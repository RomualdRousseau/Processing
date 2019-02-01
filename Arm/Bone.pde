public static final PVector NULLVECTOR = new PVector();
public static final float[] NULLANGLE = {0, 0, 0};

public static final int DOF0 = -1;
public static final int DOFX = 0;
public static final int DOFY = 1;
public static final int DOFZ = 2;

abstract class BonePhysics {
  abstract PVector applyForces(PVector v, float dt);
}

class Bone {
  private Bone parent;
  private Bone child;
  private int dofAxis;
  private boolean tipChanged;
  private PVector tipVector = new PVector();
  
  public int length;
  public float minAngle;
  public float maxAngle;
  public float[] orgAngle = new float[3];
  public float[] gloAngle = new float[3];
  public float[] locAngle = new float[3];

  public Bone() {
    this.parent = null;
    this.child = null;
    this.tipChanged = true;
    this.dofAxis = DOF0;
    
    this.length = 100;
    
    for(int i = 0; i < 3; i++) {
      this.orgAngle[i] = 0;
      this.gloAngle[i] = 0;
      this.locAngle[i] = 0;
    }
    
    this.minAngle = -HALF_PI;
    this.maxAngle = HALF_PI;   
  }
  
  public Bone(Bone parent, int dofAxis, float[] angle, int length) {
    this.parent = parent;
    if(this.parent != null) {
      this.parent.child = this;
    }
    this.tipChanged = true;
    this.dofAxis = dofAxis;
    
    this.length = length;
    
    for(int i = 0; i < 3; i++) {
      this.orgAngle[i] = angle[i];
      this.gloAngle[i] = angle[i];
      this.locAngle[i] = angle[i] - getParentAngle()[i];
    }
    
    if(this.dofAxis != DOF0) {
      float a = angle[dofAxis] - getParentAngle()[dofAxis];
      this.minAngle = a - HALF_PI;
      this.maxAngle = a + HALF_PI;
    }
    else {
      this.minAngle = -HALF_PI;
      this.maxAngle = HALF_PI;
    }
  }
  
  public void reset() {
    for(int i = DOFX; i <= DOFZ; i++) {
      this.gloAngle[i] = this.orgAngle[i];
      this.locAngle[i] = this.orgAngle[i] - getParentAngle()[i];
    }
    this.tipChanged = true;
  }
  
  public float[] getParentAngle() {
    return (this.parent == null) ? NULLANGLE : this.parent.gloAngle;
  }
  
  public PVector getRootVector() {
    return (this.parent == null) ? NULLVECTOR : this.parent.getTipVector();
  }
  
  public PVector getTipVector() {
    ensureTipVectorUpdated();
    return this.tipVector;
  }
  
  public void updatePhysics(BonePhysics bonePhysics, float dt) {
    // Apply force to the tip of the bone
    PVector p = bonePhysics.applyForces(getTipVector().copy(), dt);
    // Update the bone motion
    moveWithIK(p, 1, 0.000001, 100);
  }
  
  public void draw() {
    PVector r = getRootVector();
    ensureTipVectorUpdated();
    
    pushMatrix();
    translate(r.x, -r.y, r.z);
    rotateX(this.gloAngle[0]);
    rotateY(this.gloAngle[1]);
    rotateZ(-this.gloAngle[2]);
    translate(this.length / 2, 0, 0);
    box(this.length, 10, 10);
    popMatrix();
  }
  
  public boolean moveWithIK(PVector goal, int epsilon, float dt, int maxIteration) {
    Bone startBone = null;
    Bone endBone = this;
    int countBones = 0;
    //int maxChainLength = 0;

    // Iterate through the chain to find the start bone, the maximum length and number of bones
    for(Bone e = endBone; e != null && e.dofAxis != DOF0; e = e.parent) {
      startBone = e;
      //maxChainLength += e.length;
      countBones++;
    }
    //goal.limit(maxChainLength);
    
    // Solve IK for the DOF XY iteratively until we are at the goal position
    for (int j = 0; j < maxIteration; j++) {
      PVector effector = endBone.getTipVector();

      PVector de = PVector.sub(goal, effector); //<>//
      if (de.magSq() < epsilon * epsilon) {
        return true;
      }

      // Derivate IK motion matrix
      PMatrix J = calculateJacobian(startBone, endBone, countBones, effector);   
      PMatrix F = calculatePseudoInverse(J);
      PMatrix da = F.mult(new PMatrix(de));

      // Integrate and normalize angles
      int i = 0;
      for(Bone e = startBone; e != endBone.child; e = e.child, i++) {
        e.integrateAndNormalizeAngle(da.data[i][0], dt);
      }
    }
    return false;
  }
  
  private PMatrix calculateJacobian(Bone startBone, Bone endBone, int countBones, PVector effector) {
    PMatrix J = new PMatrix(3, countBones);
    int i = 0;
    for(Bone e = startBone; e != endBone.child; e = e.child, i++) {
      PVector a = new PVector(e.dofAxis == DOFX ? 1 : 0, e.dofAxis == DOFY ? 1 : 0, e.dofAxis == DOFZ ? 1 : 0);
      PVector b = PVector.sub(effector, e.getRootVector());
      PVector r = a.cross(b); 
      J.data[0][i] = r.x;
      J.data[1][i] = r.y;
      J.data[2][i] = r.z;
    }
    return J;
  }
  
  private PMatrix calculatePseudoInverse(PMatrix J) {
    PMatrix JT = J.transpose();
    PMatrix JI = JT;
    // Try to calculate pseudo inverse but not always possible
    //try {
    //  JI = JT.mult(J.mult(JT).inverse()); 
    //}
    //catch(Exception x) {
    //  JI = JT;
    //} 
    return JI;
  }
  
  private void integrateAndNormalizeAngle(float a, float dt) {
    float[] parentAngle = getParentAngle();
    for(int i = DOFX; i <= DOFZ; i++) {
      if(i == this.dofAxis) {
        this.locAngle[i] = constrain(normalizeAngle(this.gloAngle[i] + a * dt - parentAngle[i]), minAngle, maxAngle);
      }
      this.gloAngle[i] = this.locAngle[i] + parentAngle[i];
    }
    this.tipChanged = true;
  }

  private float normalizeAngle(float a) {
    a = a % (float) TWO_PI;
    return (a < -PI) ? TWO_PI + a : (a > PI) ? a - TWO_PI: a;
  }
  
  private void ensureTipVectorUpdated() {
    if(this.tipChanged) {
      PVector rootVector = getRootVector();
      // Prepare transformation matrix
      PMatrix rx = new PMatrix(3, 3); rx.rotateX(this.gloAngle[0]);
      PMatrix ry = new PMatrix(3, 3); ry.rotateY(this.gloAngle[1]);
      PMatrix rz = new PMatrix(3, 3); rz.rotateZ(this.gloAngle[2]);
      PMatrix t = rx.mult(ry).mult(rz);
      // tranfsorm the tip bone in global space
      this.tipVector.x = length * t.data[0][0] + rootVector.x;
      this.tipVector.y = length * t.data[1][0] + rootVector.y;
      this.tipVector.z = length * t.data[2][0] + rootVector.z;
      this.tipChanged = false;
    }
  }
}