class Snakey {
  private ArrayList<PVector> tail = new ArrayList<PVector>();
  private PVector vel;
  
  public Snakey() {
    this.tail.add(new PVector());
    this.vel = new PVector(0, 0);
  }

  public void move(int dx, int dy) {
    this.vel = new PVector(dx, dy);
  }

  public void grow() {
    PVector head = this.tail.get(0);
    this.tail.add(head.copy());
  }
  
  public boolean eat(Food food) {
    return this.tail.get(0).equals(food.getPos());
  }
  
  public boolean eatItself() {
    PVector head = this.tail.get(0);
    boolean result = false;
    
    for(int i = 1; i < this.tail.size(); i++) {
      result |= head.equals(this.tail.get(i));
    }
    
    return result;
  }

  public void update() {
    PVector head = this.tail.get(0);
    
    for(int i = this.tail.size() - 1; i > 0; i--) {
      this.tail.get(i).set(this.tail.get(i - 1));
    }
    
    head.add(this.vel);
    if(head.x < 0) {
      head.x = GRID_SIZE - 1;
    }
    if(head.x >= GRID_SIZE) {
      head.x = 0;
    }
    if(head.y < 0) {
      head.y = GRID_SIZE - 1;
    }
    if(head.y >= GRID_SIZE) {
      head.y = 0;
    }
  }

  public void show() {
    fill(255);
    for(PVector pos: this.tail) {
      float x = map(floor(pos.x), 0, GRID_SIZE, 0, width - 1);
      float y = map(floor(pos.y), 0, GRID_SIZE, 0, height - 1);
      float w = width / GRID_SIZE;
      rect(x, y, w, w);
    }
  }
}
