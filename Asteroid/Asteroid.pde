Ship ship;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Rock> rocks = new ArrayList<Rock>();
int score = 0;

void newBoard() {
  for (int i = 0; i < 10; i++) {
    rocks.add(new Rock());
  }
  ship.spwaning = 500;
}

void setup() {
  size(800, 800);
  stroke(255);
  noFill();
  textSize(32);

  ship = new Ship();
  newBoard();
}

void draw() {
  if (rocks.size() == 0) {
    newBoard();
  }

  if (ship != null) {
    ship.controlPlayer();
    ship.friction();
    ship.update();
    ship.limits();
    ship.hitRocks();
    if (ship.life == 0) {
      ship = null;
    }
  }

  for (int i =  bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.limits();
    b.decreaseEnergy();
    b.hitRocks();
  }

  for (int i = 0; i < rocks.size(); i++) {
    Rock r = rocks.get(i);
    r.update();
    r.limits();
    r.collideRocks();
  }


  background(51);

  if (ship != null) {
    ship.show();
  }

  for (int i = 0; i < bullets.size(); i++) {
    bullets.get(i).show();
  }

  for (int i = 0; i < rocks.size(); i++) {
    rocks.get(i).show();
  }

  textAlign(LEFT);
  text(score, 50, 32);
  if (ship != null) {
    for (int i = 0; i < ship.life; i++) {
      text("A", 50 + i * 32, 64);
    }
  } else {
    textAlign(CENTER);
    text("Game Over", width / 2, height / 2);
  }
}

void keyPressed() {
  mapKeys(true);
}

void keyReleased() {
  mapKeys(false);
}
