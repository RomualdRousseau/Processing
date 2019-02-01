import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.function.Function; 
import java.util.Comparator; 
import java.util.Collections; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class FlappyBird extends PApplet {

/**
 * Flappy Bird with Melody design for my baby valentine day.
 *
 * Inspired by the Coding Train Challenge from the Nature of Code, chapter Neuro Evolution.
 * Special thanks to XXXX. Keep up this excellent YouTube Channel.
 *
 * Usage:
 *  - Hit the spacebar to fly the bird. 
 *  - Move the mouse on the bottom to access different options; demo/play mode, train, save the best bird, audio on/off.
 *  - In demo mode, the AI use the "data/melody.json" file as the brain for the bird. If it doesnt exist, the training mode starts (200 birds with neuro evolution).
 *  - Maximum scoe is 214... Valentine Day ;)
 *
 * Enhancements:
 *  - Relative features extraction as the NN input => independance to the resolution
 *  - Tanh and linear activation functions for the NN
 *  - Added a bonus to the genetic fitness if the bird flies arounf the center of the pillars
 *  - Added mass and time integral in the physic equations
 *  - Playable option
 *  - Added different behaviors to tell a story of my baby and cute GFX ;)
 *
 * Disclaimer and fair use:
 * I don't own any rights for the usage of Melody and Cinamon characters. As such this images are not for redistribution.
 * If you intend to use or to modify this , please replace the images by your own set.
 *
 * Author: Romuald Rousseau
 * Date: 2019-01-31
 * Processing 3+ with Sound library
 */
public void setup() {
  frameTime = 1.0f / frameRate; // Time calibration constant for the physic calculation

  
  
  Resources.loadAll(this);
  UI.pack();
  Game.startup(true);
}

public void draw() {
  Game.mainloop();
  Game.render();
  if(mouseY > height - 80) {
    UI.render();
  }
}

public void mouseReleased() {
  UI.mouseReleased();
}

public void mouseDragged() {
  UI.mouseDragged();
}
class Bird extends Entity {
  GeneticNeuralNetwork brain;
  ArrayList<Particle> smoke = new ArrayList<Particle>();
  float altitude = 0;
  
  Bird() {
    super();
    
    this.brain = new GeneticNeuralNetwork();
    brain.layer1 = new Layer(
    /* inputUnits */ 5, 
    /* units */      8, 
    /* activation */ new TanhActivationFunction());
    brain.layer2 = new Layer(
    /* inputUnits */ brain.layer1.getOutputUnits(), 
    /* units */      2, 
    /* activation */ new LinearActivationFunction());
    brain.compile(
    /* shuffle */    true,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(width / 4, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }
  
  Bird(JSONObject jsonBrain) {
    super();
    
    this.brain = new GeneticNeuralNetwork(jsonBrain);
    brain.layer1.activation = new TanhActivationFunction();
    brain.layer2.activation = new LinearActivationFunction();
    brain.compile(
    /* shuffle */    false,
    /* optimizer */  new OptimizerGenetic(MUTATION_VARIANCE, MUTATION_RATE));

    this.position = new PVector(width / 4, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  Bird(Bird parent) {
    super();
    
    this.brain = parent.brain.clone();
    this.brain.mutate();

    this.position = new PVector(width / 4, floor(random(BIRD_MASS, height - BIRD_MASS)));
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  public boolean isOffscreen() {
    return this.position.y < BIRD_MASS / 2 - 1;
  }

  public boolean hit() {
    Pillar closest = this.lookat();
    if (closest == null) {
      return false;
    }
    
    float r = BIRD_MASS / 4; // Roughly the hit box, somehow generous. hey! I want meet my baby
    float d = closest.bottom.x - this.position.x; // Negative is important here because the position of the pillar is relative to the center of the bird
    
    if(d < r && d > -(PILLAR_SIZE + r)) {
      if(this.position.y < closest.bottom.y + r || this.position.y > (closest.top.y - r)) {
        return true;
      } else {
        altitude = 0.9f * altitude + 0.1f * abs(this.position.y - closest.bottom.y);
        return false;
      }
    } else {
      return false;
    }
  }

  public boolean think() {
    if (mode == GameMode.INTERACTIVE) {
      return keyPressed && key == ' ';
    }
      
    Pillar closest = this.lookat();
    if (closest == null) {
      return false;
    }
    
    Matrix input = new Matrix(new float[] {
      this.position.y / height, 
      this.velocity.y / BIRD_MAX_SPEED, 
      (closest.top.x - this.position.x) / width, 
      (closest.top.y - this.position.y) / height, 
      (closest.bottom.y - this.position.y) / height
      });
    Matrix output = this.brain.predict(input);
    
    return output.data[0][0] > output.data[1][0];
  }

  public void meet(Entity entity) {
    if(entity != null) {
      PVector target = new PVector(-TROPHEE_SIZE / 2, 0).add(entity.position.copy());
      PVector force = target.sub(this.position);
      force.add(this.velocity.copy().mult(-DRAG_COEF)); // Friction
      this.acceleration.add(force.div(BIRD_MASS));
    }
  }

  public void fly() {
    PVector force = new PVector(0, BIRD_FLY_FORCE);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  public void gravity() {
    PVector force = new PVector(0, G * BIRD_MASS);
    this.acceleration.add(force.div(BIRD_MASS));
  }

  public void limit() {
    if (this.position.y >= height - BIRD_MASS / 2) {
      PVector force = new PVector(0, -this.velocity.mag() * 0.5f);
      this.acceleration.mult(0.0f).add(force);
    }
  }
  
  public void constrainToScreen() {
    this.velocity.y = constrain(this.velocity.y, -BIRD_MAX_SPEED, BIRD_MAX_SPEED);
    this.position.y = constrain(this.position.y, BIRD_MASS / 2, height - BIRD_MASS / 2);
  }
  
  public Pillar lookat() {
    Pillar closest = null;
    for(int i = 0; i < pillars.size(); i++) {
      float d = pillars.get(i).bottom.x - this.position.x;
      if (d >= -(PILLAR_SIZE + BIRD_MASS / 4)) {
        closest = pillars.get(i);
        break;
      }
    }
    return closest;
  }
  
  public void emitSmoke() {
    if (this.smoke.size() < 5 && this.velocity.heading() > radians(45)) {
      this.smoke.add(new Particle(this));
    }
    for (int i = smoke.size() - 1; i >= 0; i--) {
      Particle particle = smoke.get(i);
      particle.update();
      if (particle.life > 50) {
        particle.kill();
        smoke.remove(particle);
      }
    }
  }

  public void render() {
    imageMode(CENTER);
    pushMatrix();
    translate(this.position.x, mapToScreenY(this.position.y));
    rotate(-constrain(this.velocity.heading(), radians(0), radians(45)));
    image(BIRD_SPRITE, 0, 0, BIRD_MASS, BIRD_MASS);
    popMatrix();
    
    if (!this.alive) {
      int frame = floor(frameCount * frameRate / 500.0f) % 4;
      if (frame == 0) {
        image(STAR_SPRITE, this.position.x + 32, mapToScreenY(this.position.y + 32), 32, 32);
      }
      if (frame == 1) {
        image(STAR_SPRITE, this.position.x + 16, mapToScreenY(this.position.y - 16), 48, 48);
      }
      if (frame == 2) {
        image(STAR_SPRITE, this.position.x - 16, mapToScreenY(this.position.y - 16), 64, 64);
      }
      if (frame == 3) {
        image(STAR_SPRITE, this.position.x - 32, mapToScreenY(this.position.y + 32), 48, 48);
      }
    } else {
      for (int i = 0; i < smoke.size(); i++) {
        Particle particle = smoke.get(i);
        particle.render();
      }
    }
    
    if (DEBUG) {
      fill(255, 128);
      strokeWeight(2);
      stroke(255, 0, 0);
      ellipse(this.position.x, mapToScreenY(this.position.y), BIRD_MASS / 2, BIRD_MASS / 2);
      stroke(0, 255, 0);
      ellipse(this.position.x, mapToScreenY(this.position.y), BIRD_MASS, BIRD_MASS);
    }
  }
}
abstract class Entity {
  PVector position;
  PVector velocity;
  PVector acceleration;
  int life;
  boolean alive;
  
  Entity() {
    this.alive = true;
    this.life = 0;
  }
  
  public void kill() {
    this.alive = false;
  }
  
  public void stop() {
    this.acceleration.mult(0);
    this.velocity.mult(0);
  }
  
  public void update() {
    this.velocity.add(this.acceleration.copy().mult(frameTime));
    this.position.add(this.velocity.copy().mult(frameTime));
    this.acceleration.mult(0);
    this.life++;
  }
  
  public abstract void render();
}
class Friend extends Entity {
  Friend() {
    super();
    this.position = new PVector(3 * width / 4, height / 2);
    this.velocity = new PVector(0.0f, 0.0f);
    this.acceleration = new PVector(0.0f, 0.0f);
  }
  
  public void meet(Entity entity) {
    PVector target = null;
    if(entity != null) {
      target = new PVector(TROPHEE_SIZE / 2, 0).add(entity.position);
    } else if (pillars.size() > 0) {
      Pillar farest = pillars.get(pillars.size() - 1);
      target = new PVector(PILLAR_SIZE / 2, PILLAR_SPACING / 2).add(farest.bottom);
    }
    if(target != null) {
      PVector force = target.sub(this.position);
      force.add(this.velocity.copy().mult(-DRAG_COEF)); // Friction
      this.acceleration.add(force.div(FRIEND_MASS));
    }
  }
  
  public void constrainToScreen() {
    this.position.y = constrain(this.position.y, FRIEND_MASS / 2, height - FRIEND_MASS / 2);
  }
  
  public void render() {
    imageMode(CENTER);
    image(BONUS_SPRITE, this.position.x, mapToScreenY(this.position.y), FRIEND_MASS, FRIEND_MASS);
    
    if (DEBUG) {
      fill(255, 128);
      strokeWeight(2);
      stroke(0, 255, 0);
      ellipse(this.position.x, mapToScreenY(this.position.y), FRIEND_MASS, FRIEND_MASS);
    }
  }
}
class Game_ {
  long frameCounter;
  GameState state;
  int score;
  int pillarInterval;
  int pillarCount;

  public void startup(boolean firstRun) {
    this.state = GameState.INIT;
    this.score = 0;
    this.frameCounter = 0;
    this.pillarInterval = floor(PILLAR_INTERVAL / (3.0f * frameTime));
    this.pillarCount = 0;
    
    landscape = new Landscape();
    friend = new Friend();
    trophee = null;
    pillars = new ArrayList<Pillar>();
    
    birds = new ArrayList<Bird>();
    if (mode == GameMode.DEMO) {
      if (fileExistsInData("melody.json")) {
        JSONObject jsonBrain = loadJSONObject(dataPath("melody.json"));
        birds.add(new Bird(jsonBrain));
      } else if (firstRun) {
        for (int i = 0; i < BIRDS_COUNT; i++) {
          birds.add(new Bird());
        }
      } else {
        Genetic.calculateFitness();
        Genetic.samplePool();
        Genetic.normalizePool();
        for (int i = 0; i < BIRDS_COUNT; i++) {
          birds.add(new Bird(Genetic.selectParent()));
        }
      }
      Genetic.newPool();
    } else {
      if (fileExistsInData("melody.json")) {
        JSONObject jsonBrain = loadJSONObject("melody.json");
        birds.add(new Bird(jsonBrain));
      } else {
        birds.add(new Bird());
      }
    }
  }
  
  public void mainloop() {
    for (int i = 0; i < cycles * SIMULATION_STEPS; i++) {
      this.runOnce();
    }
  }
  
  public void runOnce() {
    landscape.update();
    
    switch(state) {
    case INIT:
      if (isSpaceBarPressed(GameMode.INTERACTIVE)) {
        this.state = GameState.MAINLOOP;
      }
      break;
  
    case MAINLOOP:
      if(this.score >= MAX_SCORE) {
        landscape.stop();
        pillars = new ArrayList<Pillar>();
        trophee = new Trophee();
        this.state = GameState.GAMEWIN;
      } else {
        this.spawnNewPillar();

        friend.meet(null);
        friend.update();
        friend.constrainToScreen();
        
        for (int i = pillars.size() - 1; i >= 0; i--) {
          Pillar pillar = pillars.get(i);
          pillar.update();
          if(pillar.isOffView()) {
            if(isAudioPlayable()) {
              POINT_SOUND.play();
            }
            this.score++;
          }
          if (pillar.isOffscreen()) {
            pillars.remove(pillar);
          }
        }
    
        for (int i = birds.size() - 1; i >= 0; i--) {
          Bird bird = birds.get(i);
          if (bird.think()) {
            bird.fly();
          }
          bird.limit();
          bird.gravity();
          bird.update();
          if (bird.isOffscreen() || bird.hit()) {
            if(isAudioPlayable()) {
              CRASH_SOUND.play();
            }
            bird.kill();
            if (mode == GameMode.DEMO) {
              Genetic.pool.add(bird);
              birds.remove(bird);
              if (birds.size() == 0) {
                this.state = GameState.GAMEOVER;
              }
            } else {
              this.state = GameState.GAMEOVER;
            }
          }
          bird.constrainToScreen();
          bird.emitSmoke();
        }
      }
      break;
  
    case GAMEOVER:
      if (isSpaceBarPressed(GameMode.INTERACTIVE)) {
        this.startup(false);
      }
      
      for (int i = birds.size() - 1; i >= 0; i--) {
        Bird bird = birds.get(i);
        bird.gravity();
        bird.limit();
        bird.update();
        bird.constrainToScreen();
      }
      break;
      
    case GAMEWIN:
      if (isSpaceBarPressed(GameMode.ALL)) {
        this.startup(false);
      }
      
      friend.meet(trophee);
      friend.update();
      friend.constrainToScreen();
      
      for (int i = birds.size() - 1; i >= 0; i--) {
        Bird bird = birds.get(i);
        bird.meet(trophee);
        bird.update();
        bird.constrainToScreen();
        bird.emitSmoke();
      }
      break;
    }
  }
  
  public void render() {
    landscape.render();
    
    if(trophee != null) {
      trophee.render();
    }
  
    friend.render();  
   
    for (int i = 0; i < pillars.size(); i++) {
      Pillar pillar = pillars.get(i);
      pillar.render();
    }
  
    for (int i = 0; i < birds.size(); i++) {
      Bird bird = birds.get(i);
      bird.render();
    }
  
    if (this.state == GameState.INIT) {
      fadeScreen();
      continueText("HIT SPACEBAR TO START");
    } else if (this.state == GameState.GAMEOVER) {
      fadeScreen();
      centeredText("GAME OVER");
      continueText("HIT SPACEBAR TO START");
    } else if (this.state == GameState.GAMEWIN) {
      continueText("HIT SPACEBAR TO START");
    }
    
    scoreText(String.format("%d", this.score));
  }
  
  public void spawnNewPillar() {
    if ((this.frameCounter % this.pillarInterval) == 0 && this.pillarCount < MAX_SCORE) {
      pillars.add(new Pillar());
      this.pillarCount++;
    }
    this.frameCounter++;
  }
  
  public boolean isAudioPlayable() {
    return audioEnabled && birds.size() < 2 && cycles < 6;
  }
}
Game_ Game = new Game_();
class Genetic_ {
  ArrayList<Bird> pool;
  
  public void newPool() {
    this.pool = new ArrayList<Bird>();
  }
  
  public void calculateFitness() {
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      float b = 1.0f / (1.0f + abs(bird.altitude - PILLAR_SPACING / 2));
      bird.brain.fitness = bird.life * (0.95f + 0.05f * b); // Give a 5% bonus if the bird flies around the center of the pillars
    }
  }
  
  public void samplePool() {
    this.samplePool(floor(random(1.0f) * this.pool.size()));
  }
  
  public void samplePool(int sampleCount) {
    Collections.sort(this.pool, Collections.reverseOrder(new Comparator<Bird>() {
      public int compare(Bird a, Bird b) {
        float d = a.brain.fitness - b.brain.fitness;
        return (d < 0) ? -1 : ((d > 0) ? 1 : 0);
      }
    }
    ));
    
    if(this.pool.size() > sampleCount) {
      for (int i = this.pool.size() - 1; i >= sampleCount; i--) {
        this.pool.remove(i);
      }
    }
  }
  
  public void normalizePool() {
    float sum = 0;
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      sum += bird.brain.fitness;
    }
    
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      bird.brain.fitness /= sum;
    }
  }

  public Bird selectParent() {
    float r = random(1.0f);
  
    Bird bestBird = null;
    int bestBirdIndex= 0;
    while (r > 0) {
      r -= pool.get(bestBirdIndex).brain.fitness;
      bestBirdIndex++;
    }
    bestBirdIndex--;
    bestBird = pool.get(bestBirdIndex);
    
    return bestBird;
  }
}
Genetic_ Genetic = new Genetic_();





enum GameState {
  INIT, 
  MAINLOOP, 
  GAMEOVER,
  GAMEWIN
};

enum GameMode {
  INTERACTIVE, 
  DEMO,
  ALL
};

static final boolean DEBUG = false;
static final int MAX_SCORE = 214;
static final float G = -9.81f;
static final float DRAG_COEF = 10;
static final float MUTATION_RATE = 0.1f;
static final float MUTATION_VARIANCE = 0.1f;
static final int SIMULATION_STEPS = 10;
static final int BIRDS_COUNT = 100;
static final float BIRD_MASS = 100;
static final float BIRD_FLY_FORCE = 6000;
static final float BIRD_MAX_SPEED = 200;
static final float PILLAR_SPACING = 200;
static final float PILLAR_SIZE = 80;
static final float PILLAR_SCROLLING_SPEED = -20;
static final float PILLAR_INTERVAL = 50.0f; // Main factor of difficulty; the smaller, the closer are the pillars! 
static final float CITY_SIZE = 400;
static final float CITY_SCROLLING_SPEED = -10;
static final float FRIEND_MASS = 150;
static final float TROPHEE_SIZE = 250;

static PImage CITY_SPRITE;
static PImage BIRD_SPRITE;
static PImage PILLAR_SPRITE;
static PImage STAR_SPRITE;
static PImage BONUS_SPRITE;
static PImage TROPHEE_SPRITE;

static SoundFile POINT_SOUND;
static SoundFile CRASH_SOUND;

static GameMode mode = GameMode.DEMO;
static float frameTime = 0.016668f; // 1.0 / frameRate if frameRate = 60 fps
static int cycles = 1;
static boolean audioEnabled = true;

static Landscape landscape;
static Friend friend;
static ArrayList<Bird> birds;
static ArrayList<Pillar> pillars;
static Trophee trophee;
class Landscape {
  float[] x;
  float[] y;
  float[] v;

  /* A bit crude parallax scrolling implementation
   */
  public Landscape() {
    this.x = new float[ceil(width / CITY_SIZE) + 1];
    this.y = new float[ceil(width / CITY_SIZE) + 1];
    this.v = new float[ceil(width / CITY_SIZE) + 1];

    for (int i = 0; i < x.length; i++) {
      this.x[i] = i * CITY_SIZE;
      this.y[i] = height - CITY_SIZE;
      this.v[i] = CITY_SCROLLING_SPEED;
    }
  }
  
  public void stop() {
    for (int i = 0; i < x.length; i++) {
      this.v[i] = 0;
    }
  }

  public void update() {
    for (int i = 0; i < x.length; i++) {
      this.x[i] += this.v[i] * frameTime;
      if (this.x[i] < -CITY_SIZE) {
        this.x[i] = width;
      }
    }
  }

  public void render() {
    background(0, 128, 255);
    imageMode(CORNER);
    for (int i = 0; i < x.length; i++) {
      image(CITY_SPRITE, this.x[i], this.y[i], CITY_SIZE + 1, CITY_SIZE); // CITY_SIZE + 1 trick ensures seamless tiles 
    }
  }
}
class Matrix {
  int rows;
  int cols;
  float[][] data;

  public Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.data = new float[this.rows][this.cols];
    this.reset();
  }

  public Matrix(float[] v) {
    this.rows = v.length;
    this.cols = 1;
    this.data = new float[this.rows][this.cols];
    for (int i = 0; i < this.rows; i++) {
      this.data[i][0] = v[i];
    }
  }
  
  public Matrix(JSONObject json) {
    this.rows = json.getInt("rows");
    this.cols = json.getInt("cols");
    this.data = new float[this.rows][this.cols];
    JSONArray jsonData = json.getJSONArray("data");
    for (int i = 0; i < this.rows; i++) {
      JSONArray jsonRow = jsonData.getJSONArray(i);
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = jsonRow.getFloat(j);
      }
    }
  }

  public void reset() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = 0.0f;
      }
    }
  }

  public Matrix mutate(float rate, float variance) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        if (random(1.0f) < rate) {
          this.data[i][j] += randomGaussian() * variance;
        }
      }
    }
    return this;
  }

  public void randomize() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = random(-1.0f, 1.0f);
      }
    }
  }

  public void randomize(int n) {
    float a = 1.0f / sqrt(n);
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = random(-a, a);
      }
    }
  }

  public Matrix add(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] += m.data[i][j];
      }
    }
    return this;
  }

  public Matrix sub(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] -= m.data[i][j];
      }
    }
    return this;
  }

  public Matrix mult(float n) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] *= n;
      }
    }
    return this;
  }

  public Matrix mult(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] *= m.data[i][j];
      }
    }
    return this;
  }

  public Matrix map(Function<Float, Float> fn) {
    if (fn == null) {
      throw new IllegalArgumentException("function is not defined");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = fn.apply(this.data[i][j]);
      }
    }
    return this;
  }

  public Matrix copy() {
    Matrix result = new Matrix(this.rows, this.cols);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[i][j];
      }
    }
    return result;
  }

  public Matrix transpose() {
    Matrix result = new Matrix(this.cols, this.rows);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[j][i];
      }
    }
    return result;
  }

  public Matrix transform(Matrix m) {
    if (this.cols != m.rows) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    Matrix result = new Matrix(this.rows, m.cols);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        float sum = 0.0f;
        for (int k = 0; k < this.cols; k++) {
          sum += this.data[i][k] * m.data[k][j];
        }
        result.data[i][j] = sum;
      }
    }
    return result;
  }
  
  public JSONObject toJSON() {
    JSONArray jsonData = new JSONArray();
    for (int i = 0; i < this.rows; i++) {
      JSONArray jsonRow = new JSONArray();
      for (int j = 0; j < this.cols; j++) {
        jsonRow.setFloat(j, this.data[i][j]);
      }
      jsonData.setJSONArray(i, jsonRow);
    }
    JSONObject json = new JSONObject();
    json.setInt("rows", this.rows);
    json.setInt("cols", this.cols);
    json.setJSONArray("data", jsonData);
    return json;
  }

  public void print() {
    for (int i  = 0; i < this.rows; i++) {
      println(this.data[i]);
    }
  }
}
abstract class NeuralNetwork {
  Layer layer1;
  Layer layer2;
  Optimizer optimizer;
  LearningRateScheduler learningRateScheduler;
  float epochs;

