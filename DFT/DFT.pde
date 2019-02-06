float r = 100.0;
float l = 300.0;
float t = 0.0;
float k = 1.0;

ArrayList<PVector> curve = new ArrayList<PVector>();

void setup() {
  size(800, 400);
}

void draw() {
  background(0);
  noFill();
  stroke(255);
  
  float dt = 1.0 / frameRate;
  
  float x1 = r * cos(-2 * PI * k * t);
  float y1 = r * sin(-2 * PI * k * t);
  
  float x2 = x1 + (r / 3) * cos(-2 * PI * k * t * 3);
  float y2 = y1 + (r / 3) * sin(-2 * PI * k * t * 3);
  
  float x3 = x2 + (r / 8) * cos(-2 * PI * k * t * 8);
  float y3 = y2 + (r / 8) * sin(-2 * PI * k * t * 8);
  
  float x4 = x3 + (r / 10) * cos(-2 * PI * k * t * 10);
  float y4 = y3 + (r / 10) * sin(-2 * PI * k * t * 10);
 
  for (int i = curve.size() - 1; i >= 0; i--) {
    PVector v = curve.get(i);
    v.x += 250 * dt;
  }
  curve.add(new PVector(0, y4));
  if(curve.size() > 100) {
    curve.remove(0);
  }

  stroke(128);
  
  ellipse(200, 200, r * 2, r * 2);
  ellipse(200 + x1, 200 + y1, (r / 3) * 2, (r / 3) * 2);
  ellipse(200 + x2, 200 + y2, (r / 8) * 2, (r / 8) * 2);
  ellipse(200 + x3, 200 + y3, (r / 10) * 2, (r / 10) * 2);
  
  line(200, 200, 200 + x1, 200 + y1);
  line(200 + x1, 200 + y1, 200 + x2, 200 + y2);
  line(200 + x2, 200 + y2, 200 + x3, 200 + y3);
  line(200 + x3, 200 + y3, 200 + x4, 200 + y4);
  
  line(200 + x3, 200 + y3, 200 + l, 200 + y3);
  
  stroke(255);
  
  beginShape();
  for (int i = curve.size() - 1; i >= 0; i--) {
    PVector v = curve.get(i);
    vertex(200 + l + v.x, 200 + v.y);
  }
  endShape();
  
  t += dt;
}
