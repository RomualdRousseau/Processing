private class Voxel
{
  public int x, y, z;
  
  public Voxel(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

private class CastResult
{
  public Voxel  voxel;
  public int    side;
  public float  z;

  public CastResult(Voxel voxel, int side, float gradient) {
    this.voxel = voxel;
    this.side = side;
    this.z = gradient;
  }
}

private CastResult castRay(int[][][] map, PVector location, PVector direction) {

  int voxelX = int(location.x);
  int voxelY = int(location.y);
  int voxelZ = int(location.z);

  // Ray casting (DDA)

  float deltaDistX = 1.0 / abs(direction.x);
  float deltaDistY = 1.0 / abs(direction.y);
  float deltaDistZ = 1.0 / abs(direction.z);

  int stepX = (direction.x < 0) ? -1 : 1;
  int stepY = (direction.y < 0) ? -1 : 1;
  int stepZ = (direction.z < 0) ? -1 : 1;

  float sideDistX = stepX * (voxelX - location.x + (1 + stepX) / 2) * deltaDistX;
  float sideDistY = stepY * (voxelY - location.y + (1 + stepY) / 2) * deltaDistY;
  float sideDistZ = stepZ * (voxelZ - location.z + (1 + stepZ) / 2) * deltaDistZ;

  int hit  = 0;
  int side = 0;
  while (hit == 0) {

    if (sideDistX < sideDistY) {
      if (sideDistX < sideDistZ) {
        sideDistX += deltaDistX;
        voxelX += stepX;
        side = 0;
      } else {
        sideDistZ += deltaDistZ;
        voxelZ += stepZ;
        side = 2;
      }
    } else {
      if (sideDistY < sideDistZ) {
        sideDistY += deltaDistY;
        voxelY += stepY;
        side = 1;
      } else {
        sideDistZ += deltaDistZ;
        voxelZ += stepZ;
        side = 2;
      }
    }

    if (voxelZ < 0 || voxelZ >= map.length
      || voxelY < 0 || voxelY >= map[0].length
      || voxelX < 0 || voxelX >= map[0][0].length) {
      hit = 2;
    } else if (map[voxelZ][voxelY][voxelX] > 0) {
      hit = 1;
    }
  }

  if (hit == 2) {
    return null;
  }

  float z;
  if (side == 0) {
    z = (voxelX - location.x + (1 - stepX) / 2) / direction.x;
  } else if (side == 1) {
    z = (voxelY - location.y + (1 - stepY) / 2) / direction.y;
  } else {
    z = (voxelZ - location.z + (1 - stepZ) / 2) / direction.z;
  }

  return new CastResult(new Voxel(voxelX, voxelY, voxelZ), side, z);
}
