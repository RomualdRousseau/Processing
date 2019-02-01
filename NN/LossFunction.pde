interface LossFunction {
  Matrix apply(Matrix output, Matrix target);
}

class MeanSquaredErrorFunction implements LossFunction {
  public Matrix apply(Matrix output, Matrix target) {
    return target.copy().sub(output);
  }
}
