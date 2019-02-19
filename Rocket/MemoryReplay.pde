class MemorySlot {
  float[] s;
  int a;
  float reward;
  float[] s_1;
  boolean done;
}

class MemoryReplay {
  ArrayList<MemorySlot> slots = new ArrayList<MemorySlot>();
  int memoryReplaySize;
  
  MemoryReplay(int memoryReplaySize) {
    this.memoryReplaySize = memoryReplaySize;
  }
  
  int size() {
    return this.slots.size();
  }

  MemorySlot pickOne() {
    return slots.get(floor(random(this.slots.size())));
  }

  void add(float[] s, int a, float reward, float[] s_1, boolean done) {
    MemorySlot m = new MemorySlot();
    m.s = s;
    m.a = a;
    m.reward = reward;
    m.s_1 = s_1;
    m.done = done;

    this.slots.add(m);

    if (this.slots.size() > this.memoryReplaySize) {
      this.slots.remove(0);
    }
  }
}
