class Friend extends Entity {
  Friend() {
    super();
    this.position = new PVector(3 * WIDTH / 4, HEIGHT / 2);
    this.velocity = new PVector(0.0, 0.0);
    this.acceleration = new PVector(0.0, 0.0);
  }
  
  void meet(Entity entity) {
    PVector target = null;
    if(entity != null) {
      target = new PVector(TROPHEE_SIZE / 2, 0).add(entity.position);
    } else if (pillars.size() > 0) {
      Pillar farest = pillars.get(pillars.size() - 1);
      target = new PVector(PILLAR_SIZE / 2, PILLAR_SPACING / 2).add(farest.bottom);
    }
    if(target != null) {
      PVector force = target.sub(this.position);
      force.add(this.velocity.copy().mult(-DRAG_COEF)); // Friction
      this.acceleration.add(force.div(FRIEND_MASS));
    }
  }
  
  void constrainToScreen() {
    this.position.y = constrain(this.position.y, FRIEND_MASS / 2, HEIGHT - FRIEND_MASS / 2);
  }
  
  void render() {
    imageMode(CENTER);
    image(BONUS_SPRITE, mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenX(FRIEND_MASS), scaleToScreenY(FRIEND_MASS));
    
    if (DEBUG) {
      fill(255, 128);
      strokeWeight(2);
      stroke(0, 255, 0);
      ellipse(mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenX(FRIEND_MASS), scaleToScreenY(FRIEND_MASS));
    }
  }
}
