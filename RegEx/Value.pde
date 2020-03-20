class Value implements Element {
  public Value(String v) {
    this.v = v;
  }

  public boolean match(Stream s, Context ctx) {
    String c = s.read();
    if (!c.equals("") && c.equals(v)) {
      ctx.func(c);
      return true;
    } else {
      return false;
    }
  }

  public String toString() {
    return "value('" + this.v + "')";
  }

  String v;
}

class Nop implements Element {
  public Nop() {
  }

  public boolean match(Stream s, Context ctx) {
    return true;
  }

  public String toString() {
    return "nop";
  }
}
