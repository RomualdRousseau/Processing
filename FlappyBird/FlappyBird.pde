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
 *  - Relative features extraction as the NN input
 *  - Tanh and softmax activation functions for the NN
 *  - Added a bonus to the genetic fitness if the bird flies around the center of the pillars
 *  - Physic engine independant of the screen resolution
 *  - Added mass and time integral in the physic equations
 *  - Playable option
 *  - Added different behaviors to tell a story of my wifey and cute GFX ;)
 *
 * Disclaimer and fair use:
 * I don't own any rights for the usage of Melody and Cinamon characters. As such this images are not for redistribution.
 * If you intend to use or to modify this , please replace the images by your own set.
 *
 * Author: Romuald Rousseau
 * Date: 2019-01-31
 * Processing 3+ with Sound library
 */

void settings() {
  if (!ANDROID) {
    size(600, 800, P2D);
  }
}

void setup() {
  if(ANDROID) {
    requestAllPermissions();
    ensureDataPathExist();
    orientation(PORTRAIT);
    simulationSteps = floor(600 / 30); // 30 is the frame rate
    frameRate(30);
  }
  else {
    simulationSteps = floor(600 / frameRate);  
  }
  smooth();
  Resources.loadAll(this);
  UI.pack();
  Game.startup(true);
}

void draw() {
  Game.mainloop();
  Game.render();
  UI.render();
}

void mouseReleased() {
  if (mouseY > mapToScreenY(80)) {
    if(UI.show) {
      UI.mouseReleased();  
    } else {
      UI.show = true;
    }
  } else {
    UI.show = false;
  }
}

void mouseDragged() {
  if (mouseY > mapToScreenY(80)) {
    if(UI.show) {
      UI.mouseDragged();  
    } else {
      UI.show = true;
    }
  } else {
    UI.show = false;
  }
}

void mouseMoved() {
  if (mouseY > mapToScreenY(80)) {
    UI.show = true;
  } else {
    UI.show = false;
  }
}
