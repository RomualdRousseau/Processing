class UI_
{
  Slider slider = new Slider(GameMode.ALL);
  Button buttonSwitchMode = new Button("Play", GameMode.ALL);
  Button buttonResetTraining = new Button("Train", GameMode.DEMO);
  Button buttonSaveTheBest = new Button("Save", GameMode.DEMO);
  Button buttonSwitchAudio = new Button("Audio Off", GameMode.ALL);
  boolean show = false;
  
  void pack() {
    slider.x = 10;
    slider.y = 10;
    slider.size = WIDTH - 20;
    
    float w = (WIDTH - 10) / 4;
    
    buttonSwitchMode.x = 10;
    buttonSwitchMode.y = 50;
    buttonSwitchMode.size = w - 10;
    
    buttonResetTraining.x = 10 + w;
    buttonResetTraining.y = 50;
    buttonResetTraining.size = w - 10;
    
    buttonSaveTheBest.x = 10 + w * 2;
    buttonSaveTheBest.y = 50;
    buttonSaveTheBest.size = w - 10;
    
    buttonSwitchAudio.x = 10 + w * 3;
    buttonSwitchAudio.y = 50;
    buttonSwitchAudio.size = w - 10;
  }
  
  void fadeScreen() {
    noStroke();
    fill(0, 128);
    rect(mapToScreenX(0), mapToScreenY(HEIGHT), scaleToScreenX(WIDTH), scaleToScreenY(HEIGHT));
  }
  
  void centeredText(String s) {
    textSize(scaleToScreenX(32));
    fill(255);
    textAlign(CENTER, CENTER);
    text(s, mapToScreenX(WIDTH / 2), mapToScreenY(HEIGHT / 2));
  }
  
  void continueText(String s) {
    textSize(scaleToScreenX(24));
    fill(255);
    textAlign(CENTER, CENTER);
    text(s, mapToScreenX(WIDTH / 2), mapToScreenY(40));
  }
  
  void scoreText(String s) {
    textSize(scaleToScreenX(32));
    fill(255);
    textAlign(RIGHT, TOP);
    text(s, mapToScreenX(WIDTH - 10), mapToScreenY(HEIGHT - 10));
  }
  
  void render() {
    if(!this.show) {
      return;
    }
    
    noStroke();
    fill(0, 64);
    rect(mapToScreenX(0), mapToScreenY(80), scaleToScreenX(WIDTH), scaleToScreenY(80));
    
    slider.render();
    buttonSwitchMode.render();
    buttonResetTraining.render();
    buttonSaveTheBest.render();
    buttonSwitchAudio.render();
  }
  
  void mouseReleased() {
    buttonSwitchMode.update();
    if (buttonSwitchMode.clicked) {
      switch(mode) {
      case INTERACTIVE:
        buttonSwitchMode.text = "Play";
        mode = GameMode.DEMO;
        cycles = 1;
        slider.value = 0;
        UI.show = false;
        Game.startup(true);
        break;
    
      case DEMO:
        buttonSwitchMode.text = "Demo";
        mode = GameMode.INTERACTIVE;
        cycles = 1;
        slider.value = 0;
        UI.show = false;
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
      JSON.saveJSONObject(birds.get(0).brain.toJSON(), getDataPath("melody.json"));
    }
    
    buttonSwitchAudio.update();
    if (buttonSwitchAudio.clicked) {
      audioEnabled = !audioEnabled;
      buttonSwitchAudio.text = audioEnabled ? "Audio Off" : "Audio On";
    }
    
    slider.update();
    cycles = constrain(floor(slider.value * 100), 1, 100);
  }
  
  void mouseDragged() {
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
  
  void update() {
    if(this.enableMode != GameMode.ALL && this.enableMode != mode) {
      return;
    }
    if (mouseX >= mapToScreenX(this.x) && mouseX <= mapToScreenX(this.x + this.size) && mouseY >= mapToScreenY(this.y + 30) && mouseY <= mapToScreenY(this.y - 30)) {
      this.clicked = true;
    }
    else {
      this.clicked = false;
    }
  }
  
  void render() {
    fill(0, 128);
    noStroke();
    rect(mapToScreenX(this.x), mapToScreenY(this.y), scaleToScreenX(this.size), scaleToScreenY(30), 3);
    
    if(this.enableMode == GameMode.ALL || this.enableMode == mode) {
      fill(255);
    }
    else {
      fill(128);
    }
    textAlign(CENTER, CENTER);
    textSize(scaleToScreenX(14));
    text(this.text, mapToScreenX(this.x + this.size / 2), mapToScreenY(this.y - 30 / 2));
  }
}

class Slider {
  float x;
  float y;
  float size;
  float value;
  GameMode enableMode;
  
  Slider(GameMode enableMode) {
    this.value = 0.0;
    this.enableMode = enableMode;
  }
  
  void update() {
    if(this.enableMode != GameMode.ALL && this.enableMode != mode) {
      return;
    }
    if (mouseX >= mapToScreenX(this.x) && mouseX <= mapToScreenX(this.x + this.size) && mouseY >= mapToScreenY(this.y + 5) && mouseY <= mapToScreenY(this.y - 10)) {
      this.value = map(mouseX, mapToScreenX(this.x), mapToScreenX(this.x + this.size), 0.0, 1.0);
    }
  }
  
  void render() {
    noStroke();
    fill(0, 128);
    rect(mapToScreenX(this.x), mapToScreenY(this.y), scaleToScreenX(this.size), scaleToScreenY(5), 3);
    
    if(this.enableMode == GameMode.ALL || this.enableMode == mode) {
      fill(255);
    }
    else {
      fill(128);
    }
    rect(mapToScreenX(this.x), mapToScreenY(this.y), scaleToScreenX(this.size * this.value), scaleToScreenY(5), 3);
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

float scaleToScreenXY(float y) {
  if(width <= height / 2) {
    return scaleToScreenX(y);
  } else {
    return scaleToScreenY(y);
  }
}
