static final int TILE_NUM = 16;
static final float WIND_RATE = 0.5;

static final PVector wind = new PVector(1, 0);
static final PVector[] engine = {
  new PVector( 1, 0), 
  new PVector(-1, 0), 
  new PVector( 0, 1), 
  new PVector( 0, -1)
};

class Game implements BaseGame {
  PImage tank = new PImage();
  PImage igloo = new PImage();
  PImage hole = new PImage();

  int[][] grid = new int[TILE_NUM][TILE_NUM];
  PVector position = new PVector();
  PVector velocity = new PVector();

  Game() {
    this.loadResources();
    this.buildBoard();
    this.reset(0);
  }

  int getActionCount() {
    return 4;
  }

  int getStateCount() {
    return TILE_NUM * TILE_NUM;
  }

  float[] getState() {
    return oneHot(floor(this.position.x + this.position.y * TILE_NUM), TILE_NUM * TILE_NUM);
  }

  float getReward() {
    final int i = floor(this.position.y);
    final int j = floor(this.position.x);
    
    if (this.grid[i][j] == 'G') {
      return 1.0;
    } else if (this.grid[i][j] == 'H') {
      return -1.0;
    } else {
      return -0.001;
    }
  }

  boolean isDone() {
    final int i = floor(this.position.y);
    final int j = floor(this.position.x);
    return this.grid[i][j] == 'G' || this.grid[i][j] == 'H';
  }

  void reset(int episode) {
    this.resetBoard();
    this.position.mult(0.0);
    this.velocity.mult(0.0);
  }

  void step(int a) {
    this.velocity.mult(0);
    this.move(a);
    this.wind();
    this.position.add(this.velocity);
    this.limit();
    this.markAsVisited();
  }

  void render() {
    final int w = width / TILE_NUM;
    final int h = height / TILE_NUM;

    pushMatrix();
    translate(width / 2, height / 2, 0); 
    this.showBoard(w, h);
    this.showHero(w, h);
    this.showWind();
    popMatrix();
  }

  void move(int a) {
    this.velocity.add(engine[a]);
  }

  void wind() {
    if (random(1.0) < WIND_RATE) {
      this.velocity.add(wind);
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
    
    if (this.grid[i][j] == 'F') {
      this.grid[i][j] = 'V';
    }
  }

  void showHero(int w, int h) {
    final float x = map(this.position.x + 0.5, 0, TILE_NUM, -width / 2, width / 2);
    final float y = map(this.position.y + 0.5, 0, TILE_NUM, -height/ 2, height / 2);

    noStroke();
    pushMatrix(); 
    translate(x, y);
    rotate(this.velocity.heading());
    image(this.tank, -w / 2, -h / 2, w, h);
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
          image(this.igloo, x, y, w, h);
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
    rotate(wind.heading());
    triangle(-10, -5, 10, 0, -10, 5);
    popMatrix();
    
    fill(0);
    textSize(8);
    text(String.format("%.1f", WIND_RATE), x + 10, y - 10);
  }

  void loadResources() {
    this.tank = loadImage("tank.png");
    this.igloo = loadImage("igloo.png");
    this.hole = loadImage("hole.png");
  }
}
