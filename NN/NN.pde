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
 
NeuralNetwork model = new NeuralNetwork();
  
void setup() {
  size(400, 400, P2D);
  
  model.layer1 = new Layer(
    /* inputUnits */  2,
    /* units */       2,
    /* activation */  new TanhActivationFunction());
  
  model.layer2 = new Layer(
    /* inputUnits */  model.layer1.getOutputUnits(),
    /* units */       1,
    /* activation */  new LinearActivationFunction());
  
  model.compile(
    /* loss */      new MeanSquaredErrorFunction(),
    /* optimizer */ new OptimizerMomentum(1.0),
    /* scheduler */ new ExponentialScheduler(0.1));
}

void draw() {
  final int r = 100;
  final int w = width / r;
  final int h = height / r;
  
  model.fit(inputs, targets, 1, 500, true);
  
  background(0);
  noStroke();
  for(int i = 0; i <= r; i++) {
    for(int j = 0; j <= r; j++) {
      Matrix input = new Matrix(new float[] {(float) i / (float) r, (float) j / (float) r});
      fill(model.predict(input).data[0][0] * 255); 
      rect(j * w, i * h, w, h);    
    }
  }
}

void keyPressed() {
  model.reset();
}
