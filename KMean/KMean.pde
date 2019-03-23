Matrix[] data = new Matrix[100];
Matrix[] labels = new Matrix[100];

Classifier kmean = new Classifier();

void setup() {
  size(400, 400, P3D);

  for (int i = 0; i < 100; i++) {
    data[i] = new Matrix(new float[] { random(1), random(1) });
    labels[i] = new Matrix(K, 1, 0);
  }

  kmean.initializer(data);

  frameRate(1);
}

void draw() {
  background(51);

  for (int e = 0; e < 100; e++) {
    kmean.fit(data, labels);
  }

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      Matrix point = new Matrix(new float[] {map(x, 0, width, 0, 1), map(y, 0, height, 0, 1)});
      Matrix label = kmean.predict(point);
      float[] v = oneHot(label.argmax(0), K);
      float r = map(v[0], 0, 1, 128, 255);
      float g = map(v[1], 0, 1, 128, 255);
      float b = map(v[2], 0, 1, 128, 255);
      stroke(r, g, b, 128);
      point(x, y);
    }
  }

  noStroke();

  for (int i = 0; i < data.length; i++) {
    Matrix point = data[i];
    Matrix label = labels[i];

    float[] v = oneHot(label.argmax(0), K);
    float r = map(v[0], 0, 1, 128, 255);
    float g = map(v[1], 0, 1, 128, 255);
    float b = map(v[2], 0, 1, 128, 255);
    fill(r, g, b);

    float x = map(point.get(0, 0), 0, 1, 0, width);
    float y = map(point.get(1, 0), 0, 1, 0, height);
    ellipse(x, y, 5, 5);
  }

  for (int i = 0; i < K; i++) {
    fill(255, 128);

    float x = map(kmean.weights.get(0, i), 0, 1, 0, width);
    float y = map(kmean.weights.get(1, i), 0, 1, 0, height);
    ellipse(x, y, 10, 10);
  }

  //noLoop();
}

void keyPressed() {
  if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F1) {
    for (int i = 0; i < 100; i++) {
      data[i] = new Matrix(new float[] { random(1), random(1) });
    }
  }
}
