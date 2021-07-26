final int ACTION_FORWARD       = (1 << 0);
final int ACTION_BACKWARD      = (1 << 1);
final int ACTION_TURN_RIGHT    = (1 << 2);
final int ACTION_TURN_LEFT     = (1 << 3);
final int ACTION_STRAFE_RIGHT  = (1 << 4);
final int ACTION_STRAFE_LEFT   = (1 << 5);
final int ACTION_SHOOT         = (1 << 6);
final int ACTION_OPEN          = (1 << 7);
final int ACTION_UP            = (1 << 8);
final int ACTION_DOWN          = (1 << 9);
final int ACTION_SHOW_MAP      = (1 << 10);

public class _Input
{
  private int keyPressedMask = 0;

  public void init() {
  }
  
  public boolean isShowMap() {
    if ((keyPressedMask & ACTION_SHOW_MAP) == ACTION_SHOW_MAP) {
      return true;
    }
    return false;
  }
  
  public boolean isShoot() {
    if ((keyPressedMask & ACTION_SHOOT) == ACTION_SHOOT) {
      return true;
    }
    return false;
  }

  public float getRawAxisX() {
    if ((keyPressedMask & ACTION_STRAFE_RIGHT) == ACTION_STRAFE_RIGHT) {
      return 1.0;
    }
    if ((keyPressedMask & ACTION_STRAFE_LEFT) == ACTION_STRAFE_LEFT) {
      return -1.0;
    }
    return 0;
  }

  public float getRawAxisY() {
    if ((keyPressedMask & ACTION_FORWARD) == ACTION_FORWARD) {
      return 1.0;
    }
    if ((keyPressedMask & ACTION_BACKWARD) == ACTION_BACKWARD) {
      return -1.0;
    }
    return 0;
  }

  public float getRawAxisPitch() {
    if ((keyPressedMask & ACTION_UP) == ACTION_UP) {
      return 1.0;
    }
    if ((keyPressedMask & ACTION_DOWN) == ACTION_DOWN) {
      return -1.0;
    }
    return 0;
  }

  public float getRawAxisYaw() {
    if ((keyPressedMask & ACTION_TURN_RIGHT) == ACTION_TURN_RIGHT) {
      return 1.0;
    }
    if ((keyPressedMask & ACTION_TURN_LEFT) == ACTION_TURN_LEFT) {
      return -1.0;
    }
    return 0;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      Input.keyPressedMask |= ACTION_FORWARD;
    } else if (keyCode == DOWN) {
      Input.keyPressedMask |= ACTION_BACKWARD;
    } else  if (keyCode == RIGHT) {
      Input.keyPressedMask |= ACTION_TURN_RIGHT;
    } else  if (keyCode == LEFT) {
      Input.keyPressedMask |= ACTION_TURN_LEFT;
    } else  if (keyCode == CONTROL) {
      Input.keyPressedMask |= ACTION_SHOOT;
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
      Input.keyPressedMask &= ~ACTION_TURN_RIGHT;
    } else if (keyCode == LEFT) {
      Input.keyPressedMask &= ~ACTION_TURN_LEFT;
    } else if (keyCode == CONTROL) {
      Input.keyPressedMask &= ~ACTION_SHOOT;
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
