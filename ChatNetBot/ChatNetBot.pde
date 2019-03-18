volatile int[] network = new int[3];
volatile int[] terminate = new int[3];

void setup() {
  thread("bot1");
  thread("bot2");
  thread("bot3");
}

int argmax(int[] v) {
  int result = 0;
  int maxValue = v[0];
  for (int i = 1; i < v.length; i++) {
    if (v[i] > maxValue) {
      maxValue = v[i];
      result = i;
    }
  }
  return result;
}

void bot(int i) {
  while (true) {
    int jeton = floor(random(1, 100));
    network[i] = jeton; // write to network

    int k = argmax(network);
    while (i != k && network[k] == 0) {
      k = argmax(network); // read to network
      delay(100);
    }
    network[i] = 0;
    
    println(String.format("I, %d, talk", i));
    
    terminate[i]++;
    while(min(terminate) < terminate[i]) delay(100); // read to network
  }
}

void bot1() {
  bot(0);
}

void bot2() {
  bot(1);
}

void bot3() {
  bot(2);
}
