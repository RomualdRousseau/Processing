class Game {
  Target target = new Target();
  Barrier barrier = new Barrier();
  Hero hero = new Hero();
  boolean gameOver = false;
  float reward = 0;
  
  float[] getState() {
    float[] state = new float[4];
    state[0] = this.hero.location.x / 400.0;
    state[1] = this.hero.location.y / 400.0;
    state[2] = this.hero.speed.x / 2.0;
    state[3] = this.hero.speed.y / 2.0;
    /*
    state[4] = this.target.location.y;
    state[5] = this.target.location.x;
    state[6] = this.target.size.y;
    state[7] = this.target.size.x;
    state[8] = this.barrier.location.y;
    state[9] = this.barrier.location.x;
    state[10] = this.barrier.size.y;
    state[11] = this.barrier.size.x;
    */
    return state;
  }

  void nextState(int a) {
    if (a == 1) {
      this.hero.trust(-0.1);
    } else if (a == 2) {
      this.hero.trust(0.1);
    }

    this.hero.update();

    if (this.hero.hit(target)) {
      this.gameOver = true;
      this.reward = 1.0;
      //println(reward);
    } else if (this.hero.hit(barrier)) {
      this.hero = new Hero();
      this.gameOver = true;
      this.reward = -1;
      //println(reward);
    } else if (this.hero.out()) {
      this.gameOver = true;
      this.reward = -this.hero.location.dist(this.target.location) / 400;
      //println(reward);
    } else {
      this.reward = 0.0;
    }
  }

  void show() {
    background(51);
    this.target.show();
    this.barrier.show();
    this.hero.show();
  }
}
