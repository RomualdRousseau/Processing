int as_uint8(byte a) {
  return a & 0xff;
}

int as_int8(byte a) {
  return a;
}

byte add_bin(byte a, byte b) {
  int r =  (int) (a & 0xff) + (int) (b & 0xff);
  if (r >= 256) {
    println("carry");
  }
  if (r == 0) {
    println("zero");
  }
  return (byte) (r & 0xff);
}

byte add_bcd(byte a, byte b) {
  int r =  a + b;
  if (r >= 128) {
    println("carry");
  }
  if (r < 0) {
    println("negative");
  }
  if (r == 0) {
    println("zero");
  }
  return (byte) r;
}
