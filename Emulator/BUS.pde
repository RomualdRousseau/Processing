class BUS_t {
  float reset;
  float nmi;
  char rw;
  int addr;
  char data;
  
  BUS_t() {
    reset = 0;
  }
  
  void reset() {
    reset = 0;
  }
  
  void interrupt() {
    nmi = 0;
  }
}
BUS_t BUS = new BUS_t();
