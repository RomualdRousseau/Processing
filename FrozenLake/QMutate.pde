class QMutate extends RL {
  GeneticNeuralNetwork qnetwork;
  float[] s_0;

  QMutate(BaseGame game, int qnetworkHiddenCount) {
    super(game);
    this.greedyRate = 0.05;
    this.qnetwork = buildModel(qnetworkHiddenCount);
    this.reset();
  }

  QMutate(BaseGame game, GeneticNeuralNetwork parent) {
    super(game);
    this.greedyRate = 0.05;
    this.qnetwork = parent.clone();
    this.qnetwork.mutate();
    this.reset();
  }

  void reset() {
    this.qnetwork.fitness = 0;
    this.s_0 = normalizeState(this.game.getState());
  }

  int predict() {
    if (!this.isTrainingMode && random(1.0) < this.greedyRate) {
      return floor(random(this.game.getActionCount()));
    } else {
      return this.qnetwork.predict(new Matrix(this.s_0)).argmax(0);
    }
  }

  void fit(float[] state, float reward, int a) {
    float[] newState = normalizeState(state);
    PVector u = new PVector(newState[0], newState[1]);
    PVector v = new PVector(1.0, 1.0);
    this.qnetwork.fitness = max(this.qnetwork.fitness, 0.5 * reward + 0.5 * exp(-u.dist(v)));
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
      .setInitializer(new LecunUniformInitializer())
      .setNormalize(false);

    Layer layer2 = new Layer(layer1.getOutputUnits(), game.getActionCount())
      .setActivation(new LinearActivation())
      .setInitializer(new LecunUniformInitializer())
      .setNormalize(false);

    Optimizer optimizer = new OptimizerRMSProp().setLearningRate(0.1);

    LossFunction loss = new Huber();

    return (GeneticNeuralNetwork) new GeneticNeuralNetwork()
      .setMutationRate(0.05)
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

    float maxFitness = 0.0;
    for (int p = 0; p < POPULATION_NUM; p++) {
      GeneticNeuralNetwork parent = (GeneticNeuralNetwork) Genetic.selectParent();
      maxFitness = max(maxFitness, parent.fitness);
      QMutate individual = new QMutate(game, parent);
      population.add(individual);
    }

    graph[e] = 0.8 * graph[max(0, e - 1)] + 0.2 * maxFitness;
    graphCount++;
  }

  rl = new QMutate(game, (GeneticNeuralNetwork) Genetic.selectBest());
  rl.isTrainingMode = false;

  score = 0;
  state = 1;
}
