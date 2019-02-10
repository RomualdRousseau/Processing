abstract class Optimizer {
  float learningRate0;
  float learningRate;
  float biasRate;

  public Optimizer(float learningRate) {
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    this.biasRate = 1.0;
  }
  
  public Optimizer(float learningRate, float biasRate) {
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    this.biasRate = biasRate;
  }
  
  abstract Matrix optimize(Layer layer, Matrix input, Matrix output, Matrix error);
}

class OptimizerSgd extends Optimizer {
  public OptimizerSgd(float learningRate) {
    super(learningRate);
  }
  
  public OptimizerSgd(float learningRate, float biasRate) {
    super(learningRate, biasRate);
  }
  
  public Matrix optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error);
    
    Matrix delta = gradient.transform(input.transpose()).mult(this.learningRate);
    layer.weights.add(delta);
    layer.bias.add(gradient.copy().mult(this.learningRate * this.biasRate));
    return gradient;
  }
}

class OptimizerMomentum extends Optimizer {
  float momentum;

  public OptimizerMomentum(float learningRate) {
    super(learningRate);
    this.momentum = 0.9;
  }
  
  public OptimizerMomentum(float learningRate, float momentum, float biasRate) {
    super(learningRate, biasRate);
    this.momentum = momentum;
  }
 
  public Matrix optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error);
    layer.gradients.mult(this.momentum).add(gradient.mult(1.0 - this.momentum)).mult(this.learningRate);
    
    Matrix delta = layer.gradients.transform(input.transpose());
    layer.weights.add(delta);
    layer.bias.add(layer.gradients.copy().mult(this.biasRate));
    return gradient;
  }
}
