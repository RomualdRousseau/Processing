final int NUMBER_OF_STEPS = 32;
final float MINIMUM_HIT_DISTANCE = 0.01f;
final float MAXIMUM_TRACE_DISTANCE = 1000.0f;
  
PVector cam = new PVector(0, 0, -2);
PVector light = new PVector(2, -5, 3);

float sphere(PVector p, PVector c, float r) {
  return PVector.sub(p, c).mag() - r;
}

float map_the_world(PVector p) {
  float sphere_0 = sphere(p, new PVector(0, 0, 0), 1);
  
  float cf = cos(frameCount * 0.1f);
  float dis_0 = sin(5 * p.x * cf) * sin(5 * p.y * cf) * sin(5 * p.z * cf) * 0.25;
  
  return sphere_0 + dis_0;
}

PVector normal_fast(PVector p) {
  final PVector sx = new PVector(0.001f, 0, 0);
  final PVector sy = new PVector(0, 0.001f, 0);
  final PVector sz = new PVector(0, 0, 0.001f);
  
  float gx = map_the_world(PVector.add(p, sx)) - map_the_world(PVector.sub(p, sx));
  float gy = map_the_world(PVector.add(p, sy)) - map_the_world(PVector.sub(p, sy));
  float gz = map_the_world(PVector.add(p, sz)) - map_the_world(PVector.sub(p, sz));
  return new PVector(gx, gy, gz).normalize();
}

int ray_march(PVector ro, PVector rd) {
  float t = 0.0f;
  
  for (int i = 0; i < NUMBER_OF_STEPS; i++) {
    PVector cp = PVector.mult(rd, t).add(ro);
    
    float d = map_the_world(cp);
    
    if (d < MINIMUM_HIT_DISTANCE) {
      PVector n = normal_fast(cp);
      PVector ld = PVector.sub(cp, light).normalize();
      float diff = max(0, PVector.dot(n, ld));
      return color(204 * diff + 51, 51, 51 * 2);
    } else if (d > MAXIMUM_TRACE_DISTANCE) {
      break;
    }
    
    t += d;
  }
  
  return color(51, 51, 51);
}

int shader_call(PVector uv) {
  PVector ro = cam;
  PVector rd = new PVector(uv.x, uv.y, 1).normalize();
  return ray_march(ro, rd);
}

void setup() {
  size(200, 200);
}

void draw() {
  loadPixels();
  for(int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
        PVector uv = new PVector(map(x, 0, width, -1, 1), map(y, 0, height, 1, -1), 0);
        pixels[y * width + x] = shader_call(uv);
    }
  }
  updatePixels();
}

 
