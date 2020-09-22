class RAM_t {
  char[] bank = new char[2 * 1024];
  
  RAM_t() {
    for (int i = 0; i < bank.length; i++) {
      bank[i] = (char) random(256);
    }
  }
  
  void load() {
    byte b[] = loadBytes("rom.bin");
    for (int i = 0; i < bank.length; i++) {
      bank[i] = (char) (b[i] & 0xff);
    }
  }
  
  void clock() {
    if(BUS.addr >= bank.length) {
      return;
    }
    if(BUS.rw == 1) {
      BUS.data = bank[BUS.addr];
    } else {
      bank[BUS.addr] = (char) (BUS.data & 0xFF);
    }
  }
  
  void draw() {
    final float w = width / 64;
    final float h = height / 32;
    
    for (int i = 0; i < 32; i++) {
      for (int j = 0; j < 64; j++) {
        final float x = map(j, 0, 64, 0, width);
        final float y = map(i, 0, 32, 0, height);
        final int off = i * 64 + j;
        
        if (off < MEMORY.STAK) {
          fill(20, 200, bank[off]);
        } else if (off < MEMORY.CODE) {
          fill(20, bank[off], 200);
        }  else if (off < MEMORY.DATA) {
          fill(20, 200, bank[off]);
        } else {
          fill(bank[off], 20, 200);
        }
        
        rect(x, y, w, h);
      }
    }
  }
}
RAM_t RAM = new RAM_t();
