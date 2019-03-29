public int x = 0, y = 152;

class FallingPhysics extends BonePhysics {
  public final static float GFORCE = 9.81;

  public final PVector pivot = new PVector();
  public final PVector speed = new PVector();
  public final int mass = 500;

  public FallingPhysics(PVector p) {
    this.pivot.x = p.x;
    this.pivot.y = p.y;
    this.pivot.z = p.z;
  }

  PVector applyForces(PVector v, float dt) {
    // Calculate new position with Newton equations: a = -mg
    float a = -this.mass * GFORCE;
    this.speed.y += a * dt;
    v.x = this.pivot.x;
    v.y += this.speed.y * dt;
    v.z = this.pivot.z;

    // Collide with floor
    if (v.y < -y) {
      v.y = -y;
      this.speed.y = 0;
    }

    return v;
  }
}

class WalkingPhysics extends BonePhysics {
  public final PVector pivot = new PVector();
  public final PVector speed = new PVector();

  public WalkingPhysics(PVector p, float i) {
    this.pivot.x = p.x;
    this.pivot.y = p.y;
    this.pivot.z = p.z;
    this.speed.y = i;
    this.speed.z = i;
  }

  PVector applyForces(PVector v, float dt) {
    this.speed.y += 8 * dt;
    this.speed.z += 8 * dt;
    v.x = this.pivot.x + sign(this.pivot.x) * Math.max(0, 80 * sin(this.speed.z + HALF_PI));
    v.y = -y + max(0, 40 * cos(this.speed.y));
    v.z = this.pivot.z + sign(this.pivot.z) * 40 * cos(this.speed.z + HALF_PI);

    return v;
  }

  private float sign(float x) {
    if (x < 0) return -1.0;
    return 1.0;
  }
}
