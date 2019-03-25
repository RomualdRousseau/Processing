class Portal {
  PVector pos;
  
  Portal() {
    this.pos = PVector.random2D().mult(random(1));
  }
  
  void show() {
    float x = map(this.pos.x, -1, 1, 0, width);
    float y = map(this.pos.y, -1, 1, height, 0);
    noFill();
    stroke(255);
    ellipse(x, y, 20, 20);
    line(x - 15, y , x + 15, y);
    line(x, y - 15 , x, y + 15);
  }
}
