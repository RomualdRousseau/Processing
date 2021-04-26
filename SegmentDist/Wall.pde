class Wall 
{
  Wall(PVector a, PVector b, PVector d) {
    this.a = a;
    this.b = b;
    this.u = PVector.sub(b, a).normalize();
    this.n = PVector.sub(b, a).cross(d).normalize();
    this.l = PVector.sub(b, a).mag();
  }
  
  float dist(PVector p) {
    PVector v = PVector.sub(p, this.a);
    float l = v.dot(this.u);
    float d = v.dot(this.n);
    float s = d / (abs(d) + 0.00001f);
    return (max(l - this.l, 0) - min(l, 0)) * s + d;
  }
  
  PVector closestPoint(PVector p) {
    PVector v = PVector.sub(p, this.a);
    float l = v.dot(this.u);
    if(l < 0) {
      return this.a;
    } else if( l > this.l) {
      return this.b;
    } else {
      return PVector.mult(u, l).add(a);
    }
  }
  
  void draw() {
    PVector m = PVector.add(a, b).div(2);
    stroke(255, 0, 0);
    line(m.x, m.y, m.x + this.n.x * 10, m.y + this.n.y * 10);
    
    stroke(0, 255, 0);
    line(this.a.x, this.a.y, this.b.x, this.b.y);
  }
  
  PVector a;
  PVector b;
  PVector u;
  PVector n;
  float l;
}
