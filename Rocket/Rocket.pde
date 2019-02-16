Game game = new Game();
int episode = 0;
int t = 0;
float p = 0.1;

GeneticNeuralNetwork model;
Matrix s;

void buildModel() {
  Layer layer1 = new Layer(4, 8)
    .setActivation(new TanhActivation())
    .setInitializer(new GlorotUniformInitializer())
    .setNormalize(false);

  Layer layer2 = new Layer(layer1.getOutputUnits(), 3)
    .setActivation(new LinearActivation())
    .setInitializer(new GlorotUniformInitializer())
    .setNormalize(false);
    
  Optimizer optimizer = new OptimizerMomentum()
    .setLearningRate(0.1);
    //.setLearningRateScheduler(new ExponentialScheduler(0.001, 200, 0.00001));

  LossFunction loss = new MeanSquaredError();

  model = (GeneticNeuralNetwork) new GeneticNeuralNetwork()
    .setMutationRate(0.1)
    .addLayer(layer1)
    .addLayer(layer2);
  model.compile(loss, optimizer);
}

void setup() {
  size(800, 800, P2D);
  noStroke();
  buildModel();
  s = new Matrix(game.getState());
}

void draw() {
  Matrix q_a_s = model.predict(s);

  int a = 0;
  if (random(1.0) < p) {
    a = floor(random(0, 3));
  } else {
    a = q_a_s.argmax(0);
  }

  game.nextState(a);

  if (!game.gameOver) {
    Matrix s_1 = new Matrix(game.getState());
    Matrix q_a_s_1 = model.predict(s_1);
    Matrix y = q_a_s.set(a, 0, game.reward + 0.9 * q_a_s_1.get(q_a_s_1.argmax(0), 0));
    model.fitOnce(s, y);

    s = s_1;
    t++;
    //p = max(p - 0.0001, 0.1);
  } else {
    Matrix y = q_a_s.set(a, 0, game.reward);
    model.fitOnce(s, y);
    
    game = new Game();
    s = new Matrix(game.getState());
    t = 0;
    episode++;
  }

  game.show();
}
