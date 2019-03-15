PVector[] points = new PVector[30];

Matrix W1 = new Matrix(2, 3).transpose();
Matrix G1 = new Matrix(2, 3).transpose();
Matrix C1 = new Matrix(2, 3).transpose();
Matrix W2 = new Matrix(3, 1).transpose();
Matrix G2 = new Matrix(3, 1).transpose();
Matrix C2 = new Matrix(3, 1).transpose();
ActivationFunc activation;
LossFunc loss;
float lr = 0.001;

void setup() {
  size(400, 400);

  for (int i = 0; i < points.length; i++) {
    points[i] = new PVector(random(-1, 1), random(-0.1, 0.1));
  }

  activation = Tanh;
  loss = MeanSquaredError;
  W1.randomize();
  W2.randomize();
  C1.zero();
  C2.zero();
  
  frameRate(10);
}

void draw() {
  int n = points.length;

  G1.zero();
  G2.zero();

  for (int i = 0; i < n; i++) {
    Matrix input = new Matrix(new float[] { points[i].x, 1.0 });
    Matrix target = new Matrix(new float[] { points[i].y });

    Matrix hidden = forward(input, W1);
    Matrix output = forward(hidden, W2);
    
    Matrix lossrate = loss.derivate(output, target);
    lossrate = backward(hidden, output, lossrate, G2, W2);
    lossrate = backward(input, hidden, lossrate, G1, W1);
 
    //println(loss.apply(output, target).flatten(0));
  }

  optimize(W1, G1, C1);
  optimize(W2, G2, C2);
  
  background(51);

  stroke(255);
  strokeWeight(4);
  for (int i = 0; i < n; i++) {
    float x = map(points[i].x, -1, 1, 0, width);
    float y = map(points[i].y, -1, 1, height, 0);
    point(x, y);
  }

  stroke(255, 0, 0);
  strokeWeight(1);
  for (int x = 0; x < width; x++) {
    Matrix input = new Matrix(new float[] { map(x, 0, width, -1, 1), 1.0 });
    
    Matrix hidden = forward(input, W1);
    Matrix output = forward(hidden, W2);

    float y = map(output.get(0, 0), -1, 1, height, 0);
    point(x, y);
  }
}
