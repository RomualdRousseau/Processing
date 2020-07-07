class Entity {
  PVector pos;
  PVector vel;
}

Entity[] entities = new Entity[50];

void setup() {
  size(800, 800);

  for (int i = 0; i < entities.length; i++) {
    entities[i] = new Entity();
    entities[i].pos = new PVector(random(width), random(height));
    entities[i].vel = PVector.random2D().mult(random(1, 2));
  }
}

void draw() {
  final int thres = width / 3;
  
  for (int i = 0; i < entities.length; i++) {
    entities[i].pos.add(entities[i].vel);
    if (entities[i].pos.x < 0 || entities[i].pos.x >= width || entities[i].pos.x < 0 || entities[i].pos.x >= height) {
      entities[i].pos = new PVector(random(width), random(height));
      entities[i].vel = PVector.random2D().mult(random(1, 2));
    }
  }

  background(51);

  for (int i = 0; i < entities.length; i++) {
    stroke(255, 255);
    strokeWeight(8);
    point(entities[i].pos.x, entities[i].pos.y);

    for (int j = i + 1; j < entities.length; j++) {
      float dist = PVector.dist(entities[i].pos, entities[j].pos);
      if (dist < thres) {
        stroke(255, map(dist, 0, thres, 255, 0));
        strokeWeight(1);
        line(entities[i].pos.x, entities[i].pos.y, entities[j].pos.x, entities[j].pos.y);
      }
    }
  }
}
