class Trophee extends Entity {
  Trophee() {
    super();
    this.position = new PVector(WIDTH / 2, HEIGHT / 2);
    this.velocity = new PVector(0.0, 0.0);
    this.acceleration = new PVector(0.0, 0.0);
  }
  
  void render() {
    fill(255);
    textSize(scaleToScreenX(32));
    textAlign(CENTER, CENTER);
    text("HAPPY VALENTINE\n\nMY BABY", mapToScreenX(WIDTH / 2), mapToScreenY(HEIGHT / 2 + TROPHEE_SIZE / 2 + 100)) ;
    imageMode(CENTER);
    image(TROPHEE_SPRITE, mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenX(TROPHEE_SIZE), scaleToScreenY(TROPHEE_SIZE));
  }
}
