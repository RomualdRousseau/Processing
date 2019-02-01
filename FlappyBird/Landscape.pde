class Landscape {
  float[] x;
  float[] y;
  float[] v;

  /* A bit crude parallax scrolling implementation
   */
  public Landscape() {
    this.x = new float[floor(width / CITY_SIZE) + 1];
    this.y = new float[floor(width / CITY_SIZE) + 1];
    this.v = new float[floor(width / CITY_SIZE) + 1];

    for (int i = 0; i < x.length; i++) {
      this.x[i] = i * CITY_SIZE;
      this.y[i] = height - CITY_SIZE;
      this.v[i] = CITY_SCROLLING_SPEED;
    }
  }
  
  void stop() {
    for (int i = 0; i < x.length; i++) {
      this.v[i] = 0;
    }
  }

  void update() {
    for (int i = 0; i < x.length; i++) {
      this.x[i] += this.v[i] * frameTime;
      if (this.x[i] < -CITY_SIZE) {
        this.x[i] = width;
      }
    }
  }

  public void render() {
    background(0, 128, 255);
    imageMode(CORNER);
    for (int i = 0; i < x.length; i++) {
      image(CITY_SPRITE, this.x[i], this.y[i], CITY_SIZE + 1, CITY_SIZE); // CITY_SIZE + 1 trick ensures seamless tiles 
    }
  }
}
