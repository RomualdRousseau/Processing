import controlP5.*;

ControlP5 cp5;

void setup() {
  size(600, 400);
  noStroke();
  
  cp5 = new ControlP5(this);
  
  cp5.addButton("Connect")
    .setPosition(10,10)
    .setSize(80, 19);
  
  for(int i = 0; i < 8; i++) {
    for(int j = 0; j < 8; j++) {
      cp5.addSlider("mix" + i + j, -100, 100, 0, 120 + j * 30, 10 + i * 20, 20, 14).setLabel("");
    }
  }
  
  for(int i = 0; i < 8; i++) {
    cp5.addSlider("trim" + i, -100, 100, 0, 120 + i * 30, 190, 20, 14).setLabel("");
  }
  
  for(int i = 0; i < 8; i++) {
    cp5.addSlider("command" + i, 0, 2100, 0, 400, 10 + i * 20, 100, 14).setLabel("");
  }
}

void draw() {
  background(51);
}

public void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id "+theEvent.getName());
}
