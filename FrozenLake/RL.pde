static final float GREEDY_MIN = 0.05;
static final float GREEDY_DECAY = 0.002;
static final float LEARNING_RATE = 0.8;
static final float DISCOUNT_RATE = 0.95;

interface BaseGame {
  int getActionCount();

  int getStateCount();

  float[] getState();

  float getReward();

  boolean isDone();

  void step(int a);

  void reset();

  void render();
}

abstract class RL {
  BaseGame game;
  float greedyRate;
  boolean isTrainingMode;

  RL(BaseGame game) {
    this.game = game;
    this.greedyRate = 1.0;
    this.isTrainingMode = true;
  }

  void restart() {
    this.greedyRate = max(GREEDY_MIN, this.greedyRate * exp(-GREEDY_DECAY));
    this.game.reset();
    this.reset();
  }

  void run() {
    int a = this.predict();    
    this.game.step(a);
    this.fit(this.game.getState(), this.game.getReward(), a);
  }

  void learn() {
    int a = this.predict();    
    this.game.step(a);
    this.fit(this.game.getState(), this.game.getReward(), a);
  }
  
  abstract void reset();

  abstract int predict();

  abstract void fit(float[] nextState, float reward, int a);
}