  public NeuralNetwork() {
    this.layer1 = null;
    this.layer2 = null;
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = 0.0f;
  }
  
  public NeuralNetwork(JSONObject json) {
    this.layer1 = new Layer(json.getJSONObject("layer1"));
    this.layer2 = new Layer(json.getJSONObject("layer2"));
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = json.getFloat("epochs");
  }
  
  public abstract NeuralNetwork clone();

  public void reset() {
    this.layer1.reset();
    this.layer2.reset();
    this.epochs = 0.0f;
  }

  public Matrix predict(Matrix input) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);
    return output;
  }
  
  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setJSONObject("layer1", this.layer1.toJSON());
    json.setJSONObject("layer2", this.layer2.toJSON());
    json.setFloat("epochs", this.epochs);
    return json;
  }
}

class SequentialNeuralNetwork extends NeuralNetwork {
  LossFunction loss;
  
  public SequentialNeuralNetwork() {
    super();
    this.loss = null;
  }
  
  public SequentialNeuralNetwork(JSONObject json) {
    super(json);
    this.loss = null;
  }

  private SequentialNeuralNetwork(SequentialNeuralNetwork parent) {
    this.layer1 = parent.layer1.clone();
    this.layer2 = parent.layer2.clone();
    this.loss = parent.loss;
    this.optimizer = parent.optimizer;
    this.learningRateScheduler = parent.learningRateScheduler;
    this.epochs = 0.0f;
  }

