interface LearningRateScheduler {
  void adapt(Optimizer optimizer, float epoch);
}

class TimeBasedScheduler implements LearningRateScheduler {
  float decay;
  
  public TimeBasedScheduler(float decay) {
    this.decay = decay;
  }
  
  public void adapt(Optimizer optimizer, float epoch) {
    optimizer.learningRate *= 1.0 / (1.0 + this.decay * epoch);
  }
}

class ExponentialScheduler implements LearningRateScheduler {
  float decay;
  
  public ExponentialScheduler(float decay) {
    this.decay = decay;
  }
  
  public void adapt(Optimizer optimizer, float epoch) {
    optimizer.learningRate = optimizer.learningRate0 * exp(-this.decay * epoch);
  }
}
