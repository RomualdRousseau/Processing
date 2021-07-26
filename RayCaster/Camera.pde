public class Camera extends RigidBody
{
  public PVector focal = new PVector(0.66, 0.66, 1);
  
  public PVector up = new PVector(0, 0, -1);
  public PVector direction = new PVector(0, -1, 0);
  
  public float[][] getLookAtMatrix() {
    PVector right = this.direction.cross(up);
    return new float[][] {
      { right.x, this.direction.x, this.up.x },
      { right.y, this.direction.y, this.up.y },
      { right.z, this.direction.z, this.up.z }
    };
  }
}
