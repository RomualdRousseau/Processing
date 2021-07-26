public class Sprite extends RigidBody
{
  public int texture;
  public int textureOffsetX;
  public int textureOffsetY;

  public Sprite(int id, float x, float y, float z, int texture) {
    this.id = id;
    this.transform.location = new PVector(x, y, z);
    this.texture = texture;
    this.textureOffsetX = 0;
    this.textureOffsetY = 0;
  }
}
