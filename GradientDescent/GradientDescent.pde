static final int SAMPLE_COUNT = 50;
static final int BRAIN_CLOCK = 10;
static final String BRAIN_DEFAULT_MODEL = "Softmax";
static final int BRAIN_HIDDEN_NEURONS = 64;

static final Action[] actionMap = {
  new Action(com.jogamp.newt.event.KeyEvent.VK_F1, "F1", "Reset the data set"),
  new Action(com.jogamp.newt.event.KeyEvent.VK_F2, "F2", "Reset the simulation"),
  new Action(com.jogamp.newt.event.KeyEvent.VK_F3, "F3", "Save the model"),
  new Action(com.jogamp.newt.event.KeyEvent.VK_F4, "F4", "Load a model")
};

ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<Float> accuracies = new ArrayList<Float>();
ArrayList<Float> means = new ArrayList<Float>();
PImage map2D;
PGraphics map3D;
float map3D_angleX = radians(-30);
float map3D_angleY = 0.0;
float map3D_zoom = 0;

void setup() {
  size(800, 800, P2D);
  noFill();
  stroke(255);
  strokeWeight(1);

  map2D = createImage(SAMPLE_COUNT, SAMPLE_COUNT, RGB);
  map3D = createGraphics(width/2, height/2, P3D);
  
  Brain.init(BRAIN_DEFAULT_MODEL);
}

void draw() {
  Brain.fit(points);
  captureCurvesData();
  computeMap2D();
  computeMap3D();

  background(51);
  drawMap2D(0, 0, width / 2 - 1, height / 2 - 1);
  drawMap3D(width / 2 + 1, 0, width / 2 - 1, height / 2 - 1);
  drawCurves(0, height / 2 + 1, width, height / 2 - 1 - 24);
  drawHUD();
}

void captureCurvesData() {
  accuracies.add(Brain.accuracy);
  if (accuracies.size() >= 1 + width) {
    accuracies.remove(0);
  }

  means.add(Brain.mean);
  if (means.size() >= 1 + width) {
    means.remove(0);
  }
}

void computeMap2D() {
  map2D.loadPixels();
  for (int i = 0; i < map2D.height; i++) {
    for (int j = 0; j < map2D.width; j++) {
      Matrix predicted = Brain.predict(new PVector(map(j, 0, map2D.width, 0, 1), map(i, 0, map2D.height, 0, 1)));
      float c1 = lerp(51, 128, predicted.get(0, 0));
      float c2 = lerp(51, 255, predicted.get(1, 0));
      map2D.pixels[int(i * map2D.width + j)] = color(32, c1, c2);
    }
  }
  map2D.updatePixels();
}

void computeMap3D() {
  map3D.beginDraw();
  map3D.background(51);
  map3D.strokeWeight(1);
  map3D.pushMatrix();
  map3D.translate(map3D.width / 2, map3D.height / 2, map3D_zoom * 20);
  map3D.rotateX(map3D_angleX);
  map3D.rotateY(map3D_angleY);
  for (int i = 0; i < SAMPLE_COUNT - 1; i++) {
    map3D.beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < SAMPLE_COUNT; j++) {
      for (int k = 0; k < 2; k++) {
        color c = map2D.get(j, i + k);
        float v0 = constrain(unlerp(51, 128, green(c)), 0, 1);
        float v1 = constrain(unlerp(51, 255, blue(c)), 0, 1);
        float px = map(j, 0, SAMPLE_COUNT, -100, 100);
        float py = map(v1 / (v0 + v1 + EPSILON), 0, 1, -20, 20);
        float pz = map(i + k, 0, SAMPLE_COUNT, -100, 100);
        map3D.stroke(c);
        map3D.fill(c, 192);
        map3D.vertex(px, py, pz);
      }
    }
    map3D.endShape();
  }
  map3D.popMatrix();
  map3D.endDraw();

  if (!inMap3D || !mousePressed) {
    map3D_angleY += 0.01;
  }
}

void drawMap2D(int x, int y, int w, int h) {
  clip(x, y, w, h);

  image(map2D, x, y, w, h);

  for (int i = 0; i < points.size(); i++) {
    PVector point = points.get(i);
    float px = map(point.x, 0, 1, x, w);
    float py = map(point.y, 0, 1, y, h);
    float c1 = lerp(51, 128, 1 - point.z);
    float c2 = lerp(51, 255, point.z);
    fill(32, c1, c2);
    ellipse(px, py, 10, 10);
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

  fill(31, 133, 255);
  text(String.format("Accuracy: %.2f%%", Brain.accuracy * 100), x + 8, y + 16);
  fill(133, 255, 31);
  text(String.format("Loss Mean: %.3f", Brain.mean), x + 8, y + 32);
  fill(255);
  text(String.format("Layout: %s", Brain), x + 8, y + 48);
  text(String.format("Optimizer: %s (learningRate=%f)", getClassInfo(Brain.optimizer), Brain.optimizer.learningRate), x + 8, y + 64);
  text(String.format("Criterion: %s", getClassInfo(Brain.criterion.lossFunc)), x + 8, y + 80);
  noFill();
  
  strokeWeight(1);
  stroke(255);
  rect(x + 4, y + 96 - 4, w - 8, h - 96);
  stroke(255, 128);
  for (int i = 0; i <= 10; i++) {
    float py = map(i, 0, 10, y + h - 8, y + 96);
    line(x + 4, py, x + w - 4, py);
  }
  for (int i = 0; i <= 10; i++) {
    float px = map(i, 0, 10, x + 8, x + w - 8);
    line(px, y + 96 - 4, px, y + h - 4);
  }

  clip(x + 8, y + 96 - 1, w - 8, h - 8);

  strokeWeight(2);
  stroke(31, 133, 255);
  beginShape();
  for (int i = 0; i < accuracies.size(); i++) {
    Float accuracy = accuracies.get(i);
    float x1 = map(i, 0, w, x + 8, x + w - 8);
    float y1 = map(accuracy, 0, 1, y + h - 8, y + 96);
    vertex(x1, y1);
  }
  endShape();

  stroke(133, 255, 31);
  beginShape();
  for (int i = 0; i < means.size(); i++) {
    Float mse = means.get(i);
    float x1 = map(i, 0, w, x + 8, x + w - 8);
    float y1 = map(mse, 0, 1, y + h - 8, y + 96);
    vertex(x1, y1);
  }
  endShape();

  stroke(255);
  strokeWeight(1);
  noClip();
}

void drawHUD() {
  noStroke();
  fill(255, 32);
  rect(0, height - 24, width, height);

  stroke(255);
  line(0, height / 2, width, height / 2);
  line(width / 2, 0, width / 2, height / 2);

  fill(255);
  for(int i = 0; i < actionMap.length; i++) {
    text(String.format("%s: %s", actionMap[i].keyString, actionMap[i].help), 8 + i * width / actionMap.length, height - 8);
  }
  noFill();
}
