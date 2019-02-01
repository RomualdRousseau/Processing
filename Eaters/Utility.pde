int argmax(float[] v) {
  float maxValue = v[0];
  int maxIndex = 0;
  for(int i  = 1; i < v.length; i++) {
    if(v[i] > maxValue) {
      maxValue = v[i];
      maxIndex = i;
    }
  }
  return maxIndex;
}

void softmax(float[] v) {
  float sum = 0.0;
  for(int i  = 1; i < v.length; i++) {
    sum += exp(v[i]);
  }
  for(int i  = 1; i < v.length; i++) {
    v[i] = exp(v[i]) / sum;
  }
}
