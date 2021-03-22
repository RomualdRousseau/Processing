PImage google_maps;

float latitude = 1.3248292664681482;
float longitude = 103.89291128431127;
int zoom = 15;

void setup()
{
  size(800, 800);
  
  refreshMap();
}

void draw() {
  image(google_maps, 0, 0, width, height);
}


void mouseWheel(MouseEvent event) {
  float e = -event.getCount();
  zoom += e;
  refreshMap();
}

void mouseDragged(MouseEvent event) {
  float dx = (mouseX - pmouseX) * -0.00001;
  float dy = (mouseY - pmouseY) * 0.00001;
  latitude += dy;
  longitude += dx;
}

void mouseReleased() {
  refreshMap();
}

void refreshMap() {
  google_maps = loadImage("http://maps.googleapis.com/maps/api/staticmap?center=" + latitude + "," + longitude + "&size=" + width + "x" + height + "&zoom=" + zoom + "&markers=color:blue%7Clabel:A%7C1.3248292664681482,103.89291128431127&sensor=false&key=AIzaSyBdzWUho8ag7YweMY9Hpu9aOjO1UBoS9Xk", "png");
}