  public NeuralNetwork clone() {
    return new SequentialNeuralNetwork(this);
  }
  
  public void compile(boolean shuffle, LossFunction loss, Optimizer optimizer) {
    this.compile(shuffle, loss, optimizer, null);
  }

  public void compile(boolean shuffle, LossFunction loss, Optimizer optimizer, LearningRateScheduler learningRateScheduler) {
    this.loss = loss;
    this.optimizer = optimizer;
    this.learningRateScheduler = learningRateScheduler;
    if(shuffle) {
      this.reset();
    }
  }

  public void fit(Matrix[] inputs, Matrix[] targets, int epochs, int batchSize, boolean shuffle) {
    for (int e = 0; e < epochs; e++) {
      for (int b = 0; b < batchSize; b++) {
        for (int t = 0; t < inputs.length; t++) {
          int i = (shuffle) ? floor(random(inputs.length)) : t;
          this.fitOne(inputs[i], targets[i]);
        }
      }

      this.epochs += 1.0f;

      if (this.learningRateScheduler != null) {
        this.learningRateScheduler.adapt(this.optimizer, this.epochs);
      }
    }
  }

  public void fitOne(Matrix input, Matrix target) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);

    Matrix loss = this.loss.apply(output, target);
    this.optimizer.optimize(this.layer2, hidden, output, loss);

    loss = this.layer2.feedBackLoss(loss);
    this.optimizer.optimize(this.layer1, input, hidden, loss);
  }
}

