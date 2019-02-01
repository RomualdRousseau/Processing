class Creature implements Entity
{
  public Creature() {
    this.pos = new PVector(random(width), random(height));
    this.vel = new PVector(1, 0);
    this.acc = new PVector(0, 0);
    this.health = 1.0;
    this.children = 0;
    this.age = 0.0;
    this.s = 1;
    this.a = 0;
    this.randomQ();
    this.randomDNA();
  }
  
  public Creature(Creature parent) {
    this.pos = new PVector(random(width), random(height));
    this.vel = new PVector(1, 0);
    this.acc = new PVector(0, 0);
    this.health = 1.0;
    this.children = 0;
    this.age = 0.0;
    this.s = 1;
    this.a = 0;
    this.cloneQ(parent.q);  
    this.cloneDNA(parent.dna);
  }
  
  public float getSize() {
    return this.dna[6] * MAX_MASS * 2.0;
  }
  
  public PVector getPosition() {
    return this.pos;
  }
  
  public boolean isDead() {
    return this.health == 0.0;
  }
  
  public void eat() {
    this.health = Math.min(1.0, this.health + EAT_POINT);
    this.learn(EAT_POINT * 10.0, 0);
  }
  
  public void kill() {
    this.health = Math.max(0, this.health + KILL_POINT);
    this.learn(KILL_POINT * 10.0, 1);
  }
  
  public void think(ArrayList<? extends Entity> food, ArrayList<? extends Entity> poison) {
    if(this.health == 0) {
      this.learn(DIE_POINT * 10.0, 1);
      creatures.remove(this);
      lifeSpan = (lifeSpan + this.age) * 0.5;
      creatures.add(new Creature(this));
    }
    else {
      this.reproduce();
      this.lookForFood(food, this.dna[0], this.dna[2] * VISIBILITY_RADIUS);
      this.lookForFood(poison, this.dna[1], this.dna[3] * VISIBILITY_RADIUS);
      this.lookForCreature(creatures, getSize());
      this.stayWithinWorldLimits(BOUNDARY);
      if((((int) this.age) % 2) == 0) {
        this.learn(0, s);
      }
    }
  }

  public void update() {
    this.vel.add(this.acc).limit(this.dna[5] * MAX_SPEED);
    this.pos.add(this.vel);
    this.acc.mult(0);
    this.health = max(0, this.health - HEALTH_DECAY);
    this.age += AGE_RATE;
  }
  
  public void draw() {
    stroke(lerpColor(color(128, 128, 128), color(256, 0, 0), this.dna[1]), 255 * this.health);
    fill(lerpColor(color(128, 128, 128), color(0, 256, 0), this.dna[0]), 255 * this.health);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(this.vel.heading());
    beginShape();
    vertex(-this.getSize() * 0.5, this.getSize() * 0.25);
    vertex(-this.getSize() * 0.5, -this.getSize() * 0.25);
    vertex(this.getSize() * 0.5, 0);
    endShape(CLOSE);
    popMatrix();
    
    // Debug
    println(q[s]);
    noFill();
    stroke(0, 255, 0);
    ellipse(this.pos.x, this.pos.y, this.dna[2] * VISIBILITY_RADIUS * 2, this.dna[2] * VISIBILITY_RADIUS * 2);
    stroke(255, 0, 0);
    ellipse(this.pos.x, this.pos.y, this.dna[3] * VISIBILITY_RADIUS * 2, this.dna[3] * VISIBILITY_RADIUS * 2);
  }
  
  private void reproduce() {
    if(this.children == 0 && random(1.0) < Math.sqrt(this.age + 0.01) / REPRO_RATE) {
      creatures.add(new Creature(this));
      this.children++;
    }
  }
  
  private void lookForFood(ArrayList<? extends Entity> entities, float weight, float visibility) {
    Entity closestEntity = this.lookAt(entities, Math.max(this.getSize() * 0.5, visibility));
    if(closestEntity == null) {
      return;
    }
    if(this.pos.dist(closestEntity.getPosition()) < (closestEntity.getSize() + this.getSize()) * 0.5) {
      if(closestEntity instanceof Food) {
        this.eat();
      }
      else if(closestEntity instanceof Poison) {
        this.kill();
      }
      closestEntity.kill();
    }
    else {
      this.seek(closestEntity.getPosition(), weight);
    }
  }
  
  private void lookForCreature(ArrayList<? extends Entity> entities, float visibility) {
    for(Entity entity: entities) if(this != entity) {
      float d = this.pos.dist(entity.getPosition());
      if(d < visibility) {
        this.separate(entity.getPosition());
      }
    }
  }
  
  private void stayWithinWorldLimits(int boundary) {
    if(this.pos.x < boundary || this.pos.x >= width - boundary || this.pos.y < boundary || this.pos.y >= height - boundary) {
      this.bounce();
    }
  }
  
  private void seek(PVector target, float weight) {
    this.acc.add(target.copy().sub(this.pos).mult(weight).limit(this.dna[4] * MAX_FORCE).div(this.dna[6] * MAX_MASS));
  }
  
  private void separate(PVector target) {
    this.acc.add(target.copy().sub(this.pos).mult(-1.0).limit(MAX_FORCE).div(this.dna[6] * MAX_MASS));
  }
  
  private void bounce() {
    this.acc.add(new PVector(width * 0.5, height * 0.5).sub(this.pos).limit(MAX_FORCE).div(this.dna[6] * MAX_MASS));
  }
  
  private Entity lookAt(ArrayList<? extends Entity> entities, float visibility) {
    float min = 0.0;
    Entity closestEntity = null;
    for(Entity entity: entities) {
      float d = this.pos.dist(entity.getPosition());
      if(d >= visibility) {
        continue;
      }
      if(closestEntity == null || d < min) {
        min = d;
        closestEntity = entity;
      }
    }
    return closestEntity;
  }
  
  private void learn(float r, int ss) {
    if(s == 0 || ss == 0) {
      return;
    }
    
    int aa;
    if(random(1.0) < GREEDY_RATE / Math.sqrt(this.age + 1.0)) {
      aa = floor(random(15));
    }
    else {
      aa = argmax(q[ss]);
    }
    
    // Bellman equation, optimal
    //q[s][a] = (1.0 - LEARNING_REATE) * q[s][a] + LEARNING_REATE * (r + DISCOUNTING_RATE * max(q[ss]));
    // SARSA, less optimal but more stable
    q[s][a] = (1.0 - LEARNING_REATE) * q[s][a] + LEARNING_REATE * (r + DISCOUNTING_RATE * q[ss][aa]);
    
    s = ss;
    a = aa;
    
    this.step();
  }
  
  private void step() {
    if(a > 0) {
      this.adaptDNA(a - 1);
    }
  }
  
  private void randomQ() {
    for(int i = 0; i < 2; i++) {
      for(int j = 0; j < 15; j++) {
        q[i][j] = 0.0; //random(-1.0, 1.0);
      }
    }
  }
  
  private void cloneQ(float[][] q) {
    for(int i = 0; i < 2; i++) {
      for(int j = 0; j < 15; j++) {
        this.q[i][j] = q[i][j];
      }
    }
  }
  
  private void randomDNA() {
    this.dna[0] = random(-1.0, 1.0); // food attirance
    this.dna[1] = random(-1.0, 1.0); // poison adversion
    this.dna[2] = random(1.0);       // food radius
    this.dna[3] = random(1.0);       // poison radius
    this.dna[4] = random(1.0);       // maxForce
    this.dna[5] = random(1.0);       // maxSpeed
    this.dna[6] = random(1.0);       // mass
    this.limitDNA();
  }
  
  private void cloneDNA(float[] dna) {
    this.dna[0] = dna[0]; // food attirance
    this.dna[1] = dna[1]; // poison adversion
    this.dna[2] = dna[2]; // food radius
    this.dna[3] = dna[3]; // poison radius
    this.dna[4] = dna[4]; // maxForce
    this.dna[5] = dna[5]; // maxSpeed
    this.dna[6] = dna[6]; // mass
    this.mutateDNA();
  }
  
  private void mutateDNA() {
    float r = (float) (MUTATION_RATE * MUTATION_SCALE / Math.sqrt(this.age + 0.01));
    this.dna[0] = (random(1.0) < r) ? random(-1.0, 1.0) : this.dna[0]; // food attirance
    this.dna[1] = (random(1.0) < r) ? random(-1.0, 1.0) : this.dna[1]; // poison adversion
    this.dna[2] = (random(1.0) < r) ? random(1.0) : this.dna[2];       // food radius
    this.dna[3] = (random(1.0) < r) ? random(1.0) : this.dna[3];       // poison radius
    this.dna[4] = (random(1.0) < r) ? random(1.0) : this.dna[4];       // maxForce
    this.dna[5] = (random(1.0) < r) ? random(1.0) : this.dna[5];       // maxSpeed
    this.dna[6] = (random(1.0) < r) ? random(1.0) : this.dna[6];       // mass
    this.limitDNA();
  }
  
  private void adaptDNA(int i) {
    if((i % 2) == 0) {
      this.dna[i / 2] -= MUTATION_RATE;
    }
    else {
      this.dna[i / 2] += MUTATION_RATE;
    }
    this.limitDNA();  
  }
  
  private void limitDNA() {
    this.dna[0] = constrain(this.dna[0], -1.0, 1.0); // food attirance
    this.dna[1] = constrain(this.dna[1], -1.0, 1.0); // poison adversion
    this.dna[2] = constrain(this.dna[2], 0.01, 1.0); // food radius
    this.dna[3] = constrain(this.dna[3], 0.01, 1.0); // poison radius
    this.dna[4] = constrain(this.dna[4], 0.01, 1.0); // maxForce
    this.dna[5] = constrain(this.dna[5], 0.01, 1.0); // maxSpeed
    this.dna[6] = constrain(this.dna[6], 0.01, 1.0); // mass
  }

  private PVector pos;
  private PVector vel;
  private PVector acc;
  private float health;
  private float age;
  private float[] dna = new float[7];
  private int children;
  
  private float[][] q = new float[2][15];
  private int s;
  private int a;
}
