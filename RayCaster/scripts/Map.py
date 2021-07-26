from RayCaster import Behavior
from jarray import array
from java.lang import Class
from Globals import MAP_SIZE

visited = array([[False for j in range(0, MAP_SIZE)] for i in range(0, MAP_SIZE)], Class.forName("[Z"))

class Map(Behavior):

	def start(self, camera):
		camera.parent.globalVariables.put("map.visited", visited);

	def update(self, camera, dt):
		for i in range(0, MAP_SIZE):
			for j in range(0, MAP_SIZE):
				if abs(camera.transform.location.y - i) < 3 and abs(camera.transform.location.x - j) < 3:
					visited[i][j] = True


