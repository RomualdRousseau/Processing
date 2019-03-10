class QTable extends RL {
  Matrix qtable;
  int currState;

  QTable(BaseGame game) {
    super(game);
    this.qtable = new Matrix(game.getActionCount(), TILE_NUM * TILE_NUM);
    this.reset();
  }

  void reset() {
    this.currState = normalizeState(this.game.getState());
  }

  int predict() {
    if (random(1.0) < this.greedyRate) {
      return floor(random(this.game.getActionCount()));
    } else {
      return this.qtable.argmax(this.currState);
    }
  }

  void fit(float[] state, float reward, int a) {
    int newState = normalizeState(state);
    float v_0 = this.qtable.get(a, this.currState);
    float v_1 = this.qtable.max(newState);
    this.qtable.set(a, currState, v_0 + LEARNING_RATE * (r_plus_ds(reward, v_1) - v_0));
    this.currState = newState;
  }
  
  int normalizeState(float[] state) {
    return floor(state[0] + state[1] * TILE_NUM);
  }
}

void trainWithQTable(BaseGame game) {
  score = 0;
  rl = new QTable(game);

  for (int e = 0; e < EPISODE_NUM; e++) {
    rl.restart(); 
    while(!rl.game.isDone()) {
      rl.learn();
    }
    score = max(score, score + int(rl.game.getReward()));
  }
}
