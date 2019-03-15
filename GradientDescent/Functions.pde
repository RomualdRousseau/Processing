class Linear_ implements ActivationFunc {
  Matrix apply(Matrix input) {
    return input;
  }

  Matrix derivate(Matrix output, Matrix loss) {
    return loss.copy();
  }
}
Linear_ Linear = new Linear_();

class Sigmoid_ implements ActivationFunc {
  Matrix apply(Matrix input) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        return 1.0 / (1.0 + exp(-x));
      }
    };

    return input.map(fn);
  }

  Matrix derivate(Matrix output, Matrix lossRate) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix matrix) {
        return y * (1.0 - y);
      }
    };

    Matrix m = output.copy();
    Matrix r = m.map(fn).mult(lossRate); 
    return r;
  }
}
Sigmoid_ Sigmoid = new Sigmoid_();

class Tanh_ implements ActivationFunc {
  Matrix apply(Matrix input) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        return tanh(x);
      }
    };
    return input.map(fn);
  }

  Matrix derivate(Matrix output, Matrix lossRate) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix matrix) {
        return 1.0 - y * y;
      }
    };

    Matrix m = output.copy();
    Matrix r = m.map(fn).mult(lossRate); 
    return r;
  }
}
Tanh_ Tanh = new Tanh_();

class MeanSquaredError_ implements LossFunc {
  Matrix apply(Matrix output, Matrix target) {
    return target.copy().sub(output).pow(2.0).mult(0.5);
  }

  Matrix derivate(Matrix output, Matrix target) {
    return output.copy().sub(target);
  }
}
MeanSquaredError_ MeanSquaredError = new MeanSquaredError_();

Matrix forward(Matrix input, Matrix W) {
  return activation.apply(W.transform(input));
}

Matrix backward(Matrix input, Matrix output, Matrix lossrate, Matrix G, Matrix W) {
  Matrix error = activation.derivate(output, lossrate);
  G.add(error.transform(input.transpose()));
  return W.transpose().transform(error);
}

public void optimize(Matrix W, Matrix G, Matrix C) {
  final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
    public final Float apply(Float y, int row, int col, Matrix cache) {
      float a = cache.get(row, col);
      return y * lr / sqrt(a + EPSILON);
    }
  };

  C.mult(0.9).add(G.copy().pow(2.0).mult(1.0 - 0.9));

  W.sub(G.copy().map(fn, C));
}
