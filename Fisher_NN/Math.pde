float tanh(float x) {
  return (float)Math.tanh(x);
}

public Matrix xw_plus_b(Matrix input, Matrix weights, Matrix bias) {
    return weights.transform(input).add(bias);
  }
