class Target {
  PVector location;
  PVector size;

  Target(int size) {
    this.location = new PVector(200, 350);
    this.size = new PVector(size, size);
  }

  void show() {
    float x = map(this.location.x, 0, 400, 0, width);
    float y = map(this.location.y, 0, 400, height, 0);
    float sx = map(this.size.x, 0, 400, 0, width);
    float sy = map(this.size.y, 0, 400, 0, height);
    fill(0, 255, 0);
    noStroke();
    ellipse(x, y, sx, sy);
    //fill(0, 255, 0, 64);
    //ellipse(x, y, sx * 3, sy * 3);
  }
}
