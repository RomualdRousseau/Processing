Graph graph;

void setup() {
  size(800, 800);

  graph = Algebra("PGA2D", 2, 0, 1).graph(new Graph2D(this), example1);

  //graph = Algebra("PGA3D", 2, 0, 1).graph(new Graph2D(this), example2);
  
  //graph = Algebra("Complex", 0, 1, 0).graph(new Graph2D(this), example3);
}

void draw() {
  graph.draw();
}

void mouseDragged() {
  graph.mouseX = map(mouseX, 0, width, -width * 0.5 / graph.zoom, width * 0.5 / graph.zoom);
  graph.mouseY = map(mouseY, height, 0, -height * 0.5 / graph.zoom, height * 0.5 / graph.zoom);
}

void mouseWheel(MouseEvent event) {
  graph.zoom += event.getCount();
}
