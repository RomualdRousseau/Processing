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
void setup() {
  size(800, 800, P2D);
  smooth();
  Resources.loadAll(this);
  UI.pack();
  Game.startup(true);
}

void draw() {
  Game.mainloop();
  Game.render();
  if(mouseY > mapToScreenY(80)) {
    UI.render();
  }
}

void mouseReleased() {
  if(mouseY > mapToScreenY(80)) {
    UI.mouseReleased();
  }
}

void mouseDragged() {
  if(mouseY > mapToScreenY(80)) {
    UI.mouseDragged();
  }
}
