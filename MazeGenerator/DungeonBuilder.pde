class DungeonBuilder
{
  int numRooms = 10;
  int roomMinimumSize = 4;
  int roomMaximumSize = 7;
  int roomSpacing = 1;
  
  int spreadIterations = 1000;
  float spreadMean = 1;
  float spreadStd = 3;
  float spreadCohesion = 0.1;
  float spreadSeparation = 1;
  
  int adjacentMaximumDistance = 9;
  float deformationRatio = 0.15;
  
  int mapSize;
  
  DungeonBuilder setNumberOfRooms(int numRooms) {
    this.numRooms = numRooms;
    return this;
  }

  DungeonBuilder setRoomMinimumSize(int roomMinimumSize) {
    this.roomMinimumSize = roomMinimumSize;
    return this;
  }
  
  DungeonBuilder setRoomMaximumSize(int roomMaximumSize) {
    this.roomMaximumSize = roomMaximumSize;
    return this;
  }
  
  DungeonBuilder setRoomSpacing(int roomSpacing) {
    this.roomSpacing = roomSpacing;
    return this;
  }
  
  DungeonBuilder setSpreadIterations(int spreadIterations) {
    this.spreadIterations = spreadIterations;
    return this;
  }
  
  DungeonBuilder setSpreadMean(float spreadMean) {
    this.spreadMean = spreadMean;
    return this;
  }
  
  DungeonBuilder setSpreadStd(float spreadStd) {
    this.spreadStd = spreadStd;
    return this;
  }
  
  DungeonBuilder setSpreadCohesion(float spreadCohesion) {
    this.spreadCohesion = spreadCohesion;
    return this;
  }
  
  DungeonBuilder setSpreadSeparation(float spreadSeparation) {
    this.spreadSeparation = spreadSeparation;
    return this;
  }
  
  DungeonBuilder setAdjacentMaximumDistance(int adjacentMaximumDistance) {
    this.adjacentMaximumDistance = adjacentMaximumDistance;
    return this;
  }
  
  DungeonBuilder setDeformationRatio(float deformationRatio) {
    this.deformationRatio = deformationRatio;
    return this;
  }
  
  DungeonBuilder setMapSize(int mapSize) {
    this.mapSize = mapSize;
    return this;
  }
  
  Dungeon build() {
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
