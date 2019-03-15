class MemorySlot {
  float[] s;
  int a;
  float reward;
  float[] s_1;
  boolean done;
}

class MemoryReplay {
  SumTree<MemorySlot> slots;

  MemoryReplay(int memoryReplaySize) {
    this.slots = new SumTree<MemorySlot>(new MemorySlot[memoryReplaySize]);
  }

  int size() {
    return this.slots.size();
  }

  int pickOne() {
    float s = random(this.slots.total());
    return this.slots.get(s);
  }
  
  int[] pickSample(int n) {
    int[] batch = new int[n];
    float segment = this.slots.total() / n;
    
    for(int i = 0; i < n; i++) {
      float a = segment * i;
      float b = segment * (i + 1);
      float s =  random(a, b);
      batch[i] = this.slots.get(s);
    }
    
    return batch;
  }

  void add(float[] s, int a, float reward, float[] s_1, boolean done) {
    MemorySlot m = new MemorySlot();
    m.s = s;
    m.a = a;
    m.reward = reward;
    m.s_1 = s_1;
    m.done = done;
    
    float p = priority(max(0, reward));
    this.slots.add(p, m);
  }

  void update(int i, float error) {
    float p = priority(error);
    this.slots.update(i, p);
  }
  
  float priority(float error) {
    return pow(error + EPSILON, 0.6);
  }
}