class GeneticNeuralNetwork extends NeuralNetwork {
  float fitness;

  public GeneticNeuralNetwork() {
    super();
    this.fitness = 0.0f;
  }
  
  public GeneticNeuralNetwork(JSONObject json) {
    super(json);
    this.fitness = json.getFloat("fitness");
  }

  private GeneticNeuralNetwork(GeneticNeuralNetwork parent) {
    this.layer1 = parent.layer1.clone();
    this.layer2 = parent.layer2.clone();
    this.optimizer = parent.optimizer;
    this.learningRateScheduler = parent.learningRateScheduler;
    this.epochs = 0.0f;
    this.fitness = 0.0f;
  }

  public GeneticNeuralNetwork clone() {
    return new GeneticNeuralNetwork(this);
  }
  
  public void reset() {
    super.reset();
    this.fitness = 0.0f;
  }
  
  public void compile(boolean shuffle, Optimizer optimizer) {
    this.compile(shuffle, optimizer, null);
  }

  public void compile(boolean shuffle, Optimizer optimizer, LearningRateScheduler learningRateScheduler) {
    this.optimizer = optimizer;
    this.learningRateScheduler = learningRateScheduler;
    if(shuffle) {
      this.reset();
    }
  }

  public void mutate() {
    this.optimizer.optimize(this.layer1, null, null, null);
    this.optimizer.optimize(this.layer2, null, null, null);

    this.epochs += 1.0f;

    if (this.learningRateScheduler != null) {
      this.learningRateScheduler.adapt(this.optimizer, this.epochs);
    }
  }

