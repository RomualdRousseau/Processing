class GPU_t {
  PImage vbank = createImage(100, 100, RGB);
  int[] palette = {
    color(0, 0, 0),
    color(255, 0, 0),
    color(0, 255, 0),
    color(0, 0, 255) 
  };
  int off;
  int x;
  int y;
  
  GPU_t() {
  }
  
  void load() {
  }
  
  void clock() {
    if(BUS.addr == 0x0900 && BUS.rw == 0) {
      off = BUS.data;
    }
    else if(BUS.addr == 0x0901 && BUS.rw == 0) {
      off += BUS.data * 100;
    }
    else if(BUS.addr == 0x0902 && BUS.rw == 0) {
      vbank.loadPixels();
      vbank.pixels[off] = palette[BUS.data & 0xFF];
      vbank.updatePixels();
      off++;
    }
  }
  
  void draw() {
    image(vbank, 0, 0, width, height);
  }
}
GPU_t GPU = new GPU_t();
