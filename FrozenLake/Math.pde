float[] oneHot(int i, int n) {
  float[] state = new float[n];
  state[i] = 1.0;
  return state;
}

int argmax(float[] v) {
  int result = 0;
  float maxValue = v[0];
  for (int i = 1; i < v.length; i++) {
    if (v[i] > maxValue) {
      maxValue = v[i];
      result = i;
    }
  }
  return result;
}
