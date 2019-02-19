class Rock extends Entity {
  Rock() {
    this.position = new PVector(random(0, width), random(0, height));
    this.velocity = PVector.random2D().mult(random(1.0, 3.0));
    this.acceleration = new PVector(0, 0);
    this.mass = random(50, 200);
  }

  Rock(Rock parent) {
    this.position = parent.position.copy();
    this.velocity = PVector.random2D().mult(random(1.0, 3.0));
    this.acceleration = new PVector(0, 0);
    this.mass = parent.mass / 2;
  }

  void collideRocks() {
    for (int j = 0; j < rocks.size(); j++) {
      Rock o = rocks.get(j);
      if (this != o) {
        float m = this.mass + o.mass;
        PVector v = this.collide(o).mult(m);  
        this.applyForce(v);
        o.applyForce(v.mult(-1));
      }
    }
  }

  void show() {
    stroke(255);
    ellipse(this.position.x, this.position.y, this.mass, this.mass);
  }
}
