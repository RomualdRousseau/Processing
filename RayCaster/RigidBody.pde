public class RigidBody extends Entity {
  
  public float mass = 1.0;
  public PVector forces = new PVector(0, 0, 0);
  public PVector velocity = new PVector(0, 0, 0);
  
  public void update(float dt) {
    super.update(dt);
    
    if (this.collisionMask != 0) {
      this.velocity.mult(0);
    }

    PVector acceleration = PVector.mult(forces, mass);
    this.velocity.add(PVector.mult(acceleration, dt));
    this.transform.location.add(PVector.mult(this.velocity, dt));
  }
}
