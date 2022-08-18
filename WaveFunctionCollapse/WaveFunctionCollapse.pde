int[][] grid = new int[9][9];

IntList candidates = new IntList();

void setup() {
  size(800, 800);

  initGrid();
}

void draw() {
  final int w = width / grid[0].length;
  final int h = height / grid.length;
  final int dw = w / 3;
  final int dh = h / 3;
  
  background(0);
  stroke(0);
  
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[i].length; j++) {
      final int v = grid[i][j];
      
      if (v == 0) {
        fill(128);
      } else {
        fill(255);
      }
      rect(j * w, i * h, w, h);
      
      fill(0); 
      textSize(dw * 0.6);
      textAlign(CENTER, CENTER);
      for(int k = 0; k < 9; k++) {
        int x = k % 3;
        int y = k / 3;
        if((v & (1 << k)) > 0) {
          text(k + 1, j * w + x * dw + dw / 2, i * h + y * dh + dh / 2);
        }
      }
    }
  }
  
  noFill();
  stroke(255, 0, 0);
  final int x = mouseX / w;
  final int y = mouseY / h;
  rect(x * w, y * w, w, h);
}

void keyPressed() {
  if (candidates.size() == 0) {
    initGrid();
  } else while(candidates.size() > 0) {
    final int r = getBestCellRef(candidates);  
    final int x = getXFromCellRef(r);
    final int y = getYFromCellRef(r);
    final int v = grid[y][x];
    
    if(countBits(v, 9) > 0) {
      collapseCell(grid, x, y, randomBits(v, 9));
    }
  }
}

void initGrid() {
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[i].length; j++) {
      grid[i][j] = 511;
      candidates.append(getCellRef(j, i));
    }
  }
  candidates.shuffle();
}

void collapseCell(int[][] g, int x, int y, int k) {
  g[y][x] = k;
  collapseRow(g, x - 1, y + 0, -1,  0, k);
  collapseRow(g, x + 1, y + 0,  1,  0, k);
  collapseRow(g, x + 0, y - 1,  0, -1, k);
  collapseRow(g, x + 0, y + 1,  0,  1, k);
}

void collapseRow(int[][] g, int x, int y, int dx, int dy, int k) {
  if(x >= 0 && x < grid[0].length && y >= 0 && y < grid.length) {
    g[y][x] &= ~k;
    collapseRow(g, x + dx, y + dy, dx, dy, k);
  }
}

int getBestCellRef(IntList l) {
  int result = 0;
  
  if (l.size() > 1) {
    int m = countBits(l.get(0), 9);
    for(int i = 1; i < l.size(); i++) {
      final int v = countBits(l.get(i), 9);
      if (v < m) {
        result = i;
        m = v;
      }
    }
  }
  
  return l.remove(result);
}

int countBits(int v, int s) {
  int count = 0;
  for (int i = 0; i < s; i++) {
    if ((v & (1 << i)) > 0) {
      count++;
    }
  }
  return count;
}

int randomBits(int v, int s) {
  IntList numbers = new IntList();
  for (int i = 0; i < s; i++) {
    if ((v & (1 << i)) > 0) {
      numbers.append(i);
    }
  }
  numbers.shuffle();
  return 1 << numbers.get(0);
}

int getCellRef(int x, int y) {
  return y * grid[y].length + x;
}

int getXFromCellRef(int cellRef) {
  return cellRef % grid[0].length;
}

int getYFromCellRef(int cellRef) {
  return cellRef / grid[0].length;
}
