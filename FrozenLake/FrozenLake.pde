static final int EPISODE_NUM = 1000;
static final int POPULATION_NUM = 1000;
static final int STEP_NUM = 2000;

RL rl;
int score = 0;
int state = 0;
int step = 0;
float[] graph = new float[EPISODE_NUM];
int graphCount = 0;

void setup() {
  size(800, 800, P3D);
  textSize(32);
  thread("train");
}

void draw() {
  switch(state) {
  case 0:
    background(51);

    noStroke();
    fill(255, 128);
    rect(0, height - 15, width, 10);
    fill(255);
    float w = map(graphCount, 0, EPISODE_NUM, 0, width);
    rect(0, height - 15, w, 10);
  
    stroke(255, 0, 0);
    line(0, height - 100, width, height - 100);
    line(0, height - 20, width, height - 20);
    
    stroke(255);
    int j = max(0, graphCount - width / 10);
    float prevX = 0;
    float prevY = map(graph[j], 0, 1, height - 20, height - 100);
    for(int i = j; i < graphCount; i++) {
      float x = map(i, j, graphCount, 0, min(graphCount * 10, width + 10));
      float y = map(graph[i], 0, 1, height - 20, height - 100);
      line(prevX, prevY, x, y);
      prevX = x;
      prevY = y;
    }
    break;
    
  case 1:
    rl.game.render();

    fill(0);
    textSize(32);
    text(score, width / 4, 40);

    //textSize(16);
    //text("Press 'R' to generate a new board", 8, height - 8);

    mainloop();
    break;
  }
}

void train() {
  trainWithQTable(new Game());
}

void mainloop() {
  if (rl.game.isDone() || step >= STEP_NUM) {
    score = max(score, score + int(rl.game.getReward()));
    step = 0;
    rl.restart();
  } else {
    rl.run();
    step++;
  }
}
