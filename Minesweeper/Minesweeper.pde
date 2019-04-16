static final int GRID_SIZE = 10;
static final int BEE_COUNT = 10;

Cell[][] grid = new Cell[GRID_SIZE][GRID_SIZE];
boolean boom = false;

void newBoard() {
  IntList beeGenerator = new IntList();
  for (int i = 0; i < GRID_SIZE * GRID_SIZE; i++) {
    beeGenerator.append(i);
  }
  beeGenerator.shuffle();

  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      int off = i * GRID_SIZE + j;

      boolean bee = false;
      for (int k = 0; k < BEE_COUNT; k++) {
        bee |= (beeGenerator.get(k) == off);
      }

      grid[i][j] = new Cell(i, j, bee);
    }
  }

  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      grid[i][j].countNeighboorBees();
    }
  }

  /*  
   for (int i = 0; i < GRID_SIZE; i++) {
   for (int j = 0; j < GRID_SIZE; j++) {
   grid[i][j].revealed = true;
   }
   }
   */

  boom = false;
}

void setup() {
  size(401, 401);
  newBoard();
}

void draw() {
  boolean isAllRevealed = true;
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      isAllRevealed &= grid[i][j].revealed;
    }
  }

  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      grid[i][j].show();
    }
  }

  if (isAllRevealed) {
    noStroke();
    if (boom) {
      fill(255, 0, 0, 192);
    } else {
      fill(255, 192);
    }
    rect(0, 0, width, height);
    if (boom) {
      fill(255);
    } else {
      fill(0);
    }
    textSize(16);
    text("Press 'F1' to restart", width / 2, height / 2);
  }
}

void mousePressed() {
  int i = floor(map(mouseY, 0, width - 1, 0, GRID_SIZE));
  int j = floor(map(mouseX, 0, width - 1, 0, GRID_SIZE));

  grid[i][j].reveal();

  if (mouseButton == LEFT && !grid[i][j].bee) {
    return;
  }

  if (mouseButton == RIGHT && grid[i][j].bee) {
    return;
  }

  for (i = 0; i < GRID_SIZE; i++) {
    for (j = 0; j < GRID_SIZE; j++) {
      grid[i][j].revealed = true;
    }
  }

  boom = true;
}

void keyPressed() {
  if (key == CODED && keyCode == 112) { //KeyEvent.VK_F1) {
    newBoard();
  }
}