  public JSONObject toJSON() {
    JSONObject json = super.toJSON();
    json.setFloat("fitness", this.fitness);
    return json;
  }
}

class Layer {
  Matrix weights;
  Matrix gradients;
  Matrix bias;
  ActivationFunction activation;

  public Layer(int inputUnits, int units) {
    this(inputUnits, units, new LinearActivationFunction());
  }

  public Layer(int inputUnits, int units, ActivationFunction activation) {
    this.weights = new Matrix(units, inputUnits);
    this.gradients = new Matrix(units, 1);
    this.bias = new Matrix(units, 1);
    this.activation = activation;
  }
  
  public Layer(JSONObject json) {
    this(json, new LinearActivationFunction());
  }
  
  public Layer(JSONObject json, ActivationFunction activation) {
    this.weights = new Matrix(json.getJSONObject("weights"));
    this.gradients = new Matrix(json.getJSONObject("gradients"));
    this.bias = new Matrix(json.getJSONObject("bias"));
    this.activation = activation;
  }

  private Layer(Layer parent) {
    this.weights = parent.weights.copy();
    this.gradients = parent.gradients.copy();
    this.bias = parent.bias.copy();
    this.activation = parent.activation;
  }

  public int getInputUnits() {
    return this.weights.cols;
  }

  public int getOutputUnits() {
    return this.weights.rows;
  }

