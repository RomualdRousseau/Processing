import java.util.function.Function;
import java.util.Comparator;
import java.util.Collections;
import processing.sound.*;

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
static final float WIDTH = 400;
static final float HEIGHT = 800;
static final int MAX_SCORE = 214;
static final float G = -9.81;
static final float DRAG_COEF = 10;
static final float MUTATION_RATE = 0.1;
static final float MUTATION_VARIANCE = 0.1;
static final float SIMULATION_TIME = 0.01666668; // 1.0 / 60 fps
static final int BIRDS_COUNT = 100;
static final float BIRD_MASS = 100;
static final float BIRD_FLY_FORCE = 6000;
static final float BIRD_MAX_SPEED = 200;
static final float PILLAR_SPACING = 200;
static final float PILLAR_SIZE = 80;
static final float PILLAR_SCROLLING_SPEED = -20;
static final float PILLAR_INTERVAL = 50.0; // Main factor of difficulty; the smaller, the closer are the pillars! 
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
static int cycles = 1;
static int simulationSteps = 10; // 600 / frameRate
static boolean audioEnabled = true;

static Landscape landscape;
static Friend friend;
static ArrayList<Bird> birds;
static ArrayList<Pillar> pillars;
static Trophee trophee;
