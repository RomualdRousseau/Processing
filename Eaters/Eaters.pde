final int BOUNDARY = 20;
final int CREATURE_COUNT = 1;
final int FOOD_COUNT = 20;
final int POISON_COUNT = 20;
final float MAX_FORCE = 10.0;
final float MAX_SPEED = 10.0;
final float MAX_MASS = 20.0;
final float VISIBILITY_RADIUS = 200.0;
final float LEARNING_REATE = 0.1;
final float DISCOUNTING_RATE = 0.9;
final float GREEDY_RATE = 1.0;
final float REPRO_RATE = 10000.0;
final float MUTATION_RATE = 0.001;
final float MUTATION_SCALE = 500.0;
final float HEALTH_DECAY = 0.005;
final float KILL_POINT = -0.4;
final float EAT_POINT = 0.4;
final float DIE_POINT = -0.2;
final float AGE_RATE = 0.1;

ArrayList<Creature> creatures = new ArrayList<Creature>();
ArrayList<Food> food = new ArrayList<Food>();
ArrayList<Poison> poison = new ArrayList<Poison>();
float epoch = 0.0;
float lifeSpan = 0.0;

void setup() {
  size(800, 400, P2D);
  
  for(int i = 0; i < CREATURE_COUNT; i++) {
    creatures.add(new Creature());
  }
  
  for(int i = 0; i < FOOD_COUNT; i++) {
    food.add(new Food(random(BOUNDARY * 2, width - BOUNDARY * 2), random(BOUNDARY * 2, height - BOUNDARY * 2)));
  }
  
  for(int i = 0; i < POISON_COUNT; i++) {
    poison.add(new Poison(random(BOUNDARY * 2, width - BOUNDARY * 2), random(BOUNDARY * 2, height - BOUNDARY * 2)));
  }
}

void draw() {
  background(255);
  
  for(Food one: food) {
    one.draw();
  }
  
  for(Poison one: poison) {
    one.draw();
  }
  
  for(int i = creatures.size() - 1; i >= 0; i--) {
    Creature one = creatures.get(i);
    one.think(food, poison);
    one.update();
    one.draw();
  }
  
  fill(0);
  textSize(12);
  text("Epoch: " + (epoch * 1000) + " years", 0, 16);
  text("Life Span: " + lifeSpan + " years", 0, 32);
  text("Population: " + creatures.size() + " creatures", 0, 48);
  
  if(creatures.size() == 0) {
    textSize(16);
    text("Life is no more", (width - textWidth("Life is not anymore")) * 0.5, height * 0.5);
  }
  else {
    epoch += AGE_RATE;
  }
}

void keyPressed() {
  if(key  == 'd' || key == 'D') {
    for(int i = food.size() - 1; i >= 0; i--) {
      food.remove(i);
    }
  }
  if(key  == 'f' || key == 'F') {
    for(int i = 0; i < FOOD_COUNT; i++) {
      food.add(new Food(random(BOUNDARY * 2, width - BOUNDARY * 2), random(BOUNDARY * 2, height - BOUNDARY * 2)));
    }
  }
}
