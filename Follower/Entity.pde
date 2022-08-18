class Entity {

  public PVector position = new PVector(0, 0);
  public PVector speed = new PVector(0, 0);
  public PVector acceleration = new PVector(0, 0);
  
  public float mass = 0.1;
  public float maxSpeed = 500.0;
  
  public Entity(int x_, int y_) {
    position.set(x_, y_);
  }

  public PVector seek(PVector target, float radius, float maxForce) {
    final PVector vector = PVector.sub(target, PVector.add(position, PVector.mult(speed, dt)));
    final float distance = vector.mag();
    
    // Steering Behavior
  
    float desiredSpeed = maxSpeed;
    if (distance <= radius) {
      desiredSpeed = map(distance, 0, radius, 0, maxSpeed);
    } 
    PVector force = vector.setMag(desiredSpeed).sub(speed);

    return force.limit(maxForce);
  }
  
  public PVector avoid(PVector obstacle, float radius, float repulsion, float friction) {
    final PVector vector = PVector.sub(obstacle, PVector.add(position, PVector.mult(speed, dt)));
    final float distance = vector.mag();
    
    // Steering Behavior
  
    PVector force = new PVector(0.0, 0.0);
    if (distance <= radius) {
      
      // Collision force
      
      force.add(new PVector(0, 0, 1).cross(speed).setMag(repulsion));
      
      // Friction force
      
      force.sub(speed.copy().limit(friction));
    } 

    return force;
  }
  
  public void applyForce(PVector force) {
    
    // Newton law
    
    acceleration.add(PVector.div(force, mass));
  }
  
  public void update() {
    
    // Euler integration
  
    position.add(PVector.mult(speed, dt));
    speed.add(PVector.mult(acceleration, dt)).limit(maxSpeed);
    
    // Cleanup for next update
    
    acceleration.setMag(0.0);
  }
}
