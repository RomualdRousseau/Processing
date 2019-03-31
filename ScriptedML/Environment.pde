class Observation {
  float reward;
  boolean done;
  boolean async;

  Observation(float reward, boolean done, boolean async) {
    this.reward = reward;
    this.done = done;
    this.async = async;
  }
}

class Environment {
  Portal portal;
  Gun gun;
  Soldier soldier;

  void reset() {
    this.portal = new Portal();
    this.gun = new Gun(this.portal.pos);
    this.soldier = new Soldier();
  }

  boolean busy() {
    if(this.gun.hit(this.soldier.pos)) {
      this.soldier.die();
    }
    this.soldier.update();
    return this.soldier.busy;
  }
  
  Observation getLastObservation() {
    if (this.soldier.reach(this.portal.pos)) {
      return new Observation(1.0, true, false);
    } else {
      return new Observation(-1.0, true, false);
    }
  }

  Observation step(int action) {
    switch(action) {
    case 0:
      println("Do nothing");
      break;
      
    case 1:
      println("Pick up soldier");
      this.soldier.pickedUp = true;
      break;

    case 2:
      println("Unpick soldier");
      this.soldier.pickedUp = false;
      break;

    case 3:
      if (!this.soldier.pickedUp) {
        println("Do nothing");
        action = 0;
      } else {
        println("Move to safe zone");
        PVector a = PVector.sub(this.soldier.pos, this.portal.pos).normalize();
        PVector b = PVector.sub(this.gun.pos, this.portal.pos).normalize();
        PVector c = a.copy();
        this.soldier.moveTo(a.cross(b).cross(c).mult(-0.5));
      }
      break;
      
    case 4:
      if (!this.soldier.pickedUp) {
        println("Do nothing");
        action = 0;
      } else {
        println("Move to random target");
        this.soldier.moveTo(PVector.random2D().mult(random(1)));
      }
      break;

    case 5:
      if (!this.soldier.pickedUp) {
        println("Do nothing");
        action = 0;
      } else {
        println("Move to portal");
        this.soldier.moveTo(this.portal.pos);
      }
      break;
    }
    
    return new Observation(0.0, this.soldier.dead, true);
  }

  void render() {
    background(51); 
    this.portal.show();
    this.gun.show();
    this.soldier.show();
  }
}
