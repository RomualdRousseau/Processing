public class DungeonRoom
{
  public PVector position = new PVector(0, 0);
  public PVector size = new PVector(0, 0);

  public boolean isStart = false;
  public boolean isEnd = false;

  public boolean visited = false;

  public DungeonRoom(float x, float y, float w, float h) {
    this.position.x = x;
    this.position.y = y;
    this.size.x = w;
    this.size.y = h;
  }
}

public class Dungeon
{
  public ArrayList<DungeonRoom> rooms;
  
  public int[][] baseMap;
  
  public DungeonRoom getStartRoom() {
    for (DungeonRoom room : this.rooms) {
      if(room.isStart) {
        return room;
      }
    }
    return null;
  }
  
  public DungeonRoom getEndRoom() {
    for (DungeonRoom room : this.rooms) {
      if(room.isEnd) {
        return room;
      }
    }
    return null;
  }
  
  public void generate(int numRooms, int roomMinimumSize, int roomMaximumSize, int roomSpacing, int spreadIterations, float spreadMean, float spreadStd, float spreadCohesion, float spreadSeparation, int adjacentMaximumDistance, float deformationRatio, int mapSize) {

    rooms = new ArrayList<DungeonRoom>();

    for (int i= 0; i < numRooms; i++) {
      rooms.add(generateRoom(roomMinimumSize, roomMaximumSize, spreadMean, spreadStd));
    }

    for (int i = 0; i < spreadIterations; i++) {
      spreadRooms(spreadCohesion, spreadSeparation, roomSpacing);
    }

    snapRoomsIntoMap(mapSize);

    int[][] graph = generateGraph(adjacentMaximumDistance, deformationRatio);

    baseMap = generateMap(graph, mapSize);
  }

  private DungeonRoom generateRoom(float roomMinimumSize, float roomMaximumSize, float spreadMean, float spreadStd) {

    final float l = randomGaussian() * spreadStd + spreadMean;
    final float a = random(-PI, PI);

    final float x = int(l * cos(a));
    final float y = int(l * sin(a));

    final float w = random(roomMinimumSize, roomMaximumSize);
    final float h = random(roomMinimumSize, roomMaximumSize);

    return new DungeonRoom(x, y, w, h);
  }

  private void spreadRooms(float spreadCohesion, float spreadSeparation, int spacing) {
    final float n = rooms.size() - 1;

    // Cohesion and Separation

    for (DungeonRoom room : rooms) {

      PVector cohesion = new PVector(0, 0);
      for (DungeonRoom other : rooms) {
        if (other != room) {

          float d = PVector.dist(other.position, room.position);
          float m = max((room.size.x + other.size.x) * 0.5 + spacing, (room.size.y + other.size.y) * 0.5 + spacing);
          if (d > m) {
            cohesion.add(other.position);
          }
        }
      }
      cohesion.div(n).sub(room.position).normalize();

      PVector separation = new PVector(0, 0);
      for (DungeonRoom other : rooms) {
        if (other != room) {

          float d = PVector.dist(other.position, room.position);
          float m = max((room.size.x + other.size.x) * 0.5 + spacing, (room.size.y + other.size.y) * 0.5 + spacing);
          if (d < m) {
            separation.add(PVector.sub(room.position, other.position));
          }
        }
      }
      separation.div(n).normalize();

      room.position.add(cohesion.mult(spreadCohesion)).add(separation.mult(spreadSeparation));
    }
  }

