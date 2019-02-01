class UI_
{
  Slider slider = new Slider(GameMode.ALL);
  Button buttonSwitchMode = new Button("Play", GameMode.ALL);
  Button buttonResetTraining = new Button("Train", GameMode.DEMO);
  Button buttonSaveTheBest = new Button("Save", GameMode.DEMO);
  Button buttonSwitchAudio = new Button("Audio Off", GameMode.ALL);

  void pack() {
    slider.x = 10;
    slider.y = 10;
    slider.size = WIDTH - 20;
    
    buttonSwitchMode.x = 10;
    buttonSwitchMode.y = 50;
    buttonSwitchMode.size = 100;
    
    buttonResetTraining.x = 120;
    buttonResetTraining.y = 50;
    buttonResetTraining.size = 100;
    
    buttonSaveTheBest.x = 230;
    buttonSaveTheBest.y = 50;
    buttonSaveTheBest.size = 100;
    
    buttonSwitchAudio.x = 340;
    buttonSwitchAudio.y = 50;
    buttonSwitchAudio.size = 100;
  }
  
  void render() {
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
      saveJSONObject(birds.get(0).brain.toJSON(), getDataPath("melody.json"));
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
    textSize(scaleToScreenY(16));
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
