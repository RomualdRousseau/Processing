String getClassInfo(Object o) {
  String[] m = match(o.getClass().getName(), "\\$([a-zA-Z0-9_]*[a-zA-Z0-9])_?");
  return m[1];
}

static class Action {
  short keyCode;
  String keyString;
  String help;
  
  Action(short keyCode, String keyString, String help) {
    this.keyCode = keyCode;
    this.keyString = keyString;
    this.help = help;
  }
}
