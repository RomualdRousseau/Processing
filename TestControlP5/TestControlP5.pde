import controlP5.*;

ControlP5 cp5;
ControlFrame cf;

void settings() {
  size(700, 400);
}

void setup() {
  noStroke();

  PFont icons = createFont("fontawesome-webfont.ttf", 32);

  cp5 = new ControlP5(this);

  cp5.addIcon("project", 10)
    .setPosition(0, 0)
    .setSize(64, 64)
    .setFont(icons)
    .setFontIcons(#00f15c, #00f15c)
    .setColorBackground(color(255, 100))
    ;
  cp5.addIcon("intellitag", 10)
    .setPosition(0, 64)
    .setSize(64, 64)
    .setFont(icons)
    .setFontIcons(#00f0e5, #00f0e5)
    .setColorBackground(color(255, 100))
    ;  
  cp5.addIcon("deploy", 10)
    .setPosition(0, 128)
    .setSize(64, 64)
    .setFont(icons)
    .setFontIcons(#00f0da, #00f0da)
    .setColorBackground(color(255, 100))
    ;
    
   cf = new ControlFrame(this, 400, 800, "Controls");
}

void draw() {
  background(51);
}
