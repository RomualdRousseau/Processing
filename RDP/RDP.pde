ArrayList<ArrayList<PVector>> drawing = new ArrayList<ArrayList<PVector>>();
ArrayList<PVector> current = null;

float e = 2.5;
int state = 0;

void setup() {
  size(800, 800);
}

void draw() {
  switch(state) {
  case 0:
    if (mousePressed) {
      current = new ArrayList<PVector>();
      drawing.add(current);
      current.add(new PVector(mouseX, mouseY));
      state = 1;
    }
    break;
  case 1:
    if (mousePressed) {
      current.add(new PVector(mouseX, mouseY));
      state = 1;
    } else {
      state = 0;
    }
  }

  background(51);

  int np = 0;
  stroke(255);
  strokeWeight(4);
  noFill();
  for (ArrayList<PVector> polyline : drawing) {
    beginShape();
    for (PVector v : polyline) {
      vertex(v.x, v.y);
      np++;
    }
    endShape();
  }

  int nr = 0;
  stroke(255, 0, 0);
  strokeWeight(1);
  for (ArrayList<PVector> polyline : drawing) {
    ArrayList<PVector> result = new ArrayList<PVector>();
    if (polyline.size() > 3) {
      DouglasPeucker(polyline, 0, polyline.size() - 1, e, result);
    }

    noFill();
    beginShape();
    for (PVector v : result) {
      vertex(v.x, v.y);
      nr++;
    }
    endShape();
    
    fill(255, 0, 0);
    for (PVector v : result) {
      circle(v.x, v.y, 4);
    }
  }
  
  fill(255);
  text(String.format("points = %d", np), 10, 16);
  text(String.format("n = %d    e = %.1f", nr, e), 10, 32);

}

void keyPressed() {
  if (key == '+') {
    e += 0.1;
  }
  if (key == '-') {
    e -= 0.1;
  }
  if (key == 'c') {
    drawing.clear();
  }
  
  e = constrain(e, 0, 10);
}

void DouglasPeucker(ArrayList<PVector> polyline, int a, int b, float e, ArrayList<PVector> result) {
  PVector start = polyline.get(a);
  PVector end = polyline.get(b);
  int c = -1;

  float maxL = -1;
  for (int i = a + 1; i < b; i++) {
    float l = orthoDistance(start, end, polyline.get(i));
    if (l > maxL && l >= e) {
      c = i;
      maxL = l;
    }
  }

  if (c >= 0) {
    DouglasPeucker(polyline, a, c, e, result);
    result.remove(result.size() - 1); // remove duplicates
    DouglasPeucker(polyline, c, b, e, result);
  } else {
    result.add(start);
    result.add(end);
  }
}

float orthoDistance(PVector a, PVector b, PVector c) {
  return PVector.dist(scalarProjection(a, b, c), c);
}

PVector scalarProjection(PVector a, PVector b, PVector c) {
  PVector u = PVector.sub(b, a).normalize();
  PVector v = PVector.sub(c, a);
  return PVector.add(a, u.mult(v.dot(u)));
}
