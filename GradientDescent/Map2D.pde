class Map2D_ {
  ArrayList<PVector> points = new ArrayList<PVector>();
  PImage image;
  boolean active = false; 

  void init() {
    this.points.clear();
    this.image = createImage(SAMPLE_COUNT, SAMPLE_COUNT, RGB);
  }

  void update() {
    this.image.loadPixels();
    for (int i = 0; i < this.image.height; i++) {
      float b = map(i, 0, this.image.height, 0, 1);
      for (int j = 0; j < this.image.width; j++) {
        float a = map(j, 0, this.image.width, 0, 1);
        PVector y = new PVector(a, b);
        Matrix predicted = Brain.predict(y);
        float c1 = lerp(51, 128, predicted.get(0, 0));
        float c2 = lerp(51, 255, predicted.get(1, 0));
        this.image.pixels[int(i * image.width + j)] = color(32, c1, c2);
      }
    }
    this.image.updatePixels();
  }

  void draw(int x, int y, int w, int h) {
    clip(x, y, w, h);

    image(this.image, x, y, w, h);

    for (int i = 0; i < this.points.size(); i++) {
      PVector point = this.points.get(i);
      float px = map(point.x, 0, 1, x, w);
      float py = map(point.y, 0, 1, y, h);
      float c1 = lerp(51, 128, 1 - point.z);
      float c2 = lerp(51, 255, point.z);
      fill(32, c1, c2);
      ellipse(px, py, 10, 10);
    }
    noFill();

    noClip();
  }
}
Map2D_ Map2D = new Map2D_();
