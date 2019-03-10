float tanh(float x) {
  return (float)Math.tanh(x);
}

Matrix xw_plus_b(Matrix input, Matrix weights, Matrix bias) {
  return weights.transform(input).add(bias);
}

float r_plus_ds(float r, float s) {
  return r + DISCOUNT_RATE * s;
}

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
