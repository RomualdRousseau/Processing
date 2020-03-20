String[] table1 = {
  "hhhhmm",
  "vvvvxy",
  "vvvvxy",
  "vvvvxy",
  "tv"
};

String[] table2 = {
  "m",
  "hhhhhmmm",
  "vvvvvxyz",
  "vvvvvxyz",
  "vvvvvxyz",
  "tv",
  "m",
  "hhhhhmmm",
  "vvvvvxyz",
  "vvvvvxyz",
  "vvvvvxyz",
  "tv"
};

void setup() {
  println(new Compiler("(h+mm$)([v|x|y|z]+$)+(tv$)$").compile().match(new TableStream(table1), new Context()));
  println(new Compiler("[(m$h+m+$)([v|x|y|z]+$)+(tv$)]+$").compile().match(new TableStream(table2), new Context()));
}

void draw() {
}
