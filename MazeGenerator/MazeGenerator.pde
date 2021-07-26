DungeonBuilder db;
Dungeon dg;

void setup() {
  size(800, 800);
  
  db = new DungeonBuilder()
    .setNumberOfRooms(10)
    .setRoomMinimumSize(4)
    .setRoomMaximumSize(7)
    .setMapSize(24);

  dg = db.build();
}

void draw() {
  
  final float w = width / dg.map.length;

  background(0);
  
  stroke(color(64));
  fill(color(0));
  strokeWeight(1);
  
  for (int i = 0; i < height; i += w) {
    for (int j = 0; j < width; j += w) {
      rect(j, i, w, w);
    }
  }

  for (int i = 0; i < dg.map.length; i++) {
    for (int j = 0; j < dg.map[i].length; j++) {
      if (dg.map[i][j] == 1) {
        fill(color(255));
        rect(j * w, i * w, w, w);
      } else if (dg.map[i][j] == 2) {
        fill(color(128));
        rect(j * w, i * w, w, w);
      }
    }
  }
  
  noFill();
  strokeWeight(4);
  
  for (DungeonRoom room: dg.rooms) {
    if (room.start) {
      stroke(color(0, 0, 255));
    } else if (room.end) {
      stroke(color(0, 255, 0));
    } else {
      stroke(color(255, 0, 0));
    }
    rect(room.position.x * w, room.position.y * w, room.size.x * w, room.size.y * w);
  }
  
  stroke(color(255, 255, 0));
  for (int i = 0; i < dg.graph.length; i++) {
    DungeonRoom a = dg.rooms.get(i);
    for (int j = 0; j < dg.graph[i].length; j++) {
      if (i != j) {
        DungeonRoom b = dg.rooms.get(j);
        if (dg.graph[i][j] == 1) {
          line((a.position.x + a.size.x / 2) * w, (a.position.y + a.size.y / 2) * w,
            (b.position.x + b.size.x / 2) * w, (b.position.y + b.size.y / 2) * w);
        }
      }
    }
  }
}

void keyPressed() {
  dg = db.build();
}
