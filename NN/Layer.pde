class Layer {
  Matrix weights;
  Matrix gradients;
  Matrix bias;
  ActivationFunction activation;
 
  public Layer(int inputUnits, int units) {
    this.weights = new Matrix(units, inputUnits);
    this.gradients = new Matrix(units, 1);
    this.bias = new Matrix(units, 1);
    this.activation = new LinearActivationFunction();
  }
  
  public Layer(int inputUnits, int units, ActivationFunction activation) {
    this.weights = new Matrix(units, inputUnits);
    this.gradients = new Matrix(units, 1);
    this.bias = new Matrix(units, 1);
    this.activation = activation;
  }
  
  public int getInputUnits() {
    return this.weights.cols;
  }
  
  public int getOutputUnits() {
    return this.weights.rows;
  }
  
  public void reset() {
    this.weights.randomize(this.weights.rows);
    this.gradients.reset();
    this.bias.randomize(this.bias.rows);
  }
  
  public Matrix feedForward(Matrix input) {
    return this.weights.transform(input).add(this.bias).map(this.activation.apply);
  }
  
  public Matrix feedBackLoss(Matrix loss) {
    return this.weights.transpose().transform(loss);
  }
}