  private void snapRoomsIntoMap(int mapSize) {
    
    // Align room to a grid of 1x1

    for (DungeonRoom room : rooms) {
      room.position.x = ceil(room.position.x);
      room.position.y = ceil(room.position.y);
      room.size.x = floor(room.size.x);
      room.size.y = floor(room.size.y);
    }

    // Calculate the bounding box

    PVector bbmin = rooms.get(0).position.copy();
    PVector bbmax = rooms.get(0).position.copy();
    for (DungeonRoom room : rooms) {
      if (room.position.x < bbmin.x) {
        bbmin.x = room.position.x;
      }
      if (room.position.x + room.size.x > bbmax.x) {
        bbmax.x = room.position.x + room.size.x;
      }
      if (room.position.y < bbmin.y) {
        bbmin.y = room.position.y;
      }
      if (room.position.y + room.size.y > bbmax.y) {
        bbmax.y = room.position.y + room.size.y;
      }
    }

    // Align the min corner to the origin of the grid

    PVector origin = bbmin.mult(-1);
    for (DungeonRoom room : rooms) {
      room.position.add(origin);
    }
    
    // Clip rooms to the grid size
    
    for (DungeonRoom room : rooms) {
      room.position.x = constrain(room.position.x, 1, mapSize - 2);
      room.position.y = constrain(room.position.y, 1, mapSize - 2);
      room.size.x = constrain(room.position.x + room.size.x, 1, mapSize) - 1 - room.position.x;
      room.size.y = constrain(room.position.y + room.size.y, 1, mapSize) - 1 - room.position.y;
    }

    // Remove rooms out of the grid

    ArrayList<DungeonRoom> tmp = new ArrayList<DungeonRoom>();
    for (DungeonRoom room : rooms) {
      if (room.position.x >= 0 && room.position.x < (mapSize - 2)
        && room.position.y >= 0 && room.position.y < (mapSize - 2)) {
        tmp.add(room);
      }
    }
    rooms = tmp;
  }

  private int[][] generateGraph(float maxDist, float deformPercent) {

    // Build laplacian matrix of the grap connecting all rooms
    // i.e. connect all rooms together

    int[][] graph = new int[rooms.size()][rooms.size()];
    for (int i = 0; i < graph.length; i++) {
      for (int j = 0; j < graph[i].length; j++) {
        graph[i][j] = 0;
      }
    }

    for (int i = 0; i < graph.length; i++) {
      DungeonRoom a = rooms.get(i);
      for (int j = 0; j < graph[i].length; j++) {
        if (i != j) {
          DungeonRoom b = rooms.get(j);
          if (PVector.dist(a.position, b.position) < maxDist) {
            graph[i][j] = -1;
            graph[j][i] = -1;
            graph[i][i]++;
          }
        }
      }
    }

    // Build one spanning tree from the laplacian matrix
    // i.e. find a path that go through all the rooms

    int[][] tree = new int[rooms.size()][rooms.size()];
    for (int i = 0; i < graph.length; i++) {
      for (int j = 0; j < graph[i].length; j++) {
        tree[i][j] = 0;
      }
    }

    int start = int(random(graph.length));
    int end = spanningTree(graph, start, tree);

    // Deform the spanning tree with arbitrary original graph transitions
    // i.e. add a bit of fun

    for (int i = 0; i < graph.length; i++) {
      for (int j = i + 1; j < graph[i].length; j++) {
        if (random(1) < deformPercent) {
          tree[i][j] = (graph[i][j] == -1) ? 1 : 0;
        }
      }
    }

    // Mark start and end rooms

    rooms.get(start).isStart = true;
    rooms.get(end).isEnd = true;

    return tree;
  }

  private int spanningTree(int[][] graph, int v, int[][] tree) {
    int last = v;

    rooms.get(v).visited = true;

    for (int j = 0; j < graph[v].length; j++) {
      if (j != v && graph[v][j] == -1 && !rooms.get(j).visited) {

        // Fill only the up triangle matrix (directed graph)

        if (j > v) {
          tree[v][j] = 1;
        } else {
          tree[j][v] = 1;
        }

        last = spanningTree(graph, j, tree);
      }
    }

    return last;
  }

  private int[][] generateMap(int[][] tree, int mapSize) {

    int[][] map = new int[mapSize][mapSize];
    for (int i = 0; i < map.length; i++) {
      for (int j = 0; j < map[i].length; j++) {
        map[i][j] = 0;
      }
    }

    for (int i = 0; i < tree.length; i++) {
      DungeonRoom a = rooms.get(i);
      for (int j = 0; j < tree[i].length; j++) {
        if (tree[i][j] == 1) {
          DungeonRoom b = rooms.get(j);
          carveCorridor(map, a, b);
        }
      }
    }

    for (DungeonRoom room : rooms) {
      carveRoom(map, room);
    }

    carveBorders(map);

    return map;
  }

