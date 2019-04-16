class Cell {
  int row;
  int col;
  boolean bee;
  int neighboorBees;
  boolean revealed;
  
  Cell(int row, int col, boolean bee) {
    this.row = row;
    this.col = col;
    this.bee = bee;
    this.neighboorBees = 0;
    this.revealed = false;
  }

  void countNeighboorBees() {
    this.neighboorBees = 0;

    if (this.bee) {
      return;
    }

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int a = this.row + i;
        int b = this.col + j;
        if (a >= 0 && a < GRID_SIZE && b >= 0 && b < GRID_SIZE) {
          if (grid[a][b].bee) {
            this.neighboorBees++;
          }
        }
      }
    }
  }

  void reveal() {
    if (this.revealed) {
      return;
    }

    this.revealed = true;

    if (this.bee || this.neighboorBees > 0) {
      return;
    }

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int a = this.row + i;
        int b = this.col + j;
        if (a >= 0 && a < GRID_SIZE && b >= 0 && b < GRID_SIZE) {
          grid[a][b].reveal();
        }
      }
    }
  }

  void show() {
    float x = map(col, 0, GRID_SIZE, 0, width - 1);
    float y = map(row, 0, GRID_SIZE, 0, height - 1);
    float w = width / GRID_SIZE;
    float h = height / GRID_SIZE;

    textAlign(CENTER, CENTER);
    textSize(width / GRID_SIZE / 2);

    if (this.revealed) {
      if (this.bee) {
        fill(200);
        stroke(0);
        rect(x, y, w, h);
        fill(128);
        stroke(0);
        ellipse(x + w * 0.5, y + h * 0.5, w * 0.5, h * 0.5);
      } else {
        fill(200);
        stroke(0);
        rect(x, y, w, h);
        if (this.neighboorBees > 0) {
          fill(0);
          text(this.neighboorBees, x +  w * 0.5, y + h * 0.5);
        }
      }
    } else {
      fill(255);
      stroke(0);
      rect(x, y, w, h);
    }
  }
}
