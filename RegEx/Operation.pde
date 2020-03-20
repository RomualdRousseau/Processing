class Or implements Element {
  public Or(ArrayList<Element> stack) {
    this.a = stack.remove(stack.size() - 1);
    this.b = stack.remove(stack.size() - 1);
  }

  public boolean match(Stream s, Context ctx) {
    s.push();
    boolean a = this.a.match(s, ctx);
    s.seek(s.pop());
    boolean b = this.b.match(s, ctx);
    return a || b;
  }
  
  public String toString() {
    return "OR(" + a + "," + b + ")";
  }

  Element a;
  Element b;
}

class Concat implements Element {
  public Concat(ArrayList<Element> stack) {
    this.a = stack.remove(stack.size() - 1);
    this.b = stack.remove(stack.size() - 1);
  }

  public boolean match(Stream s, Context ctx) {
    boolean a = this.a.match(s, ctx);
    boolean b = this.b.match(s, ctx);
    return a && b;
  }
  
  public String toString() {
    return "CONCAT(" + a + "," + b + ")";
  }

  Element a;
  Element b;
}

class Closure implements Element {
  public Closure(ArrayList<Element> stack) {
    this.a = stack.remove(stack.size() - 1);
  }

  public boolean match(Stream s, Context ctx) {
    boolean m = false;
    int count = 0;
    while (true) {
      s.push();
      boolean a = this.a.match(s, ctx);
      if (!a) {
        s.seek(s.pop());
        return (count > 0) && m;
      } else {
        count++;
        s.pop();
        m |= true;
      }
    }
  }
  
  public String toString() {
    return "CLOSURE(" + a + ")";
  }

  Element a;
}

class Group implements Element {
  public Group(ArrayList<Element> stack) {
    this.a = stack.remove(stack.size() - 1);
  }

  public boolean match(Stream s, Context ctx) {
    ctx.group++;
    return a.match(s, ctx);
  }
  
  public String toString() {
    return "GROUP(" + a + ")";
  }

  Element a;
}
