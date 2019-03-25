class Soldier {
  PVector pos;
  PVector speed;
  PVector target;
  boolean busy;
  boolean dead;
  boolean pickedUp;

  Soldier() {
    this.pos = PVector.random2D().mult(random(1));
    this.speed = new PVector();
    this.target = null;
    this.busy = false;
    this.dead = false;
    this.pickedUp = false;
  }

  void die() {
    this.speed.mult(0);
    this.target = null;
    this.busy = false;
    this.dead = true;
  }

  boolean reach(PVector target) {
    float d = PVector.dist(this.pos, target);
    return (d < 0.01);
  }

  void moveTo(PVector target) {
    this.speed = PVector.sub(target, this.pos).limit(0.01);
    this.target = target.copy();
    this.busy = true;
  }

  void update() {
    final float dt = (60 / frameRate);

    this.pos.add(PVector.mult(this.speed, dt));

    if (this.target != null && this.reach(this.target)) { 
      this.speed.mult(0);
      this.target = null;
      this.busy = false;
    }
  }

  void show() {
    float x = map(this.pos.x, -1, 1, 0, width);
    float y = map(this.pos.y, -1, 1, height, 0);

    fill(0, 0, 255);
    stroke(255);
    ellipse(x, y, 10, 10);

    if (this.pickedUp) {
      noFill();
      stroke(0, 255, 0);
      ellipse(x, y, 16, 16);
    }

    if (this.target != null) {
      x = map(this.target.x, -1, 1, 0, width);
      y = map(this.target.y, -1, 1, height, 0);
      fill(255, 0, 0, 128);
      noStroke();
      ellipse(x, y, 10, 10);
    }
  }
}
