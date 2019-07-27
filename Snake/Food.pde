class Food {
  private PVector pos;
  
  public Food() {
    this.pos = new PVector(floor(random(0, GRID_SIZE)), floor(random(0, GRID_SIZE))); 
  }
  
  public PVector getPos() {
    return this.pos;
  }
  
  public void show() {
    fill(255, 0, 0);
    float x = map(floor(this.pos.x), 0, GRID_SIZE, 0, width - 1);
    float y = map(floor(this.pos.y), 0, GRID_SIZE, 0, height - 1);
    float w = width / GRID_SIZE;
    ellipse(x + w / 2, y + w / 2, w, w);
  }
}
