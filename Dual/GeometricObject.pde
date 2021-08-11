interface GeometricObject
{
  GeometricObject dual();

  void draw();
}

class Infinity implements GeometricObject
{
  public GeometricObject dual() {
    return this;
  }
  
  public void draw() {
  }
}

class Point implements GeometricObject
{
  PVector org;

  public Point(float _x, float _y) {
    org = new PVector(_x, _y);
  }

  public GeometricObject dual() {

    float x1 = 0;
    float y1 = x1 * org.x - org.y;

    float x2 = 1;
    float y2 = x2 * org.x - org.y;

    return new Line(x1, y1, x2, y2);
  }

  public void draw() {
    strokeWeight(4);
    stroke(255, 255, 0);
    point(org.x, org.y);
  }
}

class Line implements GeometricObject
{
  PVector org;
  PVector dir;

  public Line(Point _p1, Point _p2) {
    this(_p1.org.x, _p1.org.y, _p2.org.x, _p2.org.y);
  }

  public Line(float _x1, float _y1, float _x2, float _y2) {
    org = new PVector(_x1, _y1);
    dir = new PVector(_x2 - _x1, _y2 - _y1).normalize();
  }

  public GeometricObject dual() {
    if (dir.x == 0) {
      return new Infinity();
    } else {
      float x = dir.y / dir.x;
      float y = x * org.x - org.y;
      return new Point(x, y);
    }
  }

  public void draw() {
    if (dir.x == 0) {
      float y1 = 0;
      float x1 = (y1 - org.y) * dir.x / dir.y + org.x;

      float y2 = width;
      float x2 = (y2 - org.y) * dir.x / dir.y + org.x;

      strokeWeight(1);
      stroke(255, 0, 255);
      line(x1, y1, x2, y2);
    } else {
      float x1 = 0;
      float y1 = (x1 - org.x) * dir.y / dir.x + org.y;

      float x2 = width;
      float y2 = (x2 - org.x) * dir.y / dir.x + org.y;

      strokeWeight(1);
      stroke(255, 0, 0);
      line(x1, y1, x2, y2);
    }
  }
}
