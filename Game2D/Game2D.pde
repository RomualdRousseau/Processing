final int tileSize = 32;

float pitch = 1.0f;
float angle = 0.0f;
float zoom = 1.0f;

PImage tex1;
PImage tex2;

void setup() {
  size(400, 400, P3D);
  textureMode(NORMAL);
  
  tex1 = loadImage("land.jpg");
  tex2 = loadImage("wall.jpg");
}

void draw() {
  ortho();
  
  translate(width / 2, height / 2);

  scale(zoom);
  rotateX(pitch);
  rotateZ(angle);
  
  background(51);
  noStroke();

  for (int i = 0; i < 64; i++) {
    for (int j = 0; j < 64; j++) {
      pushMatrix();
      translate(i * tileSize - 32 * tileSize, j * tileSize - 32 * tileSize, 0);
      if (i == 32 && j == 32) {
        dwall(tex2);
      } else {
        dfloor(tex1);
      }
      popMatrix();
    }
  }
}

void keyPressed() {
  if (key == 'w') {
    pitch += 0.1f;
  } else if (key == 's') {
    pitch -= 0.1f;
  } else if (key == 'a') {
    angle += 0.1f;
  } else if (key == 'd') {
    angle -= 0.1f;
  } else if (key == 'r') {
    zoom += 0.1f;
  } else if (key == 'f') {
    zoom -= 0.1f;
  }
}

void dwall(PImage tex) {
  scale(tileSize / 2);
  
  beginShape(QUADS);
  texture(tex);
  
  // +Z "front" face
  vertex(-1, -1,  2, 0, 0);
  vertex( 1, -1,  2, 1, 0);
  vertex( 1,  1,  2, 1, 1);
  vertex(-1,  1,  2, 0, 1);

  // +Y "bottom" face
  vertex(-1,  1,  2, 0, 0);
  vertex( 1,  1,  2, 1, 0);
  vertex( 1,  1,  0, 1, 1);
  vertex(-1,  1,  0, 0, 1);

  // -Y "top" face
  vertex(-1, -1,  0, 0, 0);
  vertex( 1, -1,  0, 1, 0);
  vertex( 1, -1,  2, 1, 1);
  vertex(-1, -1,  2, 0, 1);

  // +X "right" face
  vertex( 1, -1,  2, 0, 0);
  vertex( 1, -1,  0, 1, 0);
  vertex( 1,  1,  0, 1, 1);
  vertex( 1,  1,  2, 0, 1);

  // -X "left" face
  vertex(-1, -1,  0, 0, 0);
  vertex(-1, -1,  2, 1, 0);
  vertex(-1,  1,  2, 1, 1);
  vertex(-1,  1,  0, 0, 1);

  endShape();
}

void dfloor(PImage tex) {
  scale(tileSize / 2);
  
  beginShape(QUADS);
  texture(tex);

  vertex(-1, -1,  0, 0, 0);
  vertex( 1, -1,  0, 1, 0);
  vertex( 1,  1,  0, 1, 1);
  vertex(-1,  1,  0, 0, 1);

  endShape();
}
