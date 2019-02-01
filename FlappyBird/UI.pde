class UI_
{
  Slider slider = new Slider();
  Button buttonSwitchMode = new Button("Play");
  Button buttonRestartTraining = new Button("Restart");
  Button buttonSaveTheBest = new Button("Save");
  Button buttonSwitchAudio = new Button("Audio Off");

  void pack() {
    slider.x = 10;
    slider.y = height - 10;
    slider.size = width - 20;
    
    buttonSwitchMode.x = 10;
    buttonSwitchMode.y = height - 50;
    buttonSwitchMode.size = 100;
    
    buttonRestartTraining.x = 120;
    buttonRestartTraining.y = height - 50;
    buttonRestartTraining.size = 100;
    
    buttonSaveTheBest.x = 230;
    buttonSaveTheBest.y = height - 50;
    buttonSaveTheBest.size = 100;
    
    buttonSwitchAudio.x = 340;
    buttonSwitchAudio.y = height - 50;
    buttonSwitchAudio.size = 100;
  }
  
  void render() {
    noStroke();
    fill(0, 64);
    rect(0, height - 80, width, 80);
    
    slider.render();
    buttonSwitchMode.render();
    buttonRestartTraining.render();
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
      }
    }
    
    buttonRestartTraining.update();
    if (buttonRestartTraining.clicked) {
      Game.startup(true);
    }
    
    buttonSaveTheBest.update();
    if (buttonSaveTheBest.clicked) {
      for (int i = birds.size() - 1; i >= 1; i--) {
        birds.remove(i);
      }
      audioEnabled = true;
      saveJSONObject(birds.get(0).brain.toJSON(), "melody.json");
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
  
  Button(String text) {
    this.clicked = false;
    this.text = text;
  }
  
  void update() {
    if (mouseX >= this.x && mouseX <= this.x + this.size && mouseY >= this.y - 30 && mouseY <= this.y + 30) {
      this.clicked = true;
    }
    else {
      this.clicked = false;
    }
  }
  
  void render() {
    fill(0, 128);
    noStroke();
    rect(x, y, size, 30, 3);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(this.text, this.x + this.size / 2, this.y + 30 / 2 - 4);
  }
}

class Slider {
  float x;
  float y;
  float size;
  float value;
  
  Slider() {
    this.value = 0.0;
  }
  
  void update() {
    if (mouseX >= this.x && mouseX <= this.x + this.size && mouseY >= this.y - 5 && mouseY <= this.y + 10) {
      this.value = map(mouseX, this.x, this.x + this.size, 0.0, 1.0);
    }
  }
  
  void render() {
    noStroke();
    fill(0, 128);
    rect(this.x, this.y, this.size, 5, 3);
    fill(255);
    rect(this.x, this.y, this.size * this.value, 5, 3);
  }
}
