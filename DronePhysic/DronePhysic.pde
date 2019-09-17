float r = 100;
float t = 1000;
float g = 9.81;
float dt = 0.1;

PVector pos;
PVector vel;
PVector acc;

void setup()
{
  size(400, 400);
  
  pos = new PVector(r, 0);
  vel = new PVector(0, 0);
  acc = new PVector(0, 0);
}

void draw()
{
  background(51);
  translate(width / 2, height / 2);
  
  PVector G = new PVector(0, -g);
  PVector T = new PVector(-t * pos.y / r, t * pos.x / r).setMag(t);
  PVector N = new PVector(-pos.x, pos.y).setMag(r);
  
  acc = new PVector().add(G).add(T).add(N);
  //acc = new PVector().add(T);
  vel.add(acc.mult(dt));
  pos.add(vel.mult(dt)).setMag(r);
  
  stroke(255);
  line(0, 0, pos.x, -pos.y);
  line(0, 0, -pos.x, pos.y);
  //line(pos.x, -pos.y, pos.x + T.x, -(pos.y + T.y));
}
