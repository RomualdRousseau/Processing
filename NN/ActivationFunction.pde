abstract class ActivationFunction {
  Function<Float, Float> apply;
  Function<Float, Float> derivate;
}

class LinearActivationFunction extends ActivationFunction {
  public LinearActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return x;
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return 1.0;
      }
    };
  }
}

class SigmoidActivationFunction extends ActivationFunction {
  public SigmoidActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return 1.0 / (1.0 + exp(-x));
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return y * (1.0 - y);
      }
    };
  }
}

class TanhActivationFunction extends ActivationFunction {
  public TanhActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return (exp(x) - exp(-x)) / (exp(x) + exp(-x));
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return 1.0 - y * y;
      }
    };
  }
}

class ReluActivationFunction extends ActivationFunction {
  public ReluActivationFunction() {
    this.apply = new Function<Float, Float>() {
      public final Float apply(Float x) {
        return max(0.0, x);
      }
    };
    this.derivate = new Function<Float, Float>() {
      public final Float apply(Float y) {
        return (y <= 0.0) ? 0.0 : 1.0;
      }
    };
  }
}
