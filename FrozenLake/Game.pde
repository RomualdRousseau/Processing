static final int TILE_NUM = 16;

static final PVector[] VECTOR_DIRS = {
  new PVector( 1, 0), 
  new PVector(-1, 0), 
  new PVector( 0, 1), 
  new PVector( 0, -1)
};

class Hero {
  Game game;
  PVector position = new PVector();
  PVector velocity = new PVector();

  Hero(Game game) {
    this.game = game;
  }

  void reset() {
    this.position.mult(0.0);
    this.velocity.mult(0.0);
  }

  void update(int a) {
    this.velocity.mult(0);
    this.move(a);
    this.wind();
    this.position.add(this.velocity);
    this.limit();
    this.markAsVisited();
  }

  void move(int a) {
    this.velocity.add(VECTOR_DIRS[a]);
  }

  void wind() {
    if (random(1.0) < this.game.windRate) {
      this.velocity.add(this.game.wind);
    }
  }

  void limit() {
    if (this.position.x < 0 || this.position.x >= TILE_NUM || this.position.y < 0 || this.position.y >= TILE_NUM) {
      this.position.sub(this.velocity);
    }
  }

  void markAsVisited() {
    final int i = floor(this.position.y);
    final int j = floor(this.position.x);

    if (this.game.grid[i][j] == 'F') {
      this.game.grid[i][j] = 'V';
    }
  }

  void show(int w, int h) {
    final float x = map(this.position.x + 0.5, 0, TILE_NUM, -width / 2, width / 2);
    final float y = map(this.position.y + 0.5, 0, TILE_NUM, -height/ 2, height / 2);

    noStroke();
    pushMatrix(); 
    translate(x, y);
    rotate(this.velocity.heading());
    image(this.game.tank, -w / 2, -h / 2, w, h);
    popMatrix();
  }
}

class Game implements BaseGame {
  PImage tank = new PImage();
  PImage goal = new PImage();
  PImage hole = new PImage();

  int[][] grid = new int[TILE_NUM][TILE_NUM];
  Hero hero;
  PVector wind;
  float windRate;

  Game() {
    this.loadResources();

    this.hero = new Hero(this);

    this.wind = VECTOR_DIRS[floor(random(4))].copy();
    this.windRate = random(0.1, 0.6);

    this.buildBoard();

    this.reset();
  }

  int getActionCount() {
    return 4;
  }

  int getStateCount() {
    return 6;
  }

  float[] getState() {
    return new float[] {
      this.hero.position.x,
      this.hero.position.y,
      this.hero.velocity.x,
      this.hero.velocity.y,
      this.wind.x,
      this.wind.y
    };
  }

  float getReward() {
    final int i = floor(this.hero.position.y);
    final int j = floor(this.hero.position.x);

    if (this.grid[i][j] == 'G') {
      return 1.0;
    } else if (this.grid[i][j] == 'H') {
      return -1.0;
    } else {
      return -0.001;
    }
  }

  boolean isDone() {
    final int i = floor(this.hero.position.y);
    final int j = floor(this.hero.position.x);
    return this.grid[i][j] == 'G' || this.grid[i][j] == 'H';
  }

  void reset() {
    this.resetBoard();
    this.hero.reset();
  }

  void step(int a) {
    this.hero.update(a);
  }

  void render() {
    final int w = width / TILE_NUM;
    final int h = height / TILE_NUM;

    background(0xBC, 0xE8, 0xFF);
    pushMatrix();
    translate(width / 2, height / 2, 0); 
    this.showBoard(w, h);
    this.showWind();
    this.hero.show(w, h);
    popMatrix();
  }

  void buildBoard() {
    for (int i = 0; i < TILE_NUM; i++) {
      for (int j = 0; j < TILE_NUM; j++) {
        this.grid[i][j] = 'F';
      }
    }

    this.grid[0][0] = 'S';
    this.grid[TILE_NUM - 1][TILE_NUM - 1] = 'G';

    int n = 0;
    while (n < TILE_NUM) {
      int i = floor(random(TILE_NUM));
      int j = floor(random(TILE_NUM));
      if (this.grid[i][j] == 'F') {
        this.grid[i][j] = 'H';
        n++;
      }
    }
  }

  void resetBoard() {
    for (int i = 0; i < TILE_NUM; i++) {
      for (int j = 0; j < TILE_NUM; j++) {
        if (this.grid[i][j] == 'V') {
          this.grid[i][j] = 'F';
        }
      }
    }
  }

  void showBoard(int w, int h) {
    for (int i = 0; i < TILE_NUM; i++) {
      for (int j = 0; j < TILE_NUM; j++) {
        final float x = map(j, 0, TILE_NUM, -width / 2, width / 2);
        final float y = map(i, 0, TILE_NUM, -height/ 2, height / 2);

        //noFill();
        //stroke(128, 32);
        //rect(x, y, w, h);

        if (this.grid[i][j] == 'G') {
          image(this.goal, x, y, w, h);
        } else if (this.grid[i][j] == 'H') {
          image(this.hole, x, y, w, h);
        } else if (this.grid[i][j] == 'S' || this.grid[i][j] == 'V') {
          fill(0, 16);
          rect(x, y, w, h);
        }
      }
    }
  }

  void showWind() {
    final float x = map((TILE_NUM - 1) + 0.5, 0, TILE_NUM, -width / 2, width / 2);
    final float y = map(0 + 0.5, 0, TILE_NUM, -height/ 2, height / 2);

    fill(255, 0, 0);
    pushMatrix(); 
    translate(x, y);
    rotate(this.wind.heading());
    triangle(-10, -5, 10, 0, -10, 5);
    popMatrix();

    fill(0);
    textSize(8);
    text(String.format("%.1f", this.windRate), x + 10, y - 10);
  }

  void loadResources() {
    this.tank = loadImage("tank.png");
    this.goal = loadImage("goal.png");
    this.hole = loadImage("hole.png");
  }
}
