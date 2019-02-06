float n = 1;
float a = 100;
float angle = 0.0;
float depth = 200;

void setup() {
  size(400, 400);
}

float supershape(PVector p, PVector s, float n, PVector pos) {
  //return pow(abs((pos.x - p.x) / s.x), n) + pow(abs((pos.y - s.y) / s.y), n) + pow(abs((pos.z - p.z) / s.z), n) - 1.0;
  return p.mag() - 1.0;
}

float scene(PVector v) {
  return supershape(v, new PVector(a, a, a), n, new PVector(100, 50, -50));
}

void draw() {
  PVector origin = new PVector(0, 0, 100);
  
  n = map(mouseX, 0, width, 1, 10);
  
  background(0);
  stroke(255);
  
  loadPixels();
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      PVector start = new PVector(x - width / 2, height / 2 - y, 0);
      PVector ray = start.copy().sub(origin).normalize();
      start = origin.copy();
      for(int z = 0; z < 100; z++) {
        float d = scene(start); 
        if(d < 0.1) {
          float r1 = scene(new PVector(start.x + 0.1, start.y, start.z));
          float r2 = scene(new PVector(start.x - 0.1, start.y, start.z));
          float r3 = scene(new PVector(start.x, start.y + 0.1, start.z));
          float r4 = scene(new PVector(start.x, start.y - 0.1, start.z));
          float r5 = scene(new PVector(start.x, start.y, start.z + 0.1));
          float r6 = scene(new PVector(start.x, start.y, start.z - 0.1));
          PVector n = new PVector(r1 - r2, r3 - r4, r5 - r6).normalize();
          pixels[y * width + x] = color(255);
          break;
        }
        start = start.add(ray.mult(d));
      }
    }
  }
  updatePixels();
  
  noLoop();
}
