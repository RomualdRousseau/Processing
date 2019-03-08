static final int EPISODE_NUM = 2000;

QTable q;
int episodeCount = 0;
int score = 0;

void setup() {
  size(800, 800, P3D);
  textSize(32);
  q = new QTable(new Game());
}

void draw() {
  background(0xBC, 0xE8, 0xFF);
  q.game.render();
  fill(0);
  textSize(32);
  text(String.format("%d        %d", score, episodeCount), width / 4, 40);

  if (episodeCount < EPISODE_NUM) {
    for (int n = 0; n < 500 && episodeCount < EPISODE_NUM; n++) {
      if (q.game.isDone()) {
        score = max(score, score + (int) q.game.getReward());
        episodeCount++;
        if (episodeCount >= EPISODE_NUM) {
          frameRate(10);
        }
        q.startNewEpisode(episodeCount);
      } else {
        q.learn();
      }
    }
  } else {
    if (q.game.isDone()) {
      q.startNewEpisode(episodeCount);
    } else {
      q.run();
    }
  }
}

void keyPressed() {
  if(key == 'r') {
    frameRate(60);
    episodeCount = 0;
    score = 0;
    q = new QTable(new Game());
  }
}
