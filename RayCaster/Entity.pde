public class Transform
{
  public PVector location = new PVector(0, 0, 0);
  public PVector rotation = new PVector(0, 0, 0);
}

public abstract class Entity
{
  public int id = 0;
  
  public Entity parent = null;
  
  public Transform transform = new Transform();
  
  public PVector bbox = new PVector(0.25, 0.25, 0.5);
  
  public ArrayList<Behavior> behaviors = new ArrayList<Behavior>();

  public boolean isCollidable = false;
  public int collisionMask = 0;
  
  public boolean isVisible = true;
  public boolean isTrashed = false;
  
  public _Scene getScene() {
    if (this.parent == null) {
      return (_Scene) this;
    }
    else if (this.parent instanceof _Scene) {
      return (_Scene) this.parent;
    } else {
      return this.parent.getScene();
    }
  }
  
  public Behavior findBehavior(String behaviorName) {
    for(Behavior b: this.behaviors) {
      if (b.getClass().getSimpleName().startsWith(behaviorName + "$")) {
        return b;
      }
    }
    return null;
  }
  
  public void start() {
    try {
      for(Behavior b: this.behaviors) {
        b.start(this);
      }
    }
    catch(PyException x) {
      x.printStackTrace();
    }
  }
  
  public void update(float dt) {
    try {
      if (this.isCollidable) {
        this.collisionMask = this.parent.collide(this);
      }
      for(Behavior b: this.behaviors) {
        b.update(this, dt);
      }
    }
    catch(PyException x) {
      x.printStackTrace();
    }
  }
  
  public int collide(Entity other) {
    PVector v = PVector.sub(other.transform.location, this.transform.location);
    float d = v.mag();
    if (d >= 1) {
      return 0;
    }
    
    float forceMag = (1 - d) * 0.5;
    PVector force = v.setMag(forceMag);
    
    this.transform.location.sub(force);
    other.transform.location.add(force); 
    
    return 0x6F;
  }
  
  public PVector lookat(Entity entity, float minimumDistance, float maximumDistance, float vision) {
    PVector lookat = PVector.fromAngle(this.transform.rotation.z);
    
    PVector target = PVector.sub(entity.transform.location, this.transform.location);
    float distanceWithTarget = target.magSq();

    if(distanceWithTarget < minimumDistance * minimumDistance) {
      return target;
    }
    else if(distanceWithTarget < maximumDistance * maximumDistance && lookat.dot(target) > vision) {
      
      PVector normTarget = target.copy().normalize();
      CastResult result = castRay(this.getScene().map, this.transform.location, normTarget);
      float distancewithNearestWall = PVector.mult(normTarget, result.z).magSq();
      
      if(distanceWithTarget < distancewithNearestWall) { 
        return target;
      }
    }
    
    return null;
  }
  
  public Entity acquireNearestTarget(ArrayList<Sprite> entities, float minimumDistance, float maximumDistance, float vision) {
    Entity acquireTarget = null;
    
    float min = maximumDistance;
    for (Entity entity : entities) {
      if (entity.id == 0) {
        continue;
      }
      
      PVector target = this.lookat(entity, minimumDistance, maximumDistance, vision);
      if (target != null && target.magSq() < min) {
        acquireTarget = entity;
        min = target.magSq();
      }
    }
    
    return acquireTarget;
  }
}
