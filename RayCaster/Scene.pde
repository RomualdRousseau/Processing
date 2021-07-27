public final static int textureWidth = 64;
public final static int textureHeight = 64;

public final static PVector[] normals = {
  new PVector(-1, 0, 0),
  new PVector( 1, 0, 0),
  new PVector( 0, -1, 0),
  new PVector( 0, 1, 0),
  new PVector( 0, 0, -1),
  new PVector( 0, 0, 1)
};

private class SpriteOrder implements Comparable<SpriteOrder>
{
  public Sprite sprite;
  public PVector transform;
  public float distance;

  public int compareTo(SpriteOrder b) {
    return (this.distance - b.distance) < 0 ? -1 : 1;
  }
}

public class _Scene extends Entity
{
  private PImage frameBuffer;
  private float[][] zbuffer;

  public PApplet applet;

  public int[][][] map;
  public int[][][] shadowMap;
  public boolean[][][] visitedVoxels;
  public PVector environmentLight = new PVector(0, -1, 0);
  public float environmentLightMin = 0.7;
  public float environmentLightMax = 1.0;

  public ArrayList<PImage> textures;
  public ArrayList<Sprite> sprites;
  public HashMap<String, Object> globalVariables;

  public Camera camera;

  public _Scene(PApplet applet) {
    this.applet = applet;
  }

  public void init(int w, int h) {
    this.frameBuffer = createImage(w, h, RGB);
    this.zbuffer = new float[w][h];
    this.reload();
    this.behaviors.add(ScriptFactory.newInstance("Main"));
  }

  public void reload() {
    this.map = null;
    this.shadowMap = null;
    this.visitedVoxels = null;
    this.textures = new ArrayList<PImage>();
    this.sprites = new ArrayList<Sprite>();
    this.globalVariables = new HashMap<String, Object>();

    this.camera = new Camera();
  }

  public _Scene getScene() {
    return (_Scene) this;
  }

  public void addTexture(String fileName) {
    this.textures.add(loadImage(fileName));
  }

  public void start() {
    super.start();

    for (Sprite sprite : this.sprites) {
      sprite.parent = this;
      sprite.start();
    }

    this.camera.parent = this;
    this.camera.start();
    
    this.visitedVoxels = new boolean[this.map.length][this.map[0].length][this.map[0][0].length];
    //for (int k = 0; k < this.visitedVoxels.length; k++) {
    //  for (int i = 0; i < this.visitedVoxels[k].length; i++) {
    //    for (int j = 0; j < this.visitedVoxels[k][i].length; j++) {
    //      this.visitedVoxels[k][i][j] = false;
    //    }
    //  }
    //}
  }

  public void update(float dt) {
    super.update(dt);

    for (Sprite sprite : this.sprites) {
      sprite.update(dt);
    }

    this.camera.update(dt);

    for (int i = this.sprites.size() -1; i >= 0; i--) {
      Sprite sprite = this.sprites.get(i);
      if (sprite.isTrashed) {
        this.sprites.remove(i);
      }
    }
    
    this.updateVisitedVoxels();
  }

  public int collide(Entity entity) {
    int result = 0;

    for (PVector step : normals) {

      int voxelX = int(entity.transform.location.x) + int(step.x);
      int voxelY = int(entity.transform.location.y) + int(step.y);
      int voxelZ = int(entity.transform.location.z) + int(step.z);

      if (voxelZ >= 0 && voxelZ < map.length
        && voxelY >= 0 && voxelY < map[0].length
        && voxelX >= 0 && voxelX < map[0][0].length
        && map[voxelZ][voxelY][voxelX] > 0) {

        float colX = int(entity.transform.location.x) + int((step.x + 1) / 2) - entity.transform.location.x;
        float colY = int(entity.transform.location.y) + int((step.y + 1) / 2) - entity.transform.location.y;
        float colZ = int(entity.transform.location.z) + int((step.z + 1) / 2) - entity.transform.location.z;

        float d = abs(colX * step.x + colY * step.y + colZ * step.z);
        float r = abs(entity.bbox.x * step.x + entity.bbox.y * step.y + entity.bbox.z * step.z);
        if (d < r) {
          float forceMag = r - d;
          PVector force = step.copy().mult(forceMag);
          entity.transform.location.sub(force);
          result |= 1;
        }
      }

      result <<= 1;
    }

    return result >> 1;
  }

  public void draw() {

    float[][] lookAtMatrix = this.camera.getLookAtMatrix();
    float[][] invLookAtMatrix = inv(lookAtMatrix);

    SpriteOrder[] spriteOrders = new SpriteOrder[this.sprites.size()];
    for (int i = 0; i < spriteOrders.length; i++) {
      PVector relSpriteLoc = PVector.sub(this.sprites.get(i).transform.location, this.camera.transform.location);
      spriteOrders[i] = new SpriteOrder();
      spriteOrders[i].sprite = this.sprites.get(i);
      spriteOrders[i].transform = matmul(relSpriteLoc, invLookAtMatrix);
      spriteOrders[i].distance = relSpriteLoc.magSq();
    }
    java.util.Arrays.sort(spriteOrders);

    this.frameBuffer.loadPixels();

    for (int y = 0; y < this.frameBuffer.height; y++) {
      for (int x = 0; x < this.frameBuffer.width; x++) {

        PVector rayDir = new PVector(
          camera.focal.x * (2.0 * float(x) / float(frameBuffer.width) - 1.0),
          1.0f,
          camera.focal.y * (2.0 * float(y) / float(frameBuffer.height) - 1.0));

        color pixel = rayCastSprite(spriteOrders, x, y, rayDir, castRayWall(x, y, matmul(rayDir, lookAtMatrix)));
        this.frameBuffer.pixels[y * frameBuffer.width + x] = pixel;
      }
    }

    this.frameBuffer.updatePixels();

    image(this.frameBuffer, 0, 0, width, height);
  }

