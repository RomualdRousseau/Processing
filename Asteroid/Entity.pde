abstract class Entity {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  
  boolean hit(Entity other) {
    float d = this.position.dist(other.position);
    float l = (this.mass + other.mass) / 2;
    return (d < l);
  }
  
  PVector collide(Entity other) {
    float d = this.position.dist(other.position);
    float l = (this.mass + other.mass) / 2;
    if(d < l) {
      return this.position.copy().sub(other.position).normalize().mult(l - d);
    } else {
      return new PVector(0, 0);
    }
  }
  
  void limits() {
    float r = this.mass / 2;
    
    if(this.position.x > width + r) {
      this.position.x = -r;
    } else if(this.position.x < -r) {
      this.position.x = width + r;
    }
    
    if(this.position.y > height + r) {
      this.position.y = -r;
    } else if(this.position.y < -r) {
      this.position.y = height + r;
    }
    
    this.velocity.limit(5.0);
  }
  
  void applyForce(PVector force) {
    this.acceleration.add(force.copy().div(this.mass));
  }
  
  void update() {
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    this.acceleration.mult(0);
  }
  
  abstract void show();
}