  public void reset() {
    this.weights.randomize(this.weights.rows);
    this.gradients.reset();
    this.bias.randomize(this.bias.rows);
  }

  public Layer clone() {
    return new Layer(this);
  }

  public Matrix feedForward(Matrix input) {
    return this.weights.transform(input).add(this.bias).map(this.activation.apply);
  }

  public Matrix feedBackLoss(Matrix loss) {
    return this.weights.transpose().transform(loss);
  }
  
  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setJSONObject("weights", this.weights.toJSON());
    json.setJSONObject("gradients", this.gradients.toJSON());
    json.setJSONObject("bias", this.bias.toJSON());
    return json;
  }
}

abstract class ActivationFunction {
  Function<Float, Float> apply;
  Function<Float, Float> derivate;
}

class LinearActivationFunction extends ActivationFunction {
  public LinearActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return x;
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return 1.0f;
      }
    };
  }
}

class SigmoidActivationFunction extends ActivationFunction {
  public SigmoidActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return 1.0f / (1.0f + exp(-x));
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return y * (1.0f - y);
      }
    };
  }
}

class TanhActivationFunction extends ActivationFunction {
  public TanhActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return (exp(x) - exp(-x)) / (exp(x) + exp(-x));
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return 1.0f - y * y;
      }
    };
  }
}

class ReluActivationFunction extends ActivationFunction {
  public ReluActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return max(0.0f, x);
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return (y <= 0.0f) ? 0.0f : 1.0f;
      }
    };
  }
}

interface LearningRateScheduler {
  public void adapt(Optimizer optimizer, float epoch);
}

class TimeBasedScheduler implements LearningRateScheduler {
  float decay;

  public TimeBasedScheduler(float decay) {
    this.decay = decay;
  }

  public void adapt(Optimizer optimizer, float epoch) {
    optimizer.learningRate *= 1.0f / (1.0f + this.decay * epoch);
  }
}

class ExponentialScheduler implements LearningRateScheduler {
  float decay;

  public ExponentialScheduler(float decay) {
    this.decay = decay;
  }

  public void adapt(Optimizer optimizer, float epoch) {
    optimizer.learningRate = optimizer.learningRate0 * exp(-this.decay * epoch);
  }
}

interface LossFunction {
  public Matrix apply(Matrix output, Matrix target);
}

class MeanSquaredErrorFunction implements LossFunction {
  public Matrix apply(Matrix output, Matrix target) {
    return target.copy().sub(output);
  }
}

abstract class Optimizer {
  float learningRate0;
  float learningRate;
  float biasRate;

  public Optimizer(float learningRate) {
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    this.biasRate = 1.0f;
  }

  public Optimizer(float learningRate, float biasRate) {
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    this.biasRate = biasRate;
  }

  public abstract void optimize(Layer layer, Matrix input, Matrix output, Matrix error);
}

class OptimizerSgd extends Optimizer {
  public OptimizerSgd(float learningRate) {
    super(learningRate);
  }

  public OptimizerSgd(float learningRate, float biasRate) {
    super(learningRate, biasRate);
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error).mult(this.learningRate);
    Matrix delta = gradient.transform(input.transpose());
    layer.weights.add(delta);
    layer.bias.add(gradient.mult(this.biasRate));
  }
}

class OptimizerMomentum extends Optimizer {
  float momentum;

  public OptimizerMomentum(float learningRate) {
    super(learningRate);
    this.momentum = 0.9f;
  }

