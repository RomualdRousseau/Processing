boolean isSpaceBarPressed() {
  if (mode == GameMode.INTERACTIVE) {
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

boolean fileExistsInData(String fileName) {
  return new File(dataPath(fileName)).exists();
}

float mapToScreenY(float y) {
  return map(y, height, 0, 0, height);
}

void fadeScreen() {
  noStroke();
  fill(0, 128);
  rect(0, 0, width, height);
}

void centeredText(String s) {
  fill(255);
  textAlign(CENTER, CENTER);
  text(s, width / 2, height /2);
}

void scoreText(String s) {
  fill(255);
  textAlign(RIGHT, TOP);
  text(s, width - 10, 10);
}
