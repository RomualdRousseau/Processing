class SumTree {
  int capacity;
  float[] tree;
  MemorySlot[] data;
  int write;
  int size;

  SumTree(int capacity) {
    this.capacity = capacity;
    this.tree = new float[2 * capacity - 1];
    this.data = new MemorySlot[capacity];
    this.write = 0;
    this.size = 0;
  }
  
  int size() {
    return this.size;
  }
  
  float total() {
    return this.tree[0];
  }

  void add(float p, MemorySlot data) {
    int i = this.write + this.capacity - 1;

    this.data[this.write] = data;
    this.update(i, p);

    this.write++;
    if (this.write >= this.capacity) {
      this.write = 0;
    }

    if (this.size < this.capacity) {
      this.size++;
    }
  }

  void update(int i, float p) {
    float change = p - this.tree[i];
    this.tree[i] = p;
    this.propagate(i, change);
  }

  int get(float p) {
    return this.retrieve(0, p);
  }
  
  MemorySlot getData(int i) {
    return this.data[i - this.capacity + 1];
  }

  int retrieve(int i, float p) {
    int left = 2 * i + 1;
    int right = left + 1;

    if (left >= this.tree.length) {
      return i;
    }

    if (p <= this.tree[left]) {
      return this.retrieve(left, p);
    } else {
      return this.retrieve(right, p - this.tree[left]);
    }
  }

  void propagate(int i, float p) {
    int parent = (i - 1) / 2;

    this.tree[parent] += p;

    if (parent != 0) {
      this.propagate(parent, p);
    }
  }
}