class GPU_t {
  PImage vbank = createImage(100, 100, RGB);
  PImage font;
  int[] palette = {
    color(0, 0, 0),
    color(255, 0, 0),
    color(0, 255, 0),
    color(0, 0, 255) 
  };
  int x;
  int y;
  
  GPU_t() {
  }
  
  void load() {
    font = loadImage("font.png");
  }
  
  void clock() {
    if(BUS.addr == 0x0900 && BUS.rw == 0) {
      x = BUS.data;
    }
    else if(BUS.addr == 0x0901 && BUS.rw == 0) {
      y = BUS.data;
    }
    else if(BUS.addr == 0x0902 && BUS.rw == 0) {
      vbank.loadPixels();
      vbank.pixels[y * vbank.width + x] = palette[BUS.data & 0xFF];
      vbank.updatePixels();
      x++;
    }
    else if(BUS.addr == 0x0903 && BUS.rw == 0) {
      int num = (BUS.data & 0xFF);
      int xf = (num % 12) * 8;
      int yf = (num / 12) * 8;
      vbank.set(x, y, font.get(xf, yf, 8, 8));
      x += 8;
    }
  }
  
  void draw() {
    image(vbank, 0, 0, width, height);
  }
}
GPU_t GPU = new GPU_t();