  private color castRayWall(int x, int y, PVector rayDir) {

    CastResult result = castRay(map, this.camera.transform.location, rayDir);
    if (result == null) {
      this.zbuffer[x][y] = 1000;
      return color(0, 128, 255);
    }

    this.zbuffer[x][y] = result.z;

    PVector uvmap;
    if (result.side == 0) {
      uvmap = new PVector(this.camera.transform.location.y + rayDir.y * result.z, this.camera.transform.location.z + rayDir.z * result.z, 0);
    } else if (result.side == 1) {
      uvmap = new PVector(this.camera.transform.location.x + rayDir.x * result.z, this.camera.transform.location.z + rayDir.z * result.z, 0);
    } else {
      uvmap = new PVector(this.camera.transform.location.x + rayDir.x * result.z, this.camera.transform.location.y + rayDir.y * result.z, 0);
    }
    uvmap.x = uvmap.x - floor(uvmap.x);
    if (uvmap.x < 0) {
      uvmap.x = 1.0 - uvmap.x;
    }
    uvmap.y = 1.0 - (uvmap.y - floor(uvmap.y));
    if (uvmap.y < 0) {
      uvmap.y = 1.0 - uvmap.y;
    }

    PVector normal;
    if (result.side == 0) {
      if (rayDir.x < 0) {
        normal = normals[0];
      } else {
        normal = normals[1];
      }
    } else if (result.side == 1) {
      if (rayDir.y < 0) {
        normal = normals[2];
      } else {
        normal = normals[3];
      }
    } else {
      if (rayDir.z < 0) {
        normal = normals[4];
      } else {
        normal = normals[5];
      }
    }

    PImage wallTexture = this.textures.get(map[result.voxel.z][result.voxel.y][result.voxel.x] - 1);
    int texX = int(uvmap.x * float(textureWidth)) & (textureWidth - 1);
    int texY = int(uvmap.y * float(textureHeight)) & (textureHeight - 1);
    color diffuse = wallTexture.pixels[wallTexture.width * texY + texX];

    float shading = map(this.shadowMap[result.voxel.z][result.voxel.y][result.voxel.x], 0, 9, 0, 1.0);
    shading *= map(max(this.environmentLight.dot(normal), 0), 0, 1.0, this.environmentLightMin, this.environmentLightMax);

    return lerpColor(color(0), diffuse, shading);
  }

  private color rayCastSprite(SpriteOrder[] spriteOrders, int x, int y, PVector rayDir, color background) {

    float deltaDistY = 1.0 / abs(rayDir.y);

    for (int i = 0; i < min(10, spriteOrders.length); i++) {
      Sprite sprite = spriteOrders[i].sprite;

      PVector transform = spriteOrders[i].transform;
      if (!sprite.isVisible || transform.y <= 0 || transform.y >= zbuffer[x][y]) {
        continue;
      }

      PVector cp = PVector.mult(rayDir, transform.y * deltaDistY);
      PVector face = PVector.sub(cp, transform);
      float hit = max(abs(face.x) - 0.5, abs(face.z) - 0.5);
      if (hit >= 0) {
        continue;
      }

      PImage spriteTexture = this.textures.get(sprite.texture);
      int texX = (int((face.x + 0.5) * float(textureWidth)) & (textureWidth - 1)) + sprite.textureOffsetX;
      int texY = (int((face.z + 0.5) * float(textureHeight)) & (textureHeight - 1)) + sprite.textureOffsetY;
      color diffuse = spriteTexture.pixels[spriteTexture.width * texY + texX];
      if (alpha(diffuse) == 0) {
        continue;
      }

      float shading = 0;
      int voxelX = int(sprite.transform.location.x);
      int voxelY = int(sprite.transform.location.y);
      int voxelZ = int(sprite.transform.location.z);
      if (voxelZ >= 0 && voxelZ < this.shadowMap.length
        && voxelY >= 0 && voxelY < this.shadowMap[0].length
        && voxelX >= 0 && voxelX < this.shadowMap[0][0].length) {
        shading = map(this.shadowMap[voxelZ][voxelY][voxelX], 0, 9, 0, 1.0);
      }

      return lerpColor(color(0), diffuse, shading);
    }

    return background;
  }
  
  private void updateVisitedVoxels() {
    int k = int(this.camera.transform.location.z);
    for (int i = max(int(this.camera.transform.location.y) - 2, 0); i <= min(int(this.camera.transform.location.y) + 2, this.visitedVoxels[k].length); i++) {
      for (int j = max(int(this.camera.transform.location.x) - 2, 0); j <= min(int(this.camera.transform.location.x) + 2, this.visitedVoxels[k][i].length); j++) {
        this.visitedVoxels[k][i][j] = true;
      }
    }
  }
}
