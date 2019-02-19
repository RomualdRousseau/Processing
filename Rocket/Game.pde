class Game implements BaseGame {
  Target target = new Target(50);
  Barrier barrier = null;
  Hero hero = new Hero();
  boolean gameOver = false;
  float reward = 0;
  float[] state;

  Game() {
    this.buildState();
  }

  int getStateCount() {
    return 8;
  }

  int getActionCount() {
    return 3;
  }

  float[] getState() {
    return this.state;
  }

  float getReward() {
    return this.reward;
  }

  boolean isGameOver() {
    return this.gameOver;
  }

  boolean isWon() {
    return this.reward == 1.0 && this.gameOver;
  }

  void restart(int episode) {
    //if (episode == 2000) {
    //  game.barrier = new Barrier();
    //  dqn.p = 1.0;
    //} else if (episode == 4000) {
    //  game.target = new Target(10);
    //}
    this.hero = new Hero();
    this.gameOver = false;
    this.reward = 0.0;
    this.buildState();
  }

  void runOneStep(int a) {
    if (a == 1) {
      this.hero.trust(-0.1);
    } else if (a == 2) {
      this.hero.trust(0.1);
    }

    this.hero.update();

    if (this.hero.hit(this.target)) {
      this.gameOver = true;
      this.reward = 1.0;
    } else if (this.barrier != null && this.hero.hit(this.barrier)) {
      this.gameOver = true;
      this.reward = -1.0;
    } else if (this.hero.out()) {
      this.gameOver = true;
      this.reward = -1.0;
    //} else if (this.hero.inZone(target)) {
    //  this.reward = 0.5;
    } else {
      this.reward = 0.0;
    }

    this.buildState();
  }

  void show() {
    background(51);
    this.hero.show();
    this.target.show();
    if (this.barrier != null) this.barrier.show();    
    //this.hud();
  }

  void hud() {
    float x1 = map(this.hero.location.x, 0, 400, 0, width);
    float y1 = map(this.hero.location.y, 0, 400, height, 0);
    float x2 = map(this.target.location.x, 0, 400, 0, width);
    float y2 = map(this.target.location.y, 0, 400, height, 0);
    stroke(255);
    line(x1, y1, x2, y2);
  }

  void buildState() {
    this.state = new float[8];
    //this.state[0] = 0.0; //this.hero.location.x / 400.0;
    //this.state[1] = 0.0; //this.hero.location.y / 400.0;
    this.state[0] = this.hero.speed.x / 2.0;
    this.state[1] = this.hero.speed.y / 2.0;
    this.state[2] = (this.target.location.x - this.hero.location.x) / 400.0;
    this.state[3] = (this.target.location.y - this.hero.location.y) / 400.0;
    if (this.barrier == null) {
      this.state[4] = 0.0;
      this.state[5] = 0.0;
      this.state[6] = 0.0;
      this.state[7] = 0.0;
    } else {
      this.state[4] = (this.barrier.location.x - this.hero.location.x) / 400.0;
      this.state[5] = (this.barrier.location.y - this.hero.location.y) / 400.0;
      this.state[6] = (this.barrier.location.x + this.barrier.size.x - this.hero.location.x) / 400.0;
      this.state[7] = (this.barrier.location.y + this.barrier.size.y - this.hero.location.y) / 400.0;
    }
  }
}
