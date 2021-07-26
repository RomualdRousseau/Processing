private class HUD
{
  private int getHeroLife() {
    return (int) Scene.globalVariables.get("hero.life");
  }
  
  private int getHeroGold() {
    return (int) Scene.globalVariables.get("hero.gold");
  }
  
  private boolean isVisited(int i, int j) {
    return ((boolean[][]) Scene.globalVariables.get("map.visited"))[i][j];
  }
  
  public void draw() {
    final float w = width / Scene.map[1].length;
    final float h = height / Scene.map[1].length;
    
    fill(0, 255, 0);
    text(int(frameRate) + " fps", 0, 15);
    text("Life: " + getHeroLife(), 100, 15);
    text("Gold: " + getHeroGold(), 200, 15);

    if (Input.isShowMap()) {

      stroke(64, 64, 64, 128);
      fill(64, 64, 64, 128);
      for (int i = 0; i < Scene.map[1].length; i++) {
        for (int j = 0; j < Scene.map[1][i].length; j++) {
          if (Scene.map[1][i][j] == 0) {
            rect(j * w, i * h, w, h);
          }
        }
      }

      for (Sprite sprite : Scene.sprites) {
        if (sprite instanceof AnimatedSprite) {
          stroke(128, 0, 0);
          fill(255, 0, 0);
          pushMatrix();
          translate(sprite.transform.location.x * w, sprite.transform.location.y * h);
          rotate(sprite.transform.rotation.z + PI/2);
          triangle(0, -5, 2.5, 5, -2.5, 5);
          popMatrix();
        } else {
          stroke(128, 128, 0);
          fill(255, 255, 0);
          circle(sprite.transform.location.x * w, sprite.transform.location.y * h, 5);
        }
      }
      
      stroke(128, 128, 128, 128);
      fill(255, 255, 255, 128);
      for (int i = 0; i < Scene.map[1].length; i++) {
        for (int j = 0; j < Scene.map[1][i].length; j++) {
          if (Scene.map[1][i][j] == 0 && isVisited(i, j)) {
            rect(j * w, i * h, w, h);
          }
        }
      }

      stroke(0, 128, 0);
      fill(0, 255, 0);
      pushMatrix();
      translate(Scene.camera.transform.location.x * w, Scene.camera.transform.location.y * h);
      rotate(Scene.camera.direction.heading() + PI/2);
      triangle(0, -5, 2.5, 5, -2.5, 5);
      popMatrix();
    }
  }
}