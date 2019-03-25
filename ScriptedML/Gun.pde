class Gun {
  PVector pos;
  
  Gun(PVector target) {
    this.pos = PVector.add(target, PVector.random2D().mult(0.2));
  }
  
  boolean hit(PVector target) {
    float d = PVector.dist(this.pos, target);
    return (d < 0.2);
  }
  
  void show() {
    float x = map(this.pos.x, -1, 1, 0, width);
    float y = map(this.pos.y, -1, 1, height, 0);
    fill(255, 255, 0);
    stroke(255);
    ellipse(x, y, 20, 20);
    fill(255, 255, 0, 128);
    noStroke();
    ellipse(x, y, 100, 100);
  }
}
