String[] mapData = {
  "################",
  "#..............#",
  "######.........#",
  "#..............#",
  "#..............#",
  "#....###.......#",
  "#....#.####....#",
  "#....###.......#",
  "#..............#",
  "#..............#",
  "#..............#",
  "#..#....########",
  "#.......#......#",
  "#.......#......#",
  "#..............#",
  "################"
};

ArrayList<Wall> walls = new ArrayList<Wall>();

void mapInit() {
  final int n = mapData.length;
  final int w = width / n;
  final int h = height / n;

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      char c = mapData[i].charAt(j);
      if (c == '#') {
        walls.add(new Wall(new PVector(j * w, i * h), new PVector(j * w + w, i * h), new PVector(0, 0, 1)));
        walls.add(new Wall(new PVector(j * w + w, i * h), new PVector(j * w + w, i * h + h), new PVector(0, 0, 1)));
        walls.add(new Wall(new PVector(j * w, i * h + h), new PVector(j * w + w, i * h + h), new PVector(0, 0, -1)));
        walls.add(new Wall(new PVector(j * w, i * h), new PVector(j * w, i * h + h), new PVector(0, 0, -1)));
      }
    }
  }
}

float map(PVector p, PVector c) {
  final float d = walls.stream().parallel().map(w -> w.dist(p)).sorted((d1, d2) -> (int)(abs(d1) - abs(d2))).findFirst().orElse(1000.0f);
  if (d >= 1000.0f) {
    return d;
  }
  
  final java.util.Optional<Wall> closestWall = walls.stream().parallel().filter(w -> w.dist(p) == d).findFirst();
  if (closestWall.isPresent()) {
    c.set(closestWall.get().closestPoint(p));
  }

  return d;
}

void setup() {
  size(400, 400);
  noCursor();
  mapInit();
}

void draw() {
  PVector p = new PVector(mouseX, mouseY);
  PVector c = new PVector();
  float d = map(p, c);

  background(51);

  walls.forEach(Wall::draw);

  stroke(255, 255, 0);
  line(p.x, p.y, c.x, c.y);

  stroke(255);
  line(p.x - 20, p.y, p.x + 20, p.y);
  line(p.x, p.y - 20, p.x, p.y + 20);
  text("" + d, p.x + 4, p.y - 4);
}
