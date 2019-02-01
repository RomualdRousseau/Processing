float f(float v) {
  return exp(-v - 50);
}

void setup() {
  size(400, 400);
  noLoop();
}

void draw() {
  background(255);
  stroke(0);
  beginShape();
  for(float i = 0; i < 101.0; i += 1.0) {
    float x = map(i, 0, 100.0, 0, width); 
    float y = map(f(i), 100.0, 0, 0, height);
    vertex(x, y);
  }
  endShape();
}
