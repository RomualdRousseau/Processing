from java.lang import Class
from java.lang.Math import cos, sin, random
from processing.core import PVector
from RayCaster import Input, Behavior, matmul
from Globals import ENTITY_DINO, ENTITY_BARREL

class Hero(Behavior):

	def __init__(self):
		pass

	def start(self, hero):
		hero.isCollidable = True

	def update(self, hero, dt):

		gravityForce = PVector(0, 0, -9.81)

		direction = PVector.fromAngle(hero.transform.rotation.z)
		
		moveSpeed = 200 * Input.getAxisVertical()
		moveForce = direction.copy().mult(moveSpeed)
		
		strafeSpeed = 200 * Input.getAxisHorizontal()
		strafeForce = direction.cross(hero.up).mult(strafeSpeed)

		pitchSpeed = 2 * Input.getAxisMouseY()
		hero.transform.rotation.x += pitchSpeed * dt

		yawSpeed = 5 * Input.getAxisMouseX()
		hero.transform.rotation.z += yawSpeed * dt

		hero.forces.mult(0)
		hero.forces.add(gravityForce)
		hero.forces.add(moveForce)
		hero.forces.add(strafeForce)
		
		if Input.getFire():
			acquireTarget = hero.acquireNearestTarget(hero.parent.sprites, 0, 1, 0)
			
			if not acquireTarget is None:
			
				if acquireTarget.id == ENTITY_DINO:
					b = acquireTarget.findBehavior("Dino")
					if not b is None:
						b.damage(acquireTarget, int(5 + random() * 10))

				if acquireTarget.id == ENTITY_BARREL:
					if random() < 0.5:
						gold = hero.parent.globalVariables.get("hero.gold")
						gold += int(5 + random() * 10) 
						hero.parent.globalVariables.put("hero.gold", gold)
					else:
						life = hero.parent.globalVariables.get("hero.life")
						life += 10
						hero.parent.globalVariables.put("hero.life", life)
					acquireTarget.isTrashed = True

