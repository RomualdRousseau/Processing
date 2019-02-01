class Game_ {
  long frameCounter;
  GameState state;
  int score;
  int pillarInterval;
  int pillarCount;

  void startup(boolean firstRun) {
    this.state = GameState.INIT;
    this.score = 0;
    this.frameCounter = 0;
    this.pillarInterval = floor(PILLAR_INTERVAL / (3.0 * frameTime));
    this.pillarCount = 0;
    
    landscape = new Landscape();
    friend = new Friend();
    trophee = null;
    pillars = new ArrayList<Pillar>();
    
    birds = new ArrayList<Bird>();
    if (mode == GameMode.DEMO) {
      if (fileExistsInData("melody.json")) {
        JSONObject jsonBrain = loadJSONObject(dataPath("melody.json"));
        birds.add(new Bird(jsonBrain));
      } else if (firstRun) {
        for (int i = 0; i < BIRDS_COUNT; i++) {
          birds.add(new Bird());
        }
      } else {
        Genetic.calculateFitness();
        Genetic.samplePool();
        Genetic.normalizePool();
        for (int i = 0; i < BIRDS_COUNT; i++) {
          birds.add(new Bird(Genetic.selectParent()));
        }
      }
      Genetic.newPool();
    } else {
      if (fileExistsInData("melody.json")) {
        JSONObject jsonBrain = loadJSONObject("melody.json");
        birds.add(new Bird(jsonBrain));
      } else {
        birds.add(new Bird());
      }
    }
  }
  
  void mainloop() {
    for (int i = 0; i < cycles * SIMULATION_STEPS; i++) {
      this.runOnce();
    }
  }
  
  void runOnce() {
    landscape.update();
    
    switch(state) {
    case INIT:
      if (isSpaceBarPressed(GameMode.INTERACTIVE)) {
        this.state = GameState.MAINLOOP;
      }
      break;
  
    case MAINLOOP:
      if(this.score >= MAX_SCORE) {
        landscape.stop();
        pillars = new ArrayList<Pillar>();
        trophee = new Trophee();
        this.state = GameState.GAMEWIN;
      } else {
        this.spawnNewPillar();

        friend.meet(null);
        friend.update();
        friend.constrainToScreen();
        
        for (int i = pillars.size() - 1; i >= 0; i--) {
          Pillar pillar = pillars.get(i);
          pillar.update();
          if(pillar.isOffView()) {
            if(isAudioPlayable()) {
              POINT_SOUND.play();
            }
            this.score++;
          }
          if (pillar.isOffscreen()) {
            pillars.remove(pillar);
          }
        }
    
        for (int i = birds.size() - 1; i >= 0; i--) {
          Bird bird = birds.get(i);
          if (bird.think()) {
            bird.fly();
          }
          bird.limit();
          bird.gravity();
          bird.update();
          if (bird.isOffscreen() || bird.hit()) {
            if(isAudioPlayable()) {
              CRASH_SOUND.play();
            }
            bird.kill();
            if (mode == GameMode.DEMO) {
              Genetic.pool.add(bird);
              birds.remove(bird);
              if (birds.size() == 0) {
                this.state = GameState.GAMEOVER;
              }
            } else {
              this.state = GameState.GAMEOVER;
            }
          }
          bird.constrainToScreen();
          bird.emitSmoke();
        }
      }
      break;
  
    case GAMEOVER:
      if (isSpaceBarPressed(GameMode.INTERACTIVE)) {
        this.startup(false);
      }
      
      for (int i = birds.size() - 1; i >= 0; i--) {
        Bird bird = birds.get(i);
        bird.gravity();
        bird.limit();
        bird.update();
        bird.constrainToScreen();
      }
      break;
      
    case GAMEWIN:
      if (isSpaceBarPressed(GameMode.ALL)) {
        this.startup(false);
      }
      
      friend.meet(trophee);
      friend.update();
      friend.constrainToScreen();
      
      for (int i = birds.size() - 1; i >= 0; i--) {
        Bird bird = birds.get(i);
        bird.meet(trophee);
        bird.update();
        bird.constrainToScreen();
        bird.emitSmoke();
      }
      break;
    }
  }
  
  void render() {
    landscape.render();
    
    if(trophee != null) {
      trophee.render();
    }
  
    friend.render();  
   
    for (int i = 0; i < pillars.size(); i++) {
      Pillar pillar = pillars.get(i);
      pillar.render();
    }
  
    for (int i = 0; i < birds.size(); i++) {
      Bird bird = birds.get(i);
      bird.render();
    }
  
    if (this.state == GameState.INIT) {
      fadeScreen();
      textSize(32);
      centeredText("FLAPPY BIRD\n\nHIT SPACEBAR TO START");
    } else if (this.state == GameState.GAMEOVER) {
      fadeScreen();
      textSize(32);
      centeredText("GAME OVER\n\nHIT SPACEBAR TO CONTINUE");
    }
    
    textSize(32);
    scoreText(String.format("%d", this.score));
  }
  
  void spawnNewPillar() {
    if ((this.frameCounter % this.pillarInterval) == 0 && this.pillarCount < MAX_SCORE) {
      pillars.add(new Pillar());
      this.pillarCount++;
    }
    this.frameCounter++;
  }
  
  boolean isAudioPlayable() {
    return audioEnabled && birds.size() < 2 && cycles < 6;
  }
}
Game_ Game = new Game_();
