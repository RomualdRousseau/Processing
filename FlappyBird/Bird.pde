class Bird extends Entity {
  ArrayList<Particle> smoke = new ArrayList<Particle>();
  GeneticNeuralNetwork brain;
  
  Bird() {
    super();
    
    this.brain = new GeneticNeuralNetwork();
    brain.layer1 = new Layer(
    /* inputUnits */ 5, 
    /* units */      8, 
    /* activation */ new TanhActivationFunction());
    brain.layer2 = new Layer(
    /* inputUnits */ brain.layer1.getOutputUnits(), 
    /* units */      2, 
    /* activation */ new LinearActivationFunction());
    brain.compile(
    /* shuffle */    true,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(BIRD_X + BIRD_MASS / 2, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }
  
  Bird(JSONObject jsonBrain) {
    super();
    
    this.brain = new GeneticNeuralNetwork(jsonBrain);
    brain.layer1.activation = new TanhActivationFunction();
    brain.layer2.activation = new LinearActivationFunction();
    brain.compile(
    /* shuffle */    false,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(BIRD_X + BIRD_MASS / 2, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  Bird(Bird parent) {
    super();
    
    this.brain = parent.brain.clone();
    this.brain.mutate();

    this.position = new PVector(BIRD_X + BIRD_MASS / 2, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  boolean isOffscreen() {
    return this.position.y < BIRD_MASS / 2 - 1;
  }

  boolean hit() {
    Pillar closest = this.lookat();
    if (closest == null) {
      return false;
    }
    float r = BIRD_MASS / 4; // Roughly the hit box, somehow generous. hey! I want meet my baby
    float d = closest.bottom.x - this.position.x; // Negative is important here because the position of the pillar is relative to the center of the bird
    return (d < r && d > -(PILLAR_SIZE + r)) && (this.position.y < closest.bottom.y + r || this.position.y > (closest.top.y - r));
  }

  boolean think() {
    if (mode == GameMode.INTERACTIVE) {
      return keyPressed && key == ' ';
    }
      
    Pillar closest = this.lookat();
    if (closest == null) {
      return false;
    }
    
    Matrix input = new Matrix(new float[] {
      this.position.y / height, 
      this.velocity.y / 10, 
      (closest.top.x - this.position.x) / width, 
      (closest.top.y - this.position.y) / height, 
      (closest.bottom.y - this.position.y) / height
      });
    Matrix output = this.brain.predict(input);
    
    return output.data[0][0] > output.data[1][0];
  }

  void meet(Entity entity) {
    if(entity != null) {
      PVector target = new PVector(-TROPHEE_SIZE / 2, 0).add(entity.position.copy());
      PVector force = target.sub(this.position);
      force.add(this.velocity.copy().mult(-10.0)); // Friction
      this.acceleration.add(force.div(BIRD_MASS));
    }
  }

  void fly() {
    PVector force = new PVector(0, BIRD_FLY_FORCE);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  void gravity() {
    PVector force = new PVector(0, G).mult(BIRD_MASS);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  void limit() {
    if (this.position.y > height - BIRD_MASS / 2) {
      PVector force = this.velocity.copy().mult(-BIRD_MASS * 0.2);
      this.acceleration.mult(0.0).add(force);
    }
    this.position.y = constrain(this.position.y, BIRD_MASS / 2, height - BIRD_MASS / 2);
  }
  
  Pillar lookat() {
    if (pillars.size() == 0) {
      return null;
    }

    Pillar closest = pillars.get(0);
    float d = closest.bottom.x - this.position.x;
    if (d >= -(PILLAR_SIZE + BIRD_MASS / 4)) {
      return closest;
    }

    if (pillars.size() == 1) {
      return null;
    }

    return pillars.get(1);
  }
  
  void emitSmoke() {
    if (this.smoke.size() < 5 && this.velocity.heading() > radians(45)) {
      this.smoke.add(new Particle(this));
    }
    for (int i = smoke.size() - 1; i >= 0; i--) {
      Particle particle = smoke.get(i);
      particle.update();
      if (particle.life > 50) {
        particle.kill();
        smoke.remove(particle);
      }
    }
  }

  void render() {
    imageMode(CENTER);
    pushMatrix();
    translate(this.position.x, mapToScreenY(this.position.y));
    rotate(-constrain(this.velocity.heading(), radians(0), radians(45)));
    image(BIRD_SPRITE, 0, 0, BIRD_MASS, BIRD_MASS);
    popMatrix();
    
    if (!this.alive) {
      int frame = floor(frameCount * frameRate / 400) % 4;
      if (frame == 0) {
        image(STAR_SPRITE, this.position.x + 32, mapToScreenY(this.position.y + 32), 32, 32);
      }
      if (frame == 1) {
        image(STAR_SPRITE, this.position.x + 16, mapToScreenY(this.position.y - 16), 48, 48);
      }
      if (frame == 2) {
        image(STAR_SPRITE, this.position.x - 16, mapToScreenY(this.position.y - 16), 64, 64);
      }
      if (frame == 3) {
        image(STAR_SPRITE, this.position.x - 32, mapToScreenY(this.position.y + 32), 48, 48);
      }
    } else {
      for (int i = 0; i < smoke.size(); i++) {
        Particle particle = smoke.get(i);
        particle.render();
      }
    }
    
    if (DEBUG) {
      fill(255, 128);
      strokeWeight(2);
      stroke(255, 0, 0);
      ellipse(this.position.x, mapToScreenY(this.position.y), BIRD_MASS / 2, BIRD_MASS / 2);
      stroke(0, 255, 0);
      ellipse(this.position.x, mapToScreenY(this.position.y), BIRD_MASS, BIRD_MASS);
    }
  }
}
