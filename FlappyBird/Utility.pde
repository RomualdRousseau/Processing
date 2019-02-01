String getDataPath(String path) {
  return dataPath(path);
}

boolean isSpaceBarPressed(GameMode mode_) {
  if (mode_ == GameMode.ALL || mode == mode_) {
    if (mousePressed || keyPressed && key == ' ') {
      delay(200); // Avoid Debounce; crude but it works
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

boolean fileExistsInData(String fileName) {
  return new File(getDataPath(fileName)).exists();
}

void deleteFileInData(String fileName) {
  File file = new File(getDataPath(fileName));
  if(file.exists()) { 
    file.delete();
  }
}

float mapToScreenX(float x) {
  return map(x, 0, WIDTH, 0, width);
}

float mapToScreenY(float y) {
  return map(y, HEIGHT, 0, 0, height);
}

float scaleToScreenX(float x) {
  return map(x, 0, WIDTH, 0, width);
}

float scaleToScreenY(float y) {
  return map(y, 0, HEIGHT, 0, height);
}

void fadeScreen() {
  noStroke();
  fill(0, 128);
  rect(mapToScreenX(0), mapToScreenY(HEIGHT), scaleToScreenX(WIDTH), scaleToScreenY(HEIGHT));
}

void centeredText(String s) {
  textSize(scaleToScreenY(32));
  fill(255);
  textAlign(CENTER, CENTER);
  text(s, mapToScreenX(WIDTH / 2), mapToScreenY(HEIGHT / 2));
}

void continueText(String s) {
  textSize(scaleToScreenY(32));
  fill(255);
  textAlign(CENTER, CENTER);
  text(s, mapToScreenX(WIDTH / 2), mapToScreenY(40));
}

void scoreText(String s) {
  textSize(scaleToScreenY(32));
  fill(255);
  textAlign(RIGHT, TOP);
  text(s, mapToScreenX(WIDTH - 10), mapToScreenY(HEIGHT - 10));
}
