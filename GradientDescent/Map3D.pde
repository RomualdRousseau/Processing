class Map3D_ {
  PGraphics graphics;
  PVector view;
  boolean active = false; 
  
  void init() {
    graphics = createGraphics(width/2, height/2, P3D);
    view = new PVector(radians(-30), 0, 0);
  }

  void update() {
    final float dt = 1.0 / frameRate;

    this.graphics.beginDraw();
    this.graphics.background(51);
    this.graphics.strokeWeight(1);
    this.graphics.pushMatrix();
    this.graphics.translate(this.graphics.width / 2, this.graphics.height / 2, this.view.z * 20);
    this.graphics.rotateX(this.view.x);
    this.graphics.rotateY(this.view.y);
    this.graphics.noFill();
    this.graphics.stroke(255);
    this.graphics.box(200, 200, 200);
    for (int i = 0; i < SAMPLE_COUNT - 1; i++) {
      this.graphics.beginShape(TRIANGLE_STRIP);
      for (int j = 0; j < SAMPLE_COUNT; j++) {
        for (int k = 0; k < 2; k++) {
          color c = Map2D.image.get(j, i + k);
          float v0 = constrain(unlerp(51, 128, green(c)), 0, 1);
          float v1 = constrain(unlerp(51, 255, blue(c)), 0, 1);
          float px = map(j, 0, SAMPLE_COUNT - 1, -99, 99);
          float py = map(v1 / (v0 + v1 + EPSILON), 0, 1, -99, 99);
          float pz = map(i + k, 0, SAMPLE_COUNT - 1, -99, 99);
          this.graphics.stroke(c);
          this.graphics.fill(c, 192);
          this.graphics.vertex(px, py, pz);
        }
      }
      this.graphics.endShape();
    }
    this.graphics.popMatrix();
    this.graphics.endDraw();

    if (!this.active || !mousePressed) {
      this.view.y += CUBE_ANGULAR_VELOCITY * dt;
    }
  }

  void draw(int x, int y, int w, int h) {
    clip(x, y, w, h);
    image(this.graphics, x, y, w, h);
    noClip();
  }
}
Map3D_ Map3D = new Map3D_();
