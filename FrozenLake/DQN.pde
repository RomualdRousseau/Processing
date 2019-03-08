interface BaseGame {
  int getActionCount();

  int getStateCount();

  float[] getState();

  float getReward();

  boolean isDone();

  void reset(int episode);

  void step(int a);

  void render();
}
