public class AnimatedSprite extends Sprite
{
  public int[][] animations;
  public float time;
  
  public int startFrame;
  public int endFrame;
  public float duration;
  
  public int heading;
  
  public AnimatedSprite(int id, float x, float y, float z, int texture, int[][] animations) {
    super(id, x, y, z, texture);
    this.animations = animations;
    this.time = 0;
    this.heading = 0;
    this.setAnimation(0);
  }
  
  public void setAnimation(int i) {
    this.startFrame = this.animations[i][0];
    this.endFrame = startFrame + this.animations[i][1];
    this.duration = this.animations[i][2];
    this.time = 0;
  }
  
  public void setDirection(float heading) {
    this.heading = ceil(map(heading, -PI, PI, 0, 8));
  }
  
  public int getTick() {
    return int(map(this.time / this.duration, 0, 1, 0, this.endFrame - this.startFrame));
  }
  
  public void update(float dt) {
    super.update(dt);
    this.textureOffsetX = int(lerp(this.startFrame, this.endFrame, this.time / this.duration)) * textureWidth; 
    this.textureOffsetY = heading * textureHeight;
    this.time = (this.time + 10 * dt) % this.duration;
  }
}
