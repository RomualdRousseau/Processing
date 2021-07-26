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
		
		moveSpeed = 200 * Input.getRawAxisY()
		moveForce = hero.direction.copy().mult(moveSpeed)
		
		strafeSpeed = 200 * Input.getRawAxisX()
		strafeForce = hero.direction.cross(hero.up).mult(strafeSpeed)
		
		hero.forces.mult(0)
		hero.forces.add(gravityForce)
		hero.forces.add(moveForce)
		hero.forces.add(strafeForce)

		pitchSpeed = Input.getRawAxisPitch()
		c = cos(pitchSpeed * dt)
		s = sin(pitchSpeed * dt)
		rotationX = [
			[ 1, 0,  0 ],
			[ 0, c, -s ],
			[ 0, s,  c ]
		]
		hero.direction = matmul(hero.direction, rotationX)

		yawSpeed = 3 * Input.getRawAxisYaw()
		c = cos(yawSpeed * dt)
		s = sin(yawSpeed * dt)
		rotationZ = [
			[ c, -s, 0 ],
			[ s,  c, 0 ],
			[ 0,  0, 1 ]
		]
		hero.direction = matmul(hero.direction, rotationZ)

		hero.transform.rotation.z = hero.direction.heading()
		
		if Input.isShoot():
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

