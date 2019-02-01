class NeuralNetwork {
  Layer layer1;
  Layer layer2;
  LossFunction loss;
  Optimizer optimizer;
  LearningRateScheduler learningRateScheduler;
  float epochs;

  public void compile(LossFunction loss, Optimizer optimizer) {
    this.loss = loss;
    this.optimizer = optimizer;
    this.learningRateScheduler = null;
    this.reset();
  }
  
  public void compile(LossFunction loss, Optimizer optimizer, LearningRateScheduler learningRateScheduler) {
    this.loss = loss;
    this.optimizer = optimizer;
    this.learningRateScheduler = learningRateScheduler;
    this.reset();
  }
  
  public void reset() {
    this.layer1.reset();
    this.layer2.reset();
    this.epochs = 0.0;
  }
  
  public void fit(Matrix[] inputs, Matrix[] targets, int epochs, int batchSize, boolean shuffle) {
    for(int e = 0; e < epochs; e++) {
      for(int b = 0; b < batchSize; b++) {
        for(int t = 0; t < inputs.length; t++) {
          int i = (shuffle) ? floor(random(inputs.length)) : t;
          model.fitOne(inputs[i], targets[i]);
        }
      }
      
      this.epochs += 1.0;
      
      if(this.learningRateScheduler != null) {
        this.learningRateScheduler.adapt(this.optimizer, this.epochs);
      }
    }
  }

  public void fitOne(Matrix input, Matrix target) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);
    
    Matrix loss = this.loss.apply(output, target);
    this.optimizer.optimize(this.layer2, hidden, output, loss);
    
    loss = this.layer2.feedBackLoss(loss);
    this.optimizer.optimize(this.layer1, input, hidden, loss);
  }
  
  public Matrix predict(Matrix input) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);
    return output;
  }
}