  public OptimizerMomentum(float learningRate, float momentum, float biasRate) {
    super(learningRate, biasRate);
    this.momentum = momentum;
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error).mult(this.learningRate);
    layer.gradients.mult(this.momentum).add(gradient.mult(1.0f - this.momentum));
    Matrix delta = layer.gradients.transform(input.transpose());
    layer.weights.add(delta);
    layer.bias.add(layer.gradients.mult(this.biasRate));
  }
}

class OptimizerGenetic extends Optimizer {
  float mutationRate;

  public OptimizerGenetic(float learningRate, float mutationRate) {
    super(learningRate);
    this.mutationRate = mutationRate;
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Function<Float, Float> mutationFunc = new Function<Float, Float>() {
      public final Float apply(Float x) {
        if (random(1.0f) < mutationRate) {
          return x + randomGaussian() * learningRate;
        } else {
          return x;
        }
      }
    };
    layer.weights.map(mutationFunc);
    layer.bias.map(mutationFunc);
  }
}
class Particle extends Entity {
  Particle(Bird bird) {
    super();
    this.position = new PVector(bird.position.x - BIRD_MASS / 4, bird.position.y - 20);
    this.velocity = new PVector(random(-100, -50), random(-50, -10));
    this.acceleration = new PVector(0.0f, 0.0f);
  }

  public void render() {
    fill(255, 192);
    noStroke();
    ellipse(this.position.x, mapToScreenY(this.position.y), 20, 20);
  }
}
class Pillar {
  PVector top;
  PVector bottom;
  boolean alreadyScored;
  
  Pillar() {
    this.bottom = new PVector(width, floor(random(0, height - PILLAR_SPACING)));
    this.top = new PVector(width, this.bottom.y + PILLAR_SPACING);
    this.alreadyScored = false;
  }
  
  public boolean isOffView() {
    if (!this.alreadyScored && birds.size() > 0 && this.bottom.x < birds.get(0).position.x - PILLAR_SIZE) {
      this.alreadyScored = true;
      return true;
    } else {
      return false;
    }
  }
  
  public boolean isOffscreen() {
    return this.bottom.x < -PILLAR_SIZE;
  }

  public void update() {
    this.bottom.x += PILLAR_SCROLLING_SPEED * frameTime;
    this.top.x = this.bottom.x;
  }

  public void render() {
    imageMode(CORNER);
    for (float i = mapToScreenY(this.bottom.y); i < mapToScreenY(0); i += PILLAR_SIZE) {
      image(PILLAR_SPRITE, this.bottom.x, i, PILLAR_SIZE, PILLAR_SIZE);
    }
    for (float i = mapToScreenY(this.top.y); i >= mapToScreenY(height); i -= PILLAR_SIZE) {
      image(PILLAR_SPRITE, this.top.x, i - PILLAR_SIZE, PILLAR_SIZE, PILLAR_SIZE);
    }
    
    if(DEBUG) {
      stroke(255, 0, 0);
      strokeWeight(2);
      if(birds.get(0).lookat() == this) {
        fill(255, 0, 0, 128);
      }
      else {
        fill(255, 128);
      }
      rect(this.bottom.x, mapToScreenY(this.bottom.y), PILLAR_SIZE, this.bottom.y, 7);
      rect(this.bottom.x, mapToScreenY(height), PILLAR_SIZE, height - this.bottom.y - PILLAR_SPACING, 7);
    }
  }
}
class Resources_ {
  public void loadAll(PApplet parent) {
    this.loadFonts();
    this.loadSprites();
    this.loadSounds(parent);
  }
  
  public void loadFonts() {
    textFont(loadFont("NimbusMonoPS-Bold-32.vlw"));
    //textFont(createFont("Broadway", 32));
  }
  
  public void loadSprites() {
    CITY_SPRITE = loadImage("city.png");
    BIRD_SPRITE = loadImage("bird.png");
    PILLAR_SPRITE = loadImage("pillar.png");
    STAR_SPRITE = loadImage("star.png");
    BONUS_SPRITE = loadImage("bonus.png");
    TROPHEE_SPRITE = loadImage("trophee.png");
  }
  
  public void loadSounds(PApplet parent) {
    POINT_SOUND = new SoundFile(parent, "point.wav");
    CRASH_SOUND = new SoundFile(parent, "crash.wav");
  }
}
Resources_ Resources = new Resources_();
class Trophee extends Entity {
  Trophee() {
    super();
    this.position = new PVector(width / 2, height / 2);
    this.velocity = new PVector(0.0f, 0.0f);
    this.acceleration = new PVector(0.0f, 0.0f);
  }
  
  public void render() {
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("HAPPY VALENTINE\n\nMY BABY", width / 2, height / 2 - TROPHEE_SIZE / 2 - 100) ;
    imageMode(CENTER);
    image(TROPHEE_SPRITE, this.position.x, mapToScreenY(this.position.y), TROPHEE_SIZE, TROPHEE_SIZE);
  }
}
class UI_
{
  Slider slider = new Slider(GameMode.ALL);
  Button buttonSwitchMode = new Button("Play", GameMode.ALL);
  Button buttonResetTraining = new Button("Train", GameMode.DEMO);
  Button buttonSaveTheBest = new Button("Save", GameMode.DEMO);
  Button buttonSwitchAudio = new Button("Audio Off", GameMode.ALL);

