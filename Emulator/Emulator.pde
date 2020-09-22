void setup() {
  size(400, 400);
  RAM.load();
  GPU.load();
  BUS.reset();
  CLOCK.start();
}

void draw() {
  //CPU.debug();
  //RAM.draw();
  GPU.draw();
}

void keyPressed() {
  if (key == 'r') {
    BUS.reset();
  } else if (key == 'i') {
    BUS.interrupt();
  }
}
