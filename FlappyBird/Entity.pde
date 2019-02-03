abstract class Entity {
  PVector position;
  PVector velocity;
  PVector acceleration;
  int life;
  boolean alive;
  
  Entity() {
    this.alive = true;
    this.life = 0;
  }
  
  void kill() {
    this.alive = false;
  }
  
  void stop() {
    this.acceleration.mult(0);
    this.velocity.mult(0);
  }
  
  void update() {
    this.velocity.add(this.acceleration.copy().mult(SIMULATION_TIME));
    this.position.add(this.velocity.copy().mult(SIMULATION_TIME));
    this.acceleration.mult(0);
    this.life++;
  }
  
  abstract void render();
}
