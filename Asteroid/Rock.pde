class Rock extends Entity {
  PVector[] points = new PVector[10];
  
  Rock() {
    this.position = new PVector(random(0, width), random(0, height));
    this.velocity = PVector.random2D().mult(random(1.0, 3.0));
    this.acceleration = new PVector(0, 0);
    this.mass = random(50, 200);
    
    for(int i = 0; i < points.length; i++) {
      float a = map(i, 0, points.length, 0, 2 * PI);
      float d = 0.5 * this.mass * random(0.5, 1.0);
      float x = d * cos(a);
      float y = d * sin(a);
      points[i] = new PVector(x, y);
    }
  }

  Rock(Rock parent) {
    this.position = parent.position.copy();
    this.velocity = PVector.random2D().mult(random(1.0, 3.0));
    this.acceleration = new PVector(0, 0);
    this.mass = parent.mass / 2;
    
    for(int i = 0; i < points.length; i++) {
      float a = map(i, 0, points.length, 0, 2 * PI);
      float d = 0.5 * this.mass * random(0.5, 1.0);
      float x = d * cos(a);
      float y = d * sin(a);
      points[i] = new PVector(x, y);
    }
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
    beginShape();
    for(int i = 0; i < points.length; i++) {
      vertex(this.position.x + points[i].x, this.position.y + points[i].y);
    }
    endShape(CLOSE);
  }
}
