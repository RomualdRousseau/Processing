class Pillar {
  PVector top;
  PVector bottom;
  boolean alreadyScored;
  
  Pillar() {
    this.bottom = new PVector(WIDTH, floor(random(0, HEIGHT - PILLAR_SPACING)));
    this.top = new PVector(WIDTH, this.bottom.y + PILLAR_SPACING);
    this.alreadyScored = false;
  }
  
  boolean isOffView() {
    if (!this.alreadyScored && birds.size() > 0 && this.bottom.x < birds.get(0).position.x - PILLAR_SIZE) {
      this.alreadyScored = true;
      return true;
    } else {
      return false;
    }
  }
  
  boolean isOffscreen() {
    return this.bottom.x < -PILLAR_SIZE;
  }

  void update() {
    this.bottom.x += PILLAR_SCROLLING_SPEED * SIMULATION_TIME;
    this.top.x = this.bottom.x;
  }

  void render() {
    imageMode(CORNER);
    for (float i = this.bottom.y; i >= 0; i -= PILLAR_SIZE) {
      image(PILLAR_SPRITE, mapToScreenX(this.bottom.x), mapToScreenY(i), scaleToScreenX(PILLAR_SIZE), scaleToScreenY(PILLAR_SIZE));
    }
    for (float i = this.top.y + PILLAR_SIZE; i < HEIGHT + PILLAR_SIZE; i += PILLAR_SIZE) {
      image(PILLAR_SPRITE, mapToScreenX(this.top.x), mapToScreenY(i), scaleToScreenX(PILLAR_SIZE), scaleToScreenY(PILLAR_SIZE));
    }
    
    if(DEBUG) {
      stroke(255, 0, 0);
      strokeWeight(2);
      if(birds.size() > 0 && birds.get(0).lookat() == this) {
        fill(255, 0, 0, 128);
      }
      else {
        fill(255, 128);
      }
      rect(mapToScreenX(this.bottom.x), mapToScreenY(this.bottom.y), scaleToScreenX(PILLAR_SIZE), scaleToScreenY(this.bottom.y), 7);
      rect(mapToScreenX(this.bottom.x), mapToScreenY(HEIGHT), scaleToScreenX(PILLAR_SIZE), scaleToScreenY(HEIGHT - this.bottom.y - PILLAR_SPACING), 7);
    }
  }
}
