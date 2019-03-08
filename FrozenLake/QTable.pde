static final float GREEDY_MIN = 0.05;
static final float GREEDY_DECAY = 0.002;
static final float LEARNING_RATE = 0.8;
static final float DISCOUNT_RATE = 0.95;

class QTable {
  BaseGame game;
  Matrix qtable;
  float greedyRate;

  QTable(BaseGame game) {
    this.game = game;
    this.qtable = new Matrix(game.getActionCount(), game.getStateCount());
    this.greedyRate = 1.0;
  }

  void startNewEpisode(int episodeCount) {
    this.greedyRate = max(GREEDY_MIN, this.greedyRate * exp(-GREEDY_DECAY));
    this.game.reset(episodeCount);
  }

  int predict(int s) {
    if (random(1.0) < this.greedyRate) {
      return floor(random(this.game.getActionCount()));
    } else {
      return this.qtable.argmax(s);
    }
  }
  
  void run() {
    int s = argmax(game.getState());
    int a = this.predict(s);    
    this.game.step(a);
    this.fit(s, a);
  }

  void learn() {
    int s = argmax(game.getState());
    int a = this.predict(s);    
    this.game.step(a);
    this.fit(s, a);
  }

  void fit(int s, int a) {
    int s_1 = argmax(this.game.getState());
    float r = this.game.getReward();
    this.qtable.set(a, s, this.qtable.get(a, s) + LEARNING_RATE * (r + DISCOUNT_RATE * this.qtable.max(s_1) - this.qtable.get(a, s)));
  }
}
