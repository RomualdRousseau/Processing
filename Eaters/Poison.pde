class Poison implements Entity
{
  public Poison(float x, float y) {
    this.pos = new PVector(x, y);
  }
  
  public float getSize() {
    return 5.0;
  }
  
  public PVector getPosition() {
    return this.pos;
  }
  
  public void kill() {
    poison.remove(this);
    poison.add(new Poison(random(BOUNDARY * 2, width - BOUNDARY * 2), random(BOUNDARY * 2, height - BOUNDARY * 2)));
  }
  
  public void draw() {
    stroke(128, 0, 0);
    fill(255, 0, 0);
    ellipse(this.pos.x, this.pos.y, 10, 10);
  }
  
  private PVector pos;
}
