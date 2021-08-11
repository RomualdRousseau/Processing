float myZoom = 50;
float myMouseX = 0;
float myMouseY = 0;
Consumer<Float> F;

String[] PGA2D_BASIS = { "1", "e0", "e1", "e2", "e01", "e20", "e12", "e012" };

int[] PGA2D_GRADES = { 0, 1, 1, 1, 2, 2, 2, 3 };

String[][] PGA2D_CAYLEY = {
  { "1", "e0", "e1", "e2", "e01", "e20", "e12", "e012" },
  { "e0", "0", "e01", "-e20", "0", "0", "e012", "0" },
  { "e1", "-e01", "1", "e12", "-e0", "e012", "e2", "e20" },
  { "e2", "e20", "-e12", "1", "e012", "e0", "-e1", "e01" },
  { "e01", "0", "e0", "e012", "0", "0", "-e20", "0" },
  { "e20", "0", "e012", "-e0", "0", "0", "e01", "0" },
  { "e12", "e012", "-e2", "e1", "e20", "-e01", "-1", "-e0" },
  { "e012", "0", "e20", "e01", "0", "0", "-e0", "0" }
};

void setup() {
  size(800, 800);
  F = Algebra("PGA2D", PGA2D_BASIS, PGA2D_GRADES, PGA2D_CAYLEY, (A) -> example2(A));
}

void draw() {
  background(79);
  translate(width/2, height/2);
  basis();
  F.accept(1 / frameRate);
}

void basis() {
  float wh = width/2;
  float hh = height/2;
  
  stroke(64);
  strokeWeight(1);
  line(0, -hh, 0, hh);
  line(-wh, 0, wh, 0);

  for (float i = 0; i < wh; i+=myZoom) {
    line(-i, -2, -i, +2);
    line(i, -2, i, +2);
  }

  for (float i = 0; i < hh; i+=myZoom) {
    line(-2, -i, +2, -i);
    line(-2, i, +2, i);
  }
}

void point(float[] p, String label, boolean moveable) {
  float x = p[5] / p[6];
  float y = p[4] / p[6];
  
  if (moveable) {
    stroke(64);
    line(x * myZoom, 0, x * myZoom, -y * myZoom);
    line(0, -y * myZoom, x * myZoom, -y * myZoom);
  }

  if (moveable) {
    stroke(255, 255, 0);
    fill(255, 255, 0);
  } else {
    stroke(192);
    fill(192);
  }

  strokeWeight(8);
  point(x * myZoom, -y * myZoom);

  text(label, x * myZoom + 5, -y * myZoom - 5);
}

void line(float[] l, String label) {
  float x1, y1, x2, y2;
  if (abs(l[2]) > abs(l[3])) {
    y1 = -height/2;
    x1 = -(l[1] + l[3] * y1) / l[2];

    y2 = height/2;
    x2 = -(l[1] + l[3] * y2) / l[2];
  } else {
    x1 = -width/2;
    y1 = -(l[1] + l[2] * x1) / l[3];

    x2 = width/2;
    y2 = -(l[1] + l[2] * x2) / l[3];
  }

  float xm = (x1 + x2) / 2;
  float ym = (y1 + y2) / 2;

  stroke(255, 255, 255, 128);
  strokeWeight(1);
  line(x1 * myZoom, -y1 * myZoom, x2 * myZoom, -y2 * myZoom);

  fill(255);
  pushMatrix();
  translate(xm * myZoom, -ym * myZoom);
  rotate(-new PVector(x2 - x1, y2 - y1).heading());
  text(label, 0, 0);
  popMatrix();
}

void mouseDragged() {
  myMouseX = map(mouseX, 0, width, -width * 0.5 / myZoom, width * 0.5 / myZoom);
  myMouseY = map(mouseY, height, 0, -height * 0.5 / myZoom, height * 0.5 / myZoom);
}

void mouseWheel(MouseEvent event) {
  myZoom += event.getCount();
}
