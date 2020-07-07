float score(float e, float n) {
  final float r = 0.5;
  return -(r * log(min(e, n) + 1e-7) - (1 - r) * log(n));
}

void setup() {
  size(800, 800);
}

void draw() {
  background(51);
  
  for(int i = 1; i < 800; i+=10) {
    stroke(255, 0, 0);
    strokeWeight(8);
    point(i, height - 50 * score(0, i));
  }
  
  for(int i = 1; i < 800; i+=10) {
    stroke(255, 255, 0);
    strokeWeight(8);
    point(i, height - 50 * score(1, i));
  }
  
  for(int i = 1; i < 800; i+=10) {
    stroke(0, 255, 0);
    strokeWeight(8);
    point(i, height - 50 * score(i / 2, i));
  }
  
  for(int i = 1; i < 800; i+=10) {
    stroke(0, 255, 255);
    strokeWeight(8);
    point(i, height - 50 * score(i, i));
  }
  
  noLoop();
}
