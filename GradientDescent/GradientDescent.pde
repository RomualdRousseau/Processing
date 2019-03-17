final static int SAMPLE_COUNT = 50;
final static int BRAIN_CLOCK = 10;
final static String BRAIN_MODEL = "Softmax";
final static int BRAIN_HIDDEN_NEURONS = 64;

ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<Float> accuracies = new ArrayList<Float>();
ArrayList<Float> means = new ArrayList<Float>();

Brain brain;

PImage map2D;
PGraphics map3D;
float angleX = 0.0;
float angleY = 0.0;
float zoom = 0;
boolean inMap2D = false;
boolean inMap3D = false;

void setup() {
  size(800, 800, P3D);
  noFill();
  stroke(255);
  strokeWeight(1);

  brain = new Brain();

  map2D = createImage(SAMPLE_COUNT, SAMPLE_COUNT, RGB);
  map3D = createGraphics(width/2, height/2, P3D);
}

void draw() {
  brain.fit(points);
  probeCurvesData();
  computeMap2D();
  computeMap3D();

  background(51);

  drawMap2D(0, 0, width / 2 - 1, height / 2 - 1);
  drawMap3D(width / 2 + 1, 0, width / 2 - 1, height / 2 - 1);
  drawCurves(0, height / 2 + 1, width, height / 2 - 1 - 24);
  drawHUD();
}

void probeCurvesData() {
  accuracies.add(brain.accuracy);
  if (accuracies.size() >= 2 + width) {
    accuracies.remove(0);
  }

  means.add(brain.mean);
  if (means.size() >= 2 + width) {
    means.remove(0);
  }
}

void computeMap2D() {
  map2D.loadPixels();
  for (int i = 0; i < map2D.height; i++) {
    for (int j = 0; j < map2D.width; j++) {
      Matrix predicted = brain.predict(new PVector(map(j, 0, map2D.width, 0, 1), map(i, 0, map2D.height, 0, 1)));
      float c1 = lerp(51, 128, predicted.get(0, 0));
      float c2 = lerp(51, 255, predicted.get(1, 0));
      map2D.pixels[int(i * map2D.width + j)] = color(c1, 32, c2);
    }
  }
  map2D.updatePixels();
}

void computeMap3D() {
  map3D.beginDraw();
  map3D.background(51);
  map3D.strokeWeight(1);
  map3D.pushMatrix();
  map3D.translate(map3D.width / 2, map3D.height / 2, zoom * 20);
  map3D.rotateX(angleX);
  map3D.rotateY(angleY);
  for (int i = 0; i < SAMPLE_COUNT - 1; i++) {
    map3D.beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < SAMPLE_COUNT; j++) {
      for (int k = 0; k < 2; k++) {
        color c = map2D.get(j, i + k);
        float v0 = unlerp(51, 128, red(c));
        float v1 = unlerp(51, 255, blue(c));
        float px = map(j, 0, SAMPLE_COUNT, -100, 100);
        float py = map(v1 / (v0 + v1), 0, 1, -20, 20);
        float pz = map(i + k, 0, SAMPLE_COUNT, -100, 100);
        map3D.stroke(c);
        map3D.fill(c, 128);
        map3D.vertex(px, py, pz);
      }
    }
    map3D.endShape();
  }
  map3D.popMatrix();
  map3D.endDraw();

  if (!inMap3D) {
    angleX += 0.01;
    angleY += 0.01;
  }
}

void drawMap2D(int x, int y, int w, int h) {
  clip(x, y, w, h);

  image(map2D, x, y, w, h);

  for (int i = 0; i < points.size(); i++) {
    PVector point = points.get(i);
    float x1 = map(point.x, 0, 1, x, w);
    float y1 = map(point.y, 0, 1, y, h);
    float c1 = lerp(51, 128, 1 - point.z);
    float c2 = lerp(51, 255, point.z);
    fill(c1, 32, c2);
    ellipse(x1, y1, 10, 10);
  }
  noFill();

  noClip();
}

void drawMap3D(int x, int y, int w, int h) {
  clip(x, y, w, h);
  image(map3D, x, y, w, h);
  noClip();
}

void drawCurves(int x, int y, int w, int h) {
  clip(x, y, w, h);
  strokeWeight(2);

  fill(31, 133, 255);
  text(String.format("Accuracy: %.2f%%", brain.accuracy * 100), x + 8, y + 16);
  fill(255, 133, 31);
  text(String.format("Mean: %.5f", brain.mean), x + 8, y + 32);
  fill(255);
  text(String.format("Optimizer: %s", brain.optimizer), x + 8, y + 48);
  text(String.format("Criterion: %s", brain.criterion.lossFunc), x + 8, y + 64);
  noFill();

  stroke(31, 133, 255);
  beginShape();
  for (int i = 0; i < accuracies.size(); i++) {
    Float accuracy = accuracies.get(i);
    float x1 = map(i, 0, w, x + 8, x + w - 8);
    float y1 = map(accuracy, 0, 1, y + h - 8, y + 80);
    vertex(x1, y1);
  }
  endShape();

  stroke(255, 133, 31);
  beginShape();
  for (int i = 0; i < means.size(); i++) {
    Float mse = means.get(i);
    float x1 = map(i, 0, w, x + 8, x + w - 8);
    float y1 = map(mse, 0, 1, y + h - 8, y + 80);
    vertex(x1, y1);
  }
  endShape();

  stroke(255);
  strokeWeight(1);
  noClip();
}

void drawHUD() {
  stroke(255);
  line(0, height / 2, width, height / 2);
  line(width / 2, 0, width / 2, height / 2);

  fill(255);
  text("F1: Reset the data set", 8, height - 8);
  text("F2: Reset the simulation", 8 + width / 4, height - 8);
  text("F3: Save the model", 8 + 2 * width / 4, height - 8);
  text("F4: Load the model", 8 + 3 * width / 4, height - 8);
  noFill();
}

void mouseMoved() {
  if (0 <= mouseX && mouseX < width / 2 && 0 <= mouseY && mouseY < height / 2) {
    inMap2D = true;
    inMap3D = false;
  } else if (width / 2 <= mouseX && mouseX < width && 0 <= mouseY && mouseY < height / 2) {
    inMap2D = false;
    inMap3D = true;
  } else {
    inMap2D = false;
    inMap3D = false;
  }

  if (inMap3D) {
    angleY = map(mouseX, width / 2, width, -2 * PI, 2 * PI);
    angleX = map(mouseY, 0, height / 2, -2 * PI, 2 * PI);
  }
}

void mousePressed() {
  if (inMap2D) {
    points.add(new PVector(map(mouseX, 0, width / 2, 0, 1), map(mouseY, 0, height / 2, 0, 1), (mouseButton == LEFT) ? 0 : 1));
    brain.mean = 1.0;
  }
}

void mouseWheel(MouseEvent event) {
  if (inMap3D) {
    zoom += -event.getCount();
  }
}

void keyPressed() {
  if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F1) {
    points.clear();
    brain.optimizer.reset();
  } else if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F2) {
    points.clear();
    brain.model.reset();
    brain.optimizer.reset();
  } else if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F3) {
    println("Saved");
  } else if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F4) {
    println("Loaded");
  }
}
