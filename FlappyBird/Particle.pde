class Particle extends Entity {
  Particle(Bird bird) {
    super();
    this.position = new PVector(bird.position.x - BIRD_MASS / 4, bird.position.y - 20);
    this.velocity = new PVector(random(-100, -50), random(-50, -10));
    this.acceleration = new PVector(0.0, 0.0);
  }

  void render() {
    fill(255, 192);
    noStroke();
    ellipse(mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenXY(20), scaleToScreenY(20));
  }
}
