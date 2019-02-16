class Hero {
  PVector size;
  PVector location;
  PVector speed;
  PVector accerelation;

  Hero() {
    this.size = new PVector(4, 20);
    this.location = new PVector(200, 0);
    this.speed = new PVector(0, 1);
    this.accerelation = new PVector(0, 0);
  }

  boolean hit(Target target) {
    float d = this.location.dist(target.location);
    if (d < target.size.y / 2) {
      return true;
    } else {
      return false;
    }
  }

  boolean hit(Barrier barrier) {
    PVector rel = this.location.copy().sub(barrier.location);
    if (rel.x > 0 && rel.x < barrier.size.x && rel.y > -barrier.size.y && rel.y < 0) {
      return true;
    } else {
      return false;
    }
  }

  boolean out() {
    if (this.location.x < 0 || this.location.x > 400 || this.location.y < 0 || this.location.y > 400) {
      return true;
    } else {
      return false;
    }
  }

  void trust(float force) {
    this.accerelation.add(new PVector(force, 0));
  }

  void update() {
    this.speed.add(this.accerelation).limit(2.0);
    this.location.add(this.speed);
    this.accerelation.mult(0);
  }

  void show() {
    float x = map(this.location.x, 0, 400, 0, width);
    float y = map(this.location.y, 0, 400, height, 0);
    float sx = map(this.size.x, 0, 400, 0, width);
    float sy = map(this.size.y, 0, 400, 0, height);
    pushMatrix();
    translate(x, y);
    rotate(PI / 2 - this.speed.heading());
    fill(255);
    //ellipse(0, 0, 10, 10);
    rect(-sx / 2, 0, sx, sy);
    popMatrix();
  }
}
