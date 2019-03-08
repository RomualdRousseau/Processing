Matrix[] inputs = {
  new Matrix(new float[] {0, 0}), 
  new Matrix(new float[] {0, 1}), 
  new Matrix(new float[] {1, 0}), 
  new Matrix(new float[] {1, 1})
};

Matrix[] targets = {
  new Matrix(new float[] {0}), 
  new Matrix(new float[] {1}), 
  new Matrix(new float[] {1}), 
  new Matrix(new float[] {0})
};

SequentialNeuralNetwork model = new SequentialNeuralNetwork();

void setup() {
  size(400, 400, P2D);

  model.addLayer(new Layer(2, 4)
    .setActivation(new TanhActivation())
    .setInitializer(new GlorotUniformInitializer()));

  model.addLayer(new Layer(4, 1)
    .setActivation(new LinearActivation())
    .setInitializer(new GlorotUniformInitializer()));

  model.compile(
    new Huber(), 
    new OptimizerRMSProp());
}

void draw() {
  final int r = 100;
  final int w = width / r;
  final int h = height / r;

  for (int i = 0; i < 500; i++) {
    model.fit(inputs, targets, 4, true);
  }

  background(0);
  noStroke();
  for (int i = 0; i <= r; i++) {
    for (int j = 0; j <= r; j++) {
      Matrix input = new Matrix(new float[] {(float) i / (float) r, (float) j / (float) r});
      fill(model.predict(input).data[0][0] * 255); 
      rect(j * w, i * h, w, h);
    }
  }
}

void keyPressed() {
  model.reset();
}
