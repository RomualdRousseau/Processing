class Bird extends Entity {
  GeneticNeuralNetwork brain;
  ArrayList<Particle> smoke = new ArrayList<Particle>();
  float altitude = 0;
  
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
    /* activation */ new SoftmaxActivationFunction());
    brain.compile(
    /* shuffle */    true,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(WIDTH / 4, floor(random(BIRD_MASS, HEIGHT - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }
  
  Bird(JSONObject jsonBrain) {
    super();
    
    this.brain = new GeneticNeuralNetwork(jsonBrain);
    brain.layer1.activation = new TanhActivationFunction();
    brain.layer2.activation = new SoftmaxActivationFunction();
    brain.compile(
    /* shuffle */    false,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(WIDTH / 4, floor(random(BIRD_MASS, HEIGHT - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  Bird(Bird parent) {
    super();
    
    this.brain = parent.brain.clone();
    this.brain.mutate();

    this.position = new PVector(WIDTH / 4, floor(random(BIRD_MASS, HEIGHT - BIRD_MASS)));
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
    
    if(d < r && d > -(PILLAR_SIZE + r)) {
      if(this.position.y < closest.bottom.y + r || this.position.y > (closest.top.y - r)) {
        return true;
      } else {
        altitude = 0.9 * altitude + 0.1 * abs(this.position.y - closest.bottom.y);
        return false;
      }
    } else {
      return false;
    }
  }

  boolean think() {
    if (mode == GameMode.INTERACTIVE) {
      return mousePressed || keyPressed && key == ' ';
    }
      
    Pillar closest = this.lookat();
    if (closest == null) {
      return false;
    }
    
    Matrix input = new Matrix(new float[] {
      this.position.y / HEIGHT, 
      this.velocity.y / BIRD_MAX_SPEED, 
      (closest.top.x - this.position.x) / WIDTH, 
      (closest.top.y - this.position.y) / HEIGHT, 
      (closest.bottom.y - this.position.y) / HEIGHT
      });
    Matrix output = this.brain.predict(input);
 
    return output.data[0][0] > output.data[1][0];
  }

  void meet(Entity entity) {
    if(entity != null) {
      PVector target = new PVector(-TROPHEE_SIZE / 2, 0).add(entity.position.copy());
      PVector force = target.sub(this.position);
      force.add(this.velocity.copy().mult(-DRAG_COEF)); // Friction
      this.acceleration.add(force.div(BIRD_MASS));
    }
  }

  void fly() {
    PVector force = new PVector(0, BIRD_FLY_FORCE);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  void gravity() {
    PVector force = new PVector(0, G * BIRD_MASS);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  void limit() {
    if (this.position.y >= HEIGHT - BIRD_MASS / 2) {
      PVector force = new PVector(0, -this.velocity.mag() * 0.5);
      this.acceleration.mult(0.0).add(force);
    }
  }
  
  void constrainToScreen() {
    this.velocity.y = constrain(this.velocity.y, -BIRD_MAX_SPEED, BIRD_MAX_SPEED);
    this.position.y = constrain(this.position.y, BIRD_MASS / 2, HEIGHT - BIRD_MASS / 2);
  }
  
  Pillar lookat() {
    Pillar closest = null;
    for(int i = 0; i < pillars.size(); i++) {
      float d = pillars.get(i).bottom.x - this.position.x;
      if (d >= -(PILLAR_SIZE + BIRD_MASS / 4)) {
        closest = pillars.get(i);
        break;
      }
    }
    return closest;
  }
  
  void emitSmoke() {
    if (this.smoke.size() < 5 && this.velocity.heading() > radians(45)) {
      this.smoke.add(new Particle(this));
    }
    for (int i = smoke.size() - 1; i >= 0; i--) {
      Particle particle = smoke.get(i);
      particle.update();
      if (particle.life > SMOKE_LIFE) {
        particle.kill();
        smoke.remove(particle);
      }
    }
  }

  void render() {
    imageMode(CENTER);
    pushMatrix();
    translate(mapToScreenX(this.position.x), mapToScreenY(this.position.y));
    rotate(-constrain(this.velocity.heading(), radians(0), radians(45)));
    image(BIRD_SPRITE, 0, 0, scaleToScreenXY(BIRD_MASS), scaleToScreenY(BIRD_MASS));
    popMatrix();
    
    if (!this.alive) {
      int frame = floor(frameCount * frameRate / 500.0) % 4;
      if (frame == 0) {
        image(STAR_SPRITE, mapToScreenX(this.position.x + 32), mapToScreenY(this.position.y + 32), scaleToScreenXY(32), scaleToScreenY(32));
      }
      if (frame == 1) {
        image(STAR_SPRITE, mapToScreenX(this.position.x + 16), mapToScreenY(this.position.y - 16), scaleToScreenXY(48), scaleToScreenY(48));
      }
      if (frame == 2) {
        image(STAR_SPRITE, mapToScreenX(this.position.x - 16), mapToScreenY(this.position.y - 16), scaleToScreenXY(64), scaleToScreenY(64));
      }
      if (frame == 3) {
        image(STAR_SPRITE, mapToScreenX(this.position.x - 32), mapToScreenY(this.position.y + 32), scaleToScreenXY(48), scaleToScreenY(48));
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
      ellipse(mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenX(BIRD_MASS / 2), scaleToScreenY(BIRD_MASS / 2));
      stroke(0, 255, 0);
      ellipse(mapToScreenX(this.position.x), mapToScreenY(this.position.y), scaleToScreenX(BIRD_MASS), scaleToScreenY(BIRD_MASS));
    }
  }
}
