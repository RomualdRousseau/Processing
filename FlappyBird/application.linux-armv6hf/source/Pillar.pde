class Pillar {
  PVector top;
  PVector bottom;
  boolean alreadyScored;
  
  Pillar() {
    this.bottom = new PVector(width, floor(random(0, height - PILLAR_SPACING)));
    this.top = new PVector(width, this.bottom.y + PILLAR_SPACING);
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
    this.bottom.x += PILLAR_SCROLLING_SPEED * frameTime;
    this.top.x = this.bottom.x;
  }

  void render() {
    imageMode(CORNER);
    for (float i = mapToScreenY(this.bottom.y); i < mapToScreenY(0); i += PILLAR_SIZE) {
      image(PILLAR_SPRITE, this.bottom.x, i, PILLAR_SIZE, PILLAR_SIZE);
    }
    for (float i = mapToScreenY(this.top.y); i >= mapToScreenY(height); i -= PILLAR_SIZE) {
      image(PILLAR_SPRITE, this.top.x, i - PILLAR_SIZE, PILLAR_SIZE, PILLAR_SIZE);
    }
    
    if(DEBUG) {
      stroke(255, 0, 0);
      strokeWeight(2);
      if(birds.get(0).lookat() == this) {
        fill(255, 0, 0, 128);
      }
      else {
        fill(255, 128);
      }
      rect(this.bottom.x, mapToScreenY(this.bottom.y), PILLAR_SIZE, this.bottom.y, 7);
      rect(this.bottom.x, mapToScreenY(height), PILLAR_SIZE, height - this.bottom.y - PILLAR_SPACING, 7);
    }
  }
}