  public void pack() {
    slider.x = 10;
    slider.y = height - 10;
    slider.size = width - 20;
    
    buttonSwitchMode.x = 10;
    buttonSwitchMode.y = height - 50;
    buttonSwitchMode.size = 100;
    
    buttonResetTraining.x = 120;
    buttonResetTraining.y = height - 50;
    buttonResetTraining.size = 100;
    
    buttonSaveTheBest.x = 230;
    buttonSaveTheBest.y = height - 50;
    buttonSaveTheBest.size = 100;
    
    buttonSwitchAudio.x = 340;
    buttonSwitchAudio.y = height - 50;
    buttonSwitchAudio.size = 100;
  }
  
  public void render() {
    noStroke();
    fill(0, 64);
    rect(0, height - 80, width, 80);
    
    slider.render();
    buttonSwitchMode.render();
    buttonResetTraining.render();
    buttonSaveTheBest.render();
    buttonSwitchAudio.render();
  }
  
  public void mouseReleased() {
    buttonSwitchMode.update();
    if (buttonSwitchMode.clicked) {
      switch(mode) {
      case INTERACTIVE:
        buttonSwitchMode.text = "Play";
        mode = GameMode.DEMO;
        cycles = 1;
        slider.value = 0;
        Game.startup(true);
        break;
    
      case DEMO:
        buttonSwitchMode.text = "Demo";
        mode = GameMode.INTERACTIVE;
        cycles = 1;
        slider.value = 0;
        Game.startup(true);
        break;
        
      case ALL:
        break;
      }
    }
    
    buttonResetTraining.update();
    if (buttonResetTraining.clicked) {
      deleteFileInData("melody.json");
      Game.startup(true);
    }
    
    buttonSaveTheBest.update();
    if (buttonSaveTheBest.clicked) {
      Genetic.calculateFitness();
      Genetic.samplePool(1);
      saveJSONObject(birds.get(0).brain.toJSON(), dataPath("melody.json"));
    }
    
    buttonSwitchAudio.update();
    if (buttonSwitchAudio.clicked) {
      audioEnabled = !audioEnabled;
      buttonSwitchAudio.text = audioEnabled ? "Audio Off" : "Audio On";
    }
    
    slider.update();
    cycles = constrain(floor(slider.value * 100), 1, 100);
  }
  
  public void mouseDragged() {
    slider.update();
    cycles = constrain(floor(slider.value * 100), 1, 100);
  }
}
UI_ UI = new UI_();

class Button {
  float x;
  float y;
  float size;
  boolean clicked;
  String text;
  GameMode enableMode;
  
  Button(String text, GameMode enableMode) {
    this.clicked = false;
    this.text = text;
    this.enableMode = enableMode;
  }
  
  public void update() {
    if(this.enableMode != GameMode.ALL && this.enableMode != mode) {
      return;
    }
    if (mouseX >= this.x && mouseX <= this.x + this.size && mouseY >= this.y - 30 && mouseY <= this.y + 30) {
      this.clicked = true;
    }
    else {
      this.clicked = false;
    }
  }
  
  public void render() {
    fill(0, 128);
    noStroke();
    rect(x, y, size, 30, 3);
    
    if(this.enableMode == GameMode.ALL || this.enableMode == mode) {
      fill(255);
    }
    else {
      fill(128);
    }
    textAlign(CENTER, CENTER);
    textSize(16);
    text(this.text, this.x + this.size / 2, this.y + 30 / 2);
  }
}

class Slider {
  float x;
  float y;
  float size;
  float value;
  GameMode enableMode;
  
  Slider(GameMode enableMode) {
    this.value = 0.0f;
    this.enableMode = enableMode;
  }
  
  public void update() {
    if(this.enableMode != GameMode.ALL && this.enableMode != mode) {
      return;
    }
    if (mouseX >= this.x && mouseX <= this.x + this.size && mouseY >= this.y - 5 && mouseY <= this.y + 10) {
      this.value = map(mouseX, this.x, this.x + this.size, 0.0f, 1.0f);
    }
  }
  
  public void render() {
    noStroke();
    fill(0, 128);
    rect(this.x, this.y, this.size, 5, 3);
    
    if(this.enableMode == GameMode.ALL || this.enableMode == mode) {
      fill(255);
    }
    else {
      fill(128);
    }
    rect(this.x, this.y, this.size * this.value, 5, 3);
  }
}
public boolean isSpaceBarPressed(GameMode mode_) {
  if (mode_ == GameMode.ALL || mode == mode_) {
    if (keyPressed && key == ' ') {
      delay(200); // Avoid Debounce; crude but it works
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

public boolean fileExistsInData(String fileName) {
  return new File(dataPath(fileName)).exists();
}

public void deleteFileInData(String fileName) {
  File file = new File(dataPath(fileName));
  if(file.exists()) { 
    file.delete();
  }
}

public float mapToScreenY(float y) {
  return map(y, height, 0, 0, height);
}

public void fadeScreen() {
  noStroke();
  fill(0, 128);
  rect(0, 0, width, height);
}

public void centeredText(String s) {
  textSize(32);
  fill(255);
  textAlign(CENTER, CENTER);
  text(s, width / 2, height / 2);
}

public void continueText(String s) {
  textSize(32);
  fill(255);
  textAlign(CENTER, CENTER);
  text(s, width / 2, height - 40);
}

public void scoreText(String s) {
  textSize(32);
  fill(255);
  textAlign(RIGHT, TOP);
  text(s, width - 10, 10);
}
  public void settings() {  size(600, 800, P2D);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FlappyBird" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
