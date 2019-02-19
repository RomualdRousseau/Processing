class Bullet extends Entity {
  int energy;
  
  Bullet(PVector position, PVector velocity) {
    this.position = position;
    this.velocity = velocity;
    this.acceleration = new PVector(0, 0);
    this.mass = 1;
    this.energy = 100;
  }
  
  void decreaseEnergy() {
    this.energy--;
    if(this.energy <= 0) {
      bullets.remove(this);
    }
  }
  
  void limits() {
    this.velocity.limit(10.0);
  }
  
  void hitRocks() {
    for (int j = rocks.size() - 1; j >= 0; j--) {
      Rock r = rocks.get(j);
      if (this.hit(r)) {
        score += 100;
        if (r.mass >= 50) {
          rocks.add(new Rock(r));
          rocks.add(new Rock(r));
        }
        rocks.remove(j);
        bullets.remove(this);
      }
    }
  }
  
  void show() {
    stroke(255);
    ellipse(this.position.x, this.position.y, this.mass, this.mass);
  }
}
