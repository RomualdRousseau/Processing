class Trophee extends Entity {
  Trophee() {
    super();
    this.position = new PVector(width / 2, height / 2);
    this.velocity = new PVector(0.0, 0.0);
    this.acceleration = new PVector(0.0, 0.0);
  }
  
  void render() {
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("HAPPY VALENTINE\n\nMY BABY", width / 2, height / 2 - TROPHEE_SIZE / 2 - 100) ;
    imageMode(CENTER);
    image(TROPHEE_SPRITE, this.position.x, mapToScreenY(this.position.y), TROPHEE_SIZE, TROPHEE_SIZE);
  }
}
