from java.lang.Math import cos, sin, random, PI
from processing.core import PVector
from RayCaster import Input, Scene, Behavior, matmul
from Globals import ENTITY_DINO, ENTITY_BARREL, STATE_STAND_BY, STATE_MOVE, STATE_HIT, STATE_DEAD

class Dino(Behavior):

	state = STATE_STAND_BY
	life = 100
	justHist = False
	
	def start(self, dino):
		dino.isCollidable = True
		dino.transform.rotation.z = -PI + 2 * PI * random()

	def update(self, dino, dt):

		dino.forces.mult(0);
		dino.forces.add(PVector(0, 0, -9.81));

		if self.state == STATE_STAND_BY:
			self.standBy(dino)
		elif self.state == STATE_MOVE:
			self.move(dino)
		elif self.state == STATE_HIT:
			self.hit(dino)
		elif self.state == STATE_DEAD:
			self.dead(dino)
			
	def damage(self, dino, damage):
		self.life -= max(0, damage - random() * 2)
		if self.life < 0:
			dino.setAnimation(0)
			self.state = STATE_DEAD
			
	def standBy(self, dino):
		target = dino.lookat(Scene.camera, 1, 5, 0)
		if not target is None:
			dino.setAnimation(1)
			self.state = STATE_MOVE

	def move(self, dino):
		target = dino.lookat(Scene.camera, 3, 5, -1);
		if target is None:
			dino.setAnimation(0)
			self.state = STATE_STAND_BY
		elif target.magSq() < 1:
			dino.setAnimation(2)
			self.state = STATE_HIT
		else:
			dino.transform.rotation.z = target.heading()
			dino.forces.add(target.setMag(20))

	def hit(self, dino):
		if dino.getTick() == 3 and not self.justHist:
			heroLife = Scene.globalVariables.get("hero.life")
			heroLife -= max(0, int(random() * 10 - random() * 2))
			Scene.globalVariables.put("hero.life", heroLife)
			self.justHist = True
		elif dino.getTick() == 5:
			dino.setAnimation(1)
			self.justHist = False
			self.state = STATE_MOVE


	def dead(self, dino):
		dino.isVisible = False
		dino.isTrashed = True
  
