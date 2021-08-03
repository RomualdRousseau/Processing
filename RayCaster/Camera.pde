public class Camera extends RigidBody
{
  public PVector focal = new PVector(0.66, 0.66, 1);
  public PVector up = new PVector(0, 0, -1);

  public float[][] getLookAtMatrix() {
    PVector direction = this.transform.getDirection();
    PVector right = direction.cross(up);
    return new float[][] {
      { right.x, direction.x, this.up.x },
      { right.y, direction.y, this.up.y },
      { right.z, direction.z, this.up.z }
    };
  }
}
