void settings() {
  size(400, 400);
  noSmooth();
}

void setup() {
  RAM.load();
  GPU.load();
  BUS.reset();
  CLOCK.start();
  
  println(as_uint8(add_bin((byte) 127, (byte) 64)));
  println(as_int8(add_bcd((byte) 127, (byte) 64)));
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
