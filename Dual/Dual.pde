void setup() {
  size(800, 800);
  noLoop();
}

void draw() {
  background(79);

  GeometricObject l1 = new Line(350, 0, 450, 800).dual().dual();
  GeometricObject l2 = new Line(0, 350, 800, 450).dual().dual();
  GeometricObject p3 = new Line((Point) l1.dual(), (Point) l2.dual()).dual();
  
  l1.draw();
  l2.draw();
  p3.draw();
}
