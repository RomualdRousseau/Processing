import org.spritesheet.*;

SpriteSheetLibrary spriteSheetLibrary = new SpriteSheetLibrary(this);
float dt = 0.0;

Entity hero;
SpriteAnimation heroSprite;

PVector target;
SpriteAnimation targetSprite;

PVector obstacle1;
SpriteAnimation obstacleSprite1;
PVector obstacle2;
SpriteAnimation obstacleSprite2;
PVector obstacle3;
SpriteAnimation obstacleSprite3;

void setup() {
  size(400, 400);
  noSmooth();
  imageMode(CENTER);

  SpriteSheet sp = spriteSheetLibrary.loadSpriteSheet("Cow.png", 16, 16);
  hero = new Entity(200, 200);
  heroSprite = sp.getAnimation(0, 2, 10 * 60 / 60);

  sp = spriteSheetLibrary.loadSpriteSheet("PowerUp.png", 16, 16);
  target = new PVector(200, 200);
  targetSprite = sp.getAnimation(0, 8, 5 * 60 / 60);

  sp = spriteSheetLibrary.loadSpriteSheet("Slimes.png", 16, 16);
  obstacle1 = new PVector(100, 100);
  obstacleSprite1 = sp.getAnimation(0, 2, 10 * 60 / 60);
  obstacle2 = new PVector(300, 300);
  obstacleSprite2 = sp.getAnimation(0, 2, 10 * 60 / 60);
  obstacle3 = new PVector(100, 300);
  obstacleSprite3 = sp.getAnimation(0, 2, 10 * 60 / 60);
}

void draw() {
  dt = 1.0 / frameRate;

  background(0, 192, 0);

  if (!obstacleSprite1.play(obstacle1.x, obstacle1.y, 64, 64)) {
    obstacleSprite1.rewind();
    obstacleSprite1.play(obstacle1.x, obstacle1.y, 64, 64);
  }
  
  if (!obstacleSprite2.play(obstacle2.x, obstacle2.y, 64, 64)) {
    obstacleSprite2.rewind();
    obstacleSprite2.play(obstacle2.x, obstacle2.y, 64, 64);
  }
  
  if (!obstacleSprite3.play(obstacle3.x, obstacle3.y, 64, 64)) {
    obstacleSprite3.rewind();
    obstacleSprite3.play(obstacle3.x, obstacle3.y, 64, 64);
  }
  
  if (!heroSprite.play(hero.position.x, hero.position.y, 64, 64)) {
    heroSprite.rewind();
    heroSprite.play(hero.position.x, hero.position.y, 64, 64);
  }
  
  if (!targetSprite.play(target.x, target.y, 64, 64)) {
    targetSprite.rewind();
    targetSprite.play(target.x, target.y, 64, 64);
  }

  hero.applyForce(hero.seek(target, 150, 1000));
  hero.applyForce(hero.avoid(obstacle1, 64, 2000, 100));
  hero.applyForce(hero.avoid(obstacle2, 64, 2000, 100));
  hero.applyForce(hero.avoid(obstacle3, 64, 2000, 100));
  hero.update();
}

void mouseDragged() {
  target = new PVector(mouseX, mouseY);
}
