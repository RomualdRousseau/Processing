class Barrier {
  PVector location;
  PVector size;

  Barrier() {
    this.location = new PVector(100, 200);
    this.size = new PVector(200, 10);
  }

  void show() {
    float x = map(this.location.x, 0, 400, 0, width);
    float y = map(this.location.y, 0, 400, height, 0);
    float sx = map(this.size.x, 0, 400, 0, width);
    float sy = map(this.size.y, 0, 400, 0, height);
    fill(255, 0, 0);
    noStroke();
    rect(x, y, sx, sy);
  }
}
