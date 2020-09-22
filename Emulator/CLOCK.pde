class Clock_t {
  void start() {
    thread("clockInterrupt");
  }
  
  void spinWait() {
    for (int i = 0; i < 10; i++) Thread.yield();
  }
}
Clock_t CLOCK = new Clock_t();

void clockInterrupt() {
  while(true) {
    CPU.clock();
    RAM.clock();
    GPU.clock();
    CLOCK.spinWait();
  }
}
