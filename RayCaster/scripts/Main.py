from RayCaster import Behavior, Input, ScriptFactory, DungeonBuilder, Sprite, AnimatedSprite
from processing.core import PVector
from jarray import array
from java.lang import Class
from java.lang.Math import random
from Globals import MAP_SIZE, ENTITY_THING, ENTITY_BARREL, ENTITY_DINO

class Main(Behavior):

	def start(self, scene):
	
		scene.globalVariables.put("hero.life", 100)
		scene.globalVariables.put("hero.gold", 0)
		
		# Load few textures
	
		scene.addTexture("data/wall_brick1.png")
		scene.addTexture("data/wall_brick2.png")
		scene.addTexture("data/wall_bizarre.png")
		scene.addTexture("data/wall_rock1.png")
		scene.addTexture("data/wall_rock2.png")
		scene.addTexture("data/wall_rock4.png")
		scene.addTexture("data/wall_wood.png")
		scene.addTexture("data/wall_rock3.png")
		scene.addTexture("data/sprite_barrel.png")
		scene.addTexture("data/sprite_column.png")
		scene.addTexture("data/sprite_lamp.png")
		scene.addTexture("data/sprite_dino.png")
		
		# Generate a dungeon
		
		dungeon = DungeonBuilder(scene.applet)	\
			.setNumberOfRooms(10)		\
			.setRoomMinimumSize(4)	\
			.setRoomMaximumSize(7)	\
			.setMapSize(MAP_SIZE)		\
			.build()
		
		objectMap = [[[8 for j in range(0, MAP_SIZE)] for i in range(0, MAP_SIZE)] for k in range(0, 3)]
		for i in range(0, MAP_SIZE):
			for j in range(0, MAP_SIZE):
				objectMap[1][i][j] = 0 if dungeon.baseMap[i][j] > 0 else 4
		scene.map = array(objectMap, Class.forName("[[I"))
		
		# Fake light maps with a convolution and an exponantial average
		
		shadowMap = [[[5 for j in range(0, MAP_SIZE)] for i in range(0, MAP_SIZE)] for k in range(0, 3)]
		for i in range(0, MAP_SIZE):
			for j in range(0, MAP_SIZE):
				shadowMap[0][i][j] = 7 if dungeon.baseMap[i][j] == 1 else 3 if dungeon.baseMap[i][j] == 2 else 5
				shadowMap[2][i][j] = shadowMap[0][i][j]
		for i in range(1, MAP_SIZE - 1):
			for j in range(1, MAP_SIZE - 1):
				shadowMap[1][i - 1][j - 1] = int(shadowMap[1][i - 1][j - 1] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i    ][j - 1] = int(shadowMap[1][i    ][j - 1] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i + 1][j - 1] = int(shadowMap[1][i + 1][j - 1] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i - 1][j    ] = int(shadowMap[1][i - 1][j    ] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i    ][j    ] = int(shadowMap[1][i    ][j    ] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i + 1][j    ] = int(shadowMap[1][i + 1][j    ] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i - 1][j + 1] = int(shadowMap[1][i - 1][j + 1] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i    ][j + 1] = int(shadowMap[1][i    ][j + 1] * 0.5 + shadowMap[0][i][j] * 0.5)
				shadowMap[1][i + 1][j + 1] = int(shadowMap[1][i + 1][j + 1] * 0.5 + shadowMap[0][i][j] * 0.5)    
		scene.shadowMap = array(shadowMap, Class.forName("[[I"))

		# Setup the camera
    
		scene.camera.transform.location = PVector(0.5, 0.5, 1.5).add(dungeon.getStartRoom().position)
		scene.camera.direction = PVector(1, 1, 0).normalize()
		scene.camera.behaviors.add(ScriptFactory.newInstance("Hero"))
		
		# Generate furnitures
    
		for room in dungeon.rooms:
		
			# Place lamps
      
			x = room.position.x + room.size.x * 0.5
			y = room.position.y + room.size.y * 0.5
			scene.sprites.add(Sprite(None, ENTITY_THING, x, y, 1.5, 10))
			
			# Place barrels
      
			if random() < 0.5:
				n = int(random() * 3 + 1)
				for i in range(0, n):
					xx = random() * (room.size.x - 1) + room.position.x + 0.5
					yy = random() * (room.size.y - 1) + room.position.y + 0.5
					scene.sprites.add(Sprite(None, ENTITY_BARREL, xx, yy, 1.5, 8))
					
			# Place columns

			if random() < 0.5 and room.size.x >= 4 and room.size.y >= 4:
				scene.sprites.add(Sprite(scene.applet, ENTITY_THING, room.position.x + 1, room.position.y + 1, 1.5, 9))
				scene.sprites.add(Sprite(scene.applet, ENTITY_THING, room.position.x + room.size.x - 1, room.position.y + 1, 1.5, 9))
				scene.sprites.add(Sprite(scene.applet, ENTITY_THING, room.position.x + room.size.x - 1, room.position.y + room.size.y - 1, 1.5, 9))
				scene.sprites.add(Sprite(scene.applet, ENTITY_THING, room.position.x + 1, room.position.y + room.size.y - 1, 1.5, 9))

			# Generate enemies
    
			if not room.isStart:
				n = int(random() * 4 + 1)
				for i in range(0, n):
					xx = random() * (room.size.x - 1) + room.position.x + 0.5
					yy = random() * (room.size.y - 1) + room.position.y + 0.5
					dino = AnimatedSprite(scene.applet, ENTITY_DINO, xx, yy, 1.5, 11, [ [ 0, 0, 10 ], [ 0, 6, 10 ], [ 0, 6, 5 ] ])
					dino.behaviors.add(ScriptFactory.newInstance("Dino"))
					scene.sprites.add(dino)

	def update(self, scene, dt):
		pass
