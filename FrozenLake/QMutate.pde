class QMutate extends RL {
  GeneticNeuralNetwork qnetwork;
  float[] s_0;

  QMutate(BaseGame game, int qnetworkHiddenCount) {
    super(game);
    this.qnetwork = buildModel(qnetworkHiddenCount);
    this.reset();
  }

  QMutate(BaseGame game, GeneticNeuralNetwork parentModel) {
    super(game);
    this.qnetwork = parentModel.clone();
    this.qnetwork.mutate();
    this.reset();
  }

  void reset() {
    this.qnetwork.fitness = 0;
    this.s_0 = normalizeState(this.game.getState());
  }

  int predict() {
    return this.qnetwork.predict(new Matrix(this.s_0)).argmax(0);
  }

  void fit(float[] state, float reward, int a) {
    float[] newState = normalizeState(state);
    PVector u = new PVector(newState[0], newState[1]);
    PVector v = new PVector(1.0, 1.0);
    this.qnetwork.fitness = max(this.qnetwork.fitness, 1.0 / (u.dist(v) + EPSILON));
    this.s_0 = newState;
  }
  
  float[] normalizeState(float[] state) {
    final float w = 1.0 / float(TILE_NUM);
    state[0] *= w;
    state[1] *= w;
    return state;
  }

  GeneticNeuralNetwork buildModel(int qnetworkHiddenCount) {
    Layer layer1 = new Layer(game.getStateCount(), qnetworkHiddenCount)
      .setActivation(new ReluActivation())
      .setInitializer(new GlorotUniformInitializer())
      .setNormalize(false);

    Layer layer2 = new Layer(layer1.getOutputUnits(), game.getActionCount())
      .setActivation(new LinearActivation())
      .setInitializer(new GlorotUniformInitializer())
      .setNormalize(false);

    Optimizer optimizer = new OptimizerRMSProp();

    LossFunction loss = new Huber();

    return (GeneticNeuralNetwork) new GeneticNeuralNetwork()
      .setMutationRate(0.1)
      .addLayer(layer1)
      .addLayer(layer2)
      .compile(loss, optimizer);
  }
}

void trainWithQMutable(BaseGame game) {
  ArrayList<QMutate> population = new ArrayList<QMutate>();
  
  for (int p = 0; p < POPULATION_NUM; p++) {
    QMutate individual = new QMutate(game, 32);
    population.add(individual);
  }

  for (int e = 0; e < EPISODE_NUM; e++) {
    println("Episode", e);
    Genetic.newPool();

    while (population.size() > 0) {
      QMutate individual = population.get(0);
      individual.restart();
      for (int i = 0; i < STEP_NUM && !individual.game.isDone(); i++) {
        individual.learn();
      }
      Genetic.pool.add(individual.qnetwork);
      population.remove(0);
    }

    Genetic.samplePool();
    println("Best score", Genetic.pool.get(0).getFitness());
    Genetic.normalizePool();

    for (int p = 0; p < POPULATION_NUM; p++) {
      QMutate individual = new QMutate(game, (GeneticNeuralNetwork) Genetic.selectParent());
      population.add(individual);
    }
  }

  Genetic.samplePool(1);

  score = 0;
  rl = new QMutate(game, (GeneticNeuralNetwork) Genetic.pool.get(0));
}
