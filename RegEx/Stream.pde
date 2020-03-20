interface Stream {
  String read();

  String peek();

  void push();

  int pop();

  void seek(int i);
}

class StringStream implements Stream {
  public StringStream(String s) {
    this.stack = new ArrayList<Integer>();
    this.s = s;
    this.i = 0;
  }

  public String read() {
    if (this.i >= this.s.length()) {
      return "";
    } else {
      return String.valueOf(this.s.charAt(this.i++));
    }
  }

  public String peek() {
    if (this.i >= this.s.length()) {
      return "";
    } else {
      return String.valueOf(this.s.charAt(this.i));
    }
  }

  public void push() {
    this.stack.add(this.i);
  }

  public int pop() {
    return this.stack.remove(this.stack.size() - 1);
  }

  public void seek(int i) {
    this.i = i;
  }

  ArrayList<Integer> stack;
  String s;
  int i;
}

class TableStream implements Stream {
  public TableStream(String[] s) {
    this.stack = new ArrayList<Integer>();
    this.s = s;
    this.i = 0;
    this.j = 0;
  }

  public String read() {
    if (this.j >= this.s.length) {
      return "$";
    } else if (this.i >= this.s[j].length()) {
      this.i = 0;
      this.j++;
      return "$";
    } else {
      return String.valueOf(this.s[j].charAt(this.i++));
    }
  }

  public String peek() {
    if (this.j >= this.s.length) {
      return "$";
    } else if (this.i >= this.s[j].length()) {
      return "$";
    } else {
      return String.valueOf(this.s[j].charAt(this.i));
    }
  }

  public void push() {
    this.stack.add(this.i + this.j * 1000);
  }

  public int pop() {
    return this.stack.remove(this.stack.size() - 1);
  }

  public void seek(int i) {
    this.i = i % 1000;
    this.j = i / 1000;
  }

  ArrayList<Integer> stack;
  String s[];
  int i;
  int j;
}
