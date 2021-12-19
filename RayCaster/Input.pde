final int ACTION_FORWARD         = (1 << 0);
final int ACTION_BACKWARD        = (1 << 1);
final int ACTION_TURN_RIGHT      = (1 << 2);
final int ACTION_TURN_LEFT       = (1 << 3);
final int ACTION_STRAFE_RIGHT    = (1 << 4);
final int ACTION_STRAFE_LEFT     = (1 << 5);
final int ACTION_FIRE            = (1 << 6);
final int ACTION_OPEN            = (1 << 7);
final int ACTION_LOOK_UP         = (1 << 8);
final int ACTION_LOOKP_DOWN      = (1 << 9);
final int ACTION_SHOW_MAP        = (1 << 10);

public class _Input
{
  private int keyPressedMask = 0;
  private boolean needMouseWarp = false;
  
  public void init() {
    com.jogamp.newt.opengl.GLWindow r= (com.jogamp.newt.opengl.GLWindow) surface.getNative();
    r.setPointerVisible(false);
    r.warpPointer(width/2, height/2);
    r.confinePointer(true);
  }
  
  public void update() {
    if (needMouseWarp) {
      com.jogamp.newt.opengl.GLWindow win = (com.jogamp.newt.opengl.GLWindow) surface.getNative();
      win.warpPointer(int(width * 0.5), int(height * 0.5));
      needMouseWarp = false;
    }
  }
  
  public boolean getShowMap() {
    if ((this.keyPressedMask & ACTION_SHOW_MAP) == ACTION_SHOW_MAP) {
      return true;
    }
    return false;
  }
  
  public boolean getFire() {
    if ((this.keyPressedMask & ACTION_FIRE) == ACTION_FIRE) {
      this.keyPressedMask &= ~ACTION_FIRE;
      return true;
    }
    return false;
  }

  public float getAxisHorizontal() {
    if ((this.keyPressedMask & ACTION_STRAFE_RIGHT) == ACTION_STRAFE_RIGHT) {
      return 1.0;
    }
    if ((this.keyPressedMask & ACTION_STRAFE_LEFT) == ACTION_STRAFE_LEFT) {
      return -1.0;
    }
    return 0;
  }
  
  public float getAxisVertical() {
    if ((this.keyPressedMask & ACTION_FORWARD) == ACTION_FORWARD) {
      return 1.0;
    }
    if ((this.keyPressedMask & ACTION_BACKWARD) == ACTION_BACKWARD) {
      return -1.0;
    }
    return 0;
  }
  
  public float getAxisMouseX() {

    float delta = mouseX - width * 0.5;
    if(abs(delta) < 2) {
      return 0;
    }
    
    needMouseWarp = true;

    return 0.1 * delta;
  }

  public float getAxisMouseY() {
    
    float delta = mouseY - height * 0.5;
    if(abs(delta) < 2) {
      return 0;
    }
    
    needMouseWarp = true;

    return -0.1 * delta;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      Input.keyPressedMask |= ACTION_FORWARD;
    } else if (keyCode == DOWN) {
      Input.keyPressedMask |= ACTION_BACKWARD;
    } else  if (keyCode == RIGHT) {
      Input.keyPressedMask |= ACTION_STRAFE_RIGHT;
    } else  if (keyCode == LEFT) {
      Input.keyPressedMask |= ACTION_STRAFE_LEFT;
    } else  if (keyCode == CONTROL) {
      Input.keyPressedMask |= ACTION_FIRE;
    }
  } else {
    if (key == 'w' || key == 'W') {
      Input.keyPressedMask |= ACTION_FORWARD;
    } else if (key == 's' || key == 'S') {
      Input.keyPressedMask |= ACTION_BACKWARD;
    } else  if (key == 'd' || key == 'D') {
      Input.keyPressedMask |= ACTION_STRAFE_RIGHT;
    } else  if (key == 'a' || key == 'A') {
      Input.keyPressedMask |= ACTION_STRAFE_LEFT;
    } else if (key == ' ') {
      Input.keyPressedMask |= ACTION_OPEN;
    } else if (key == TAB) {
      Input.keyPressedMask |= ACTION_SHOW_MAP;
    } else if (keyCode == com.jogamp.newt.event.KeyEvent.VK_F1) {
      ScriptFactory.reload();
      Scene.reload();
      System.gc();
      Scene.start();
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      Input.keyPressedMask &= ~ACTION_FORWARD;
    } else if (keyCode == DOWN) {
      Input.keyPressedMask &= ~ACTION_BACKWARD;
    } else if (keyCode == RIGHT) {
      Input.keyPressedMask &= ~ACTION_STRAFE_RIGHT;
    } else if (keyCode == LEFT) {
      Input.keyPressedMask &= ~ACTION_STRAFE_LEFT;
    }
  } else {
    if (key == 'w' || key == 'W') {
      Input.keyPressedMask &= ~ACTION_FORWARD;
    } else if (key == 's' || key == 'S') {
      Input.keyPressedMask &= ~ACTION_BACKWARD;
    } else if (key == 'd' || key == 'D') {
      Input.keyPressedMask &= ~ACTION_STRAFE_RIGHT;
    } else if (key == 'a' || key == 'A') {
      Input.keyPressedMask &= ~ACTION_STRAFE_LEFT;
    } else if (key == ' ') {
      Input.keyPressedMask &= ~ACTION_OPEN;
    } else if (key == TAB) {
      Input.keyPressedMask &= ~ACTION_SHOW_MAP;
    }
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    Input.keyPressedMask |= ACTION_FIRE;
  }
}
