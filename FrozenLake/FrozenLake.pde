static final int EPISODE_NUM = 1000;
static final int POPULATION_NUM = 1000;
static final int STEP_NUM = 2000;

int score;
RL rl;
int state = 0;
int step = 0;

void setup() {
  size(800, 800, P3D);
  textSize(32);
  frameRate(10);
}

void draw() {
  switch(state) {
  case 0:
    trainWithQMutable(new Game());
    state = 1;
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

void mainloop() {
  if (rl.game.isDone() || step >= STEP_NUM) {
    rl.restart();
    step = 0;
  } else {
    rl.run();
    step++;
  }
}
