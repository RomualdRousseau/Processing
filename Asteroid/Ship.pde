class Ship extends Entity {
  float heading;
  int life;
  int spwaning;

  Ship() {
    this.position = new PVector(width / 2, height / 2);
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
    this.mass = 50;
    this.heading = 0;
    this.life = 3;
    this.spwaning = 0;
  }
  
  void controlPlayer() {
    if (keys[KEY_TRUST]) {
      this.trust();
    }
    if (keys[KEY_TURN_LEFT]) {
      this.turn(-0.05);
    }
    if (keys[KEY_TURN_RIGHT]) {
      this.turn(0.05);
    }
    if (keys[KEY_SHOOT]) {
      this.shoot();
    }
  }

  void respawn() {
    this.position = new PVector(width / 2, height / 2);
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
    this.mass = 50;
    this.heading = 0;
    this.life--;
    this.spwaning = 500;
  }

  void shoot() {
    if (bullets.size() < 50) {
      float r = this.mass / 2;
      PVector h = PVector.fromAngle(heading);
      bullets.add(new Bullet(h.copy().mult(r).add(this.position), h.mult(10.0)));
    }
  }

  void turn(float delta) {
    this.heading += delta;
  }

  void trust() {
    this.applyForce(PVector.fromAngle(heading).mult(20));
  }

  void friction() {
    this.applyForce(this.velocity.copy().mult(-0.01 * this.mass));
  }
  
  void hitRocks() {
    for (int j = rocks.size() - 1; j >= 0; j--) {
      Rock r = rocks.get(j);
      if (this.spwaning == 0 && ship.hit(r)) {
        this.respawn();
      }
    }
  }

  void update() {
    super.update();
    if (this.spwaning > 0) {
      this.spwaning--;
    }
  }

  void show() {
    if (this.spwaning > 0) {
      stroke(255, 128);
    } else {
      stroke(255);
    }
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(this.heading);
    float r = this.mass / 2;
    triangle(-r, -r / 2, r, 0, -r, r / 2);
    popMatrix();
  }
}