  private void carveCorridor(int[][] map, DungeonRoom a, DungeonRoom b) {

    final int x1 = int(a.position.x + a.size.x * 0.5);
    final int y1 = int(a.position.y + a.size.y * 0.5);
    final int x2 = int(b.position.x + b.size.x * 0.5);
    final int y2 = int(b.position.y + b.size.y * 0.5);

    int x = x1;
    int y = y1;

    int sx;
    int sy;

    // First go the direction of the biggest gradient

    int dx = abs(x2 - x);
    int dy = abs(y2 - y);
    if (dx <= dy) {
      sx = (x2 >= x) ? 1 : -1;
      sy = 0;
    } else {
      sx = 0;
      sy = (y2 >= y) ? 1 : -1;
    }

    while (x != x2 && y != y2) {
      map[y][x] = 2;
      x += sx;
      y += sy;
    }

    // Finally go the direction of the lowest gradient

    dx = abs(x2 - x);
    dy = abs(y2 - y);
    if (dx >= dy) {
      sx = (x2 >= x) ? 1 : -1;
      sy = 0;
    } else {
      sx = 0;
      sy = (y2 >= y) ? 1 : -1;
    }

    while (x != x2 || y != y2) {
      map[y][x] = 2;
      x += sx;
      y += sy;
    }
  }

  private void carveRoom(int[][] map, DungeonRoom room) {

    final int x1 = int(room.position.x);
    final int y1 = int(room.position.y);
    final int x2 = x1 + int(room.size.x);
    final int y2 = y1 + int(room.size.y);
    
    for (int i = y1; i < y2; i++) {
      for (int j = x1; j < x2; j++) {
        map[i][j] = 1;
      }
    }
  }

  private void carveBorders(int[][] map) {
    for (int i = 0; i < map.length; i++) {
      for (int j = 0; j < map[i].length; j++) {
        if (i == 0 || j == 0 || i == map.length - 1 || j == map.length - 1) {
          map[i][j] = 0;
        }
      }
    }
  }
}

public class DungeonBuilder
{
  private int numRooms = 10;
  private int roomMinimumSize = 4;
  private int roomMaximumSize = 7;
  private int roomSpacing = 1;
  
  private int spreadIterations = 1000;
  private float spreadMean = 1;
  private float spreadStd = 3;
  private float spreadCohesion = 0.1;
  private float spreadSeparation = 1;
  
  private int adjacentMaximumDistance = 9;
  private float deformationRatio = 0.15;
  
  private int mapSize;
  
  public DungeonBuilder setNumberOfRooms(int numRooms) {
    this.numRooms = numRooms;
    return this;
  }

  public DungeonBuilder setRoomMinimumSize(int roomMinimumSize) {
    this.roomMinimumSize = roomMinimumSize;
    return this;
  }
  
  public DungeonBuilder setRoomMaximumSize(int roomMaximumSize) {
    this.roomMaximumSize = roomMaximumSize;
    return this;
  }
  
  public DungeonBuilder setRoomSpacing(int roomSpacing) {
    this.roomSpacing = roomSpacing;
    return this;
  }
  
  public DungeonBuilder setSpreadIterations(int spreadIterations) {
    this.spreadIterations = spreadIterations;
    return this;
  }
  
  public DungeonBuilder setSpreadMean(float spreadMean) {
    this.spreadMean = spreadMean;
    return this;
  }
  
  public DungeonBuilder setSpreadStd(float spreadStd) {
    this.spreadStd = spreadStd;
    return this;
  }
  
  public DungeonBuilder setSpreadCohesion(float spreadCohesion) {
    this.spreadCohesion = spreadCohesion;
    return this;
  }
  
  public DungeonBuilder setSpreadSeparation(float spreadSeparation) {
    this.spreadSeparation = spreadSeparation;
    return this;
  }
  
  public DungeonBuilder setAdjacentMaximumDistance(int adjacentMaximumDistance) {
    this.adjacentMaximumDistance = adjacentMaximumDistance;
    return this;
  }
  
  public DungeonBuilder setDeformationRatio(float deformationRatio) {
    this.deformationRatio = deformationRatio;
    return this;
  }
  
  public DungeonBuilder setMapSize(int mapSize) {
    this.mapSize = mapSize;
    return this;
  }
  
  public Dungeon build() {
    Dungeon dungeon = new Dungeon();
    dungeon.generate(
      numRooms,
      roomMinimumSize,
      roomMaximumSize,
      roomSpacing,
      spreadIterations,
      spreadMean,
      spreadStd,
      spreadCohesion,
      spreadSeparation,
      adjacentMaximumDistance,
      deformationRatio,
      mapSize);
    return dungeon;
  }
}
