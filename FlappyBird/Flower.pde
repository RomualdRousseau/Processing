class Flower extends Entity {
  int type;

  Flower(Entity entity) {
    super();
    this.position = new PVector(entity.position.x, entity.position.y);
    this.velocity = PVector.random2D().mult(random(FLOWER_SPEED * 0.5, FLOWER_SPEED));
    this.acceleration = new PVector(0.0, 0.0);
    this.type = floor(random(0, 2));
  }

  void gravity() {
    PVector force = new PVector(0, G * FLOWER_MASS);
    this.acceleration.add(force.div(FLOWER_MASS));
  }

  void render() {
    fill(255, 0, 0, map(life, 0, FLOWER_LIFE, 255, 0));
    imageMode(CENTER);
    pushMatrix();
    translate(mapToScreenX(this.position.x), mapToScreenY(this.position.y));
    if (type == 0) {
      image(FLOWER_SPRITE, 0, 0, scaleToScreenXY(FLOWER_MASS), scaleToScreenY(FLOWER_MASS));
    } else {
      image(HEART_SPRITE, 0, 0, scaleToScreenXY(FLOWER_MASS), scaleToScreenY(FLOWER_MASS));
    }
    popMatrix();
  }
}
