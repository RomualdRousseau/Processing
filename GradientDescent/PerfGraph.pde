class PerfGraph_ {
  ArrayList<Float> accuracies = new ArrayList<Float>();
  ArrayList<Float> means = new ArrayList<Float>();

  void init() {
    this.accuracies.clear();
    this.means.clear();
  }
  
  void update() {
    this.accuracies.add(Brain.accuracy);
    if (this.accuracies.size() >= 1 + width) {
      this.accuracies.remove(0);
    }

    this.means.add(Brain.mean);
    if (this.means.size() >= 1 + width) {
      this.means.remove(0);
    }
  }

  void draw(int x, int y, int w, int h) {
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
    for (int i = 0; i < this.accuracies.size(); i++) {
      Float accuracy = this.accuracies.get(i);
      float x1 = map(i, 0, w, x + 8, x + w - 8);
      float y1 = map(accuracy, 0, 1, y + h - 8, y + 96);
      vertex(x1, y1);
    }
    endShape();

    stroke(133, 255, 31);
    beginShape();
    for (int i = 0; i < this.means.size(); i++) {
      Float mse = this.means.get(i);
      float x1 = map(i, 0, w, x + 8, x + w - 8);
      float y1 = map(mse, 0, 1, y + h - 8, y + 96);
      vertex(x1, y1);
    }
    endShape();

    stroke(255);
    strokeWeight(1);
    noClip();
  }
}
PerfGraph_ PerfGraph = new PerfGraph_();
