class Compiler {
  public Compiler(String s) {
    this.stack = new ArrayList<Element>();
    this.pattern = new StringStream(s);
  }

  public Compiler(Stream pattern) {
    this.pattern = pattern;
  }

  public Element compile() {
    return r();
  }

  Element r() {
    // Grammar
    //   R = RR
    //   R = (R)
    //   R = R*
    //   R = a
    String c = this.pattern.peek();

    if (c.equals("")) {
      return new Nop();
    } else if (c.equals(")")) {
      return new Nop();
    }  else if (c.equals("]")) {
      return new Nop();
    } else {
      Element e1 = r2();
      Element e2 = r();

      if (e2 instanceof Nop) { // Small optimization
        return e1;
      } else {
        this.stack.add(e2);
        this.stack.add(e1);
        return new Concat(this.stack);
      }
    }
  }

  Element r2() {
    String c = this.pattern.peek();

    if (c.charAt(0) >= 'a' && c.charAt(0) <= 'z' || c.charAt(0) == '$') {
      accept();
      Element e = new Value(c);
      return r3(e);
    } else if (c.equals("(")) {
      accept();
      Element e = r();
      accept(")");
      this.stack.add(r3(e));
      return new Group(this.stack);
    } else if (c.equals("[")) {
      accept();
      Element e = r();
      accept("]");
      return r3(e);
    } else {
      throw new RuntimeException("Syntax Error: " + c);
    }
  }

  Element r3(Element e) {
    if (this.pattern.peek().equals("+")) {
      accept();
      this.stack.add(e);
      return new Closure(this.stack);
    } else if (this.pattern.peek().equals("|")) {
      accept();
      Element e2 = r();
      this.stack.add(e2);
      this.stack.add(e);
      return new Or(this.stack);
    } else {
      return e;
    }
  }

  void accept() {
    this.pattern.read();
  }

  void accept(String a) {
    if (!this.pattern.read().equals(a)) {
      throw new RuntimeException("Syntx Error");
    }
  }

  ArrayList<Element> stack;
  Stream pattern;
}
