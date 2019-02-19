static final int KEY_TRUST = 0;
static final int KEY_TURN_LEFT = 1;
static final int KEY_TURN_RIGHT = 2;
static final int KEY_SHOOT = 3;

boolean[] keys = new boolean[4];

void mapKeys(boolean b) {
  if (key == 'w') {
    keys[KEY_TRUST] = b;
  } else if (key == 'a') {
    keys[KEY_TURN_LEFT] = b;
  } else if (key == 'd') {
    keys[KEY_TURN_RIGHT] = b;
  } else if (key == ' ') {
    keys[KEY_SHOOT] = b;
  }
}
