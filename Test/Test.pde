int[] logt = new int[512];
int[] expt = new int[512];

int flog(int i) {
  if (i < 0) {
    return -logt[-i];
  } else {
    return logt[i];
  }
}

int fexp(int i) {
  if (i < 0) {
    return 2 * i + logt[-i];
  } else {
    return 2 * i - logt[i];
  }
}

void setup() {
  size(800, 800);
  
  for (int i = 0; i < 512; i++) {
    float s1 = (float) i / 512;
    //float s2 = s1 * s1; //(s1 > 0) ? log(s1 + 1) / log(3): 0;
    logt[i] = floor(map(s1 * s1, 0, 1, 0, 512));
    expt[i] = floor(map(sqrt(s1), 0, 1, 0, 512));
  }
  
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 32; j++) {
      int off = i * 32 + j;
      print(logt[off]);
      print(", ");
    }
    println();
  }
  
  println(new String[] {});
  println("".split(","));
  println("toto".split(","));
  println("toto,tata".split(","));
  println("toto,tata,titi".split(","));
}

void draw() {

  background(51);
  stroke(128);
  line(width / 2, 0, width / 2, height);
  line(0, height / 2, width, height / 2);
  
  
  for (int i = 0; i < 1023; i++) {
    float x = map(i, 0, 1023, 0, width);
    stroke(255);
    point(x, map(i - 511 + 511, 0, 1023, height, 0));
    stroke(255, 0, 0);
    point(x, map(flog(i - 511) + 511, 0, 1023, height, 0));
    stroke(0, 255, 0);
    point(x, map(fexp(i - 511) + 511, 0, 1023, height, 0));
  }
  
  noLoop();
}
