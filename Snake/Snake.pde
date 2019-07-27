static final int GRID_SIZE = 20;

Snakey snakey = new Snakey();
Food food = new Food();

void setup() {
  size(400, 400);
  frameRate(10);
}

void draw() {
  snakey.update();
  if (snakey.eat(food)) {
    snakey.grow();
    food = new Food();
  } else if (snakey.eatItself()) {
    print("GAME OVER");
    noLoop();
  }

  background(51);
  food.show();
  snakey.show();
}

void keyPressed() {
  if (key == 'w') {
    snakey.move(0, -1);
  } else if (key == 's') {
    snakey.move(0, 1);
  } else if (key == 'a') {
    snakey.move(-1, 0);
  } else if (key == 'd') {
    snakey.move(1, 0);
  }
}
