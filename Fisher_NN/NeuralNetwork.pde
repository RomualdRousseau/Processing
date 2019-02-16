abstract class NeuralNetwork {
  ArrayList<Layer> layers =  new ArrayList<Layer>();
  Optimizer optimizer;

  public NeuralNetwork() {
    this.optimizer = null;
  }

  public NeuralNetwork(JSONObject json) {
    JSONArray jsonLayers = json.getJSONArray("layers");
    for (int i  = 0; i < jsonLayers.size(); i++) {
      this.layers.add(new Layer(jsonLayers.getJSONObject(i)));
    }
    this.optimizer = null;
  }

  public abstract NeuralNetwork clone();

  public NeuralNetwork addLayer(Layer layer) {
    this.layers.add(layer);
    return this;
  }

  public void reset() {
    for (Layer l : this.layers) {
      l.reset();
    }
    this.optimizer.reset();
  }

  public Matrix predict(Matrix input) {
    Matrix current = input;
    for (Layer l : this.layers) {
      current = l.activation.apply(xw_plus_b(current, l.weights, l.bias));
    }
    return current;
  }

  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonLayers = new JSONArray();
    for (Layer l : this.layers) {
      jsonLayers.append(l.toJSON());
    }
    json.setJSONArray("layers", jsonLayers);
    return json;
  }
}

class SequentialNeuralNetwork extends NeuralNetwork {
  LossFunction loss;

  public SequentialNeuralNetwork() {
    super();
    this.loss = null;
  }

  public SequentialNeuralNetwork(JSONObject json) {
    super(json);
    this.loss = null;
  }

  private SequentialNeuralNetwork(SequentialNeuralNetwork parent) {
    for (Layer l : parent.layers) {
      this.layers.add(l.clone());
    }
    this.loss = parent.loss;
    this.optimizer = parent.optimizer;
  }

  public SequentialNeuralNetwork clone() {
    return new SequentialNeuralNetwork(this);
  }

  public SequentialNeuralNetwork compile(LossFunction loss, Optimizer optimizer) {
    this.loss = loss;
    this.optimizer = optimizer;
    return this;
  }

  public Matrix fit(Matrix[] inputs, Matrix[] targets, int batchSize, boolean shuffle) {
    Matrix sum = new Matrix(this.layers.get(this.layers.size() - 1).getOutputUnits(), 1);

    for (int t = 0; t < inputs.length; t += batchSize) {
      int bs = min(batchSize, inputs.length - t);
      for (int b = 0; b < batchSize; b++) {
        int i = (shuffle) ? floor(random(t, t + bs)) : t + b;
        sum.add(this.fitOnce(inputs[i], targets[i]));
      }
    }

    this.optimizer.updateEpochs();

    return sum.div(inputs.length);
  }

  public Matrix fitOnce(Matrix input, Matrix target) {
    ArrayList<Matrix> outputs = new ArrayList<Matrix>();
    outputs.add(input);
    for (Layer l : this.layers) {
      Matrix current = outputs.get(outputs.size() - 1);
      outputs.add(l.activation.apply(xw_plus_b(current, l.weights, l.bias)));
    }

    Matrix lossRates = null;
    for (int i = this.layers.size() - 1; i >= 0; i--) {
      Layer layer = this.layers.get(i);
      Matrix output = outputs.get(i + 1);

      if (lossRates == null) {
        lossRates = this.loss.derivate(output, target);
      } else {
        lossRates = this.loss.computeWeightedLoss(lossRates, this.layers.get(i + 1).weights);
      }      
      lossRates = layer.activation.derivate(output, lossRates);

      this.optimizer.minimize(layer, outputs.get(i), output, lossRates);
    }

    return this.loss.apply(outputs.get(outputs.size() - 1), target);
  }
}

class GeneticNeuralNetwork extends SequentialNeuralNetwork {
  float mutationRate;
  float fitness;

  public GeneticNeuralNetwork() {
    super();
    this.mutationRate = 0.1;
    this.fitness = 0.0;
  }

  public GeneticNeuralNetwork(JSONObject json) {
    super(json);
    this.mutationRate = json.getFloat("mutationRate");
    this.fitness = json.getFloat("fitness");
  }

  private GeneticNeuralNetwork(GeneticNeuralNetwork parent) {
    super(parent);
    this.mutationRate = parent.mutationRate;
    this.fitness = 0.0;
  }

  public GeneticNeuralNetwork clone() {
    return new GeneticNeuralNetwork(this);
  }

  public GeneticNeuralNetwork setMutationRate(float mutationRate) {
    this.mutationRate = mutationRate;
    return this;
  }

  public void reset() {
    super.reset();
    this.fitness = 0.0;
  }

  public void mutate() {
    for (Layer l : this.layers) {
      this.mutateLayer(l);
    }
  }

  public JSONObject toJSON() {
    JSONObject json = super.toJSON();
    json.setFloat("fitness", this.fitness);
    return json;
  }

  private void mutateLayer(Layer layer) {
    MatrixFunction<Float, Float> mutationFunc = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        if (random(1.0) < mutationRate) {
          return x + randomGaussian() * optimizer.learningRate;
        } else {
          return x;
        }
      }
    };
    layer.weights.map(mutationFunc);
    layer.bias.map(mutationFunc);
  }
}

class Layer {
  Matrix weights;
  Matrix bias;
  Matrix gradients;
  ActivationFunction activation;
  InitializerFunction initializer;
  boolean normalize;

  public Layer(int inputUnits, int units) {
    this.weights = new Matrix(units, inputUnits);
    this.bias = new Matrix(units, 1);
    this.gradients = new Matrix(units, 1);
    this.activation = new LinearActivation();
    this.initializer = new GlorotUniformInitializer();
    this.initializer.apply(this);
    this.normalize = false;
  }

  public Layer(JSONObject json) {
    this.weights = new Matrix(json.getJSONObject("weights"));
    this.bias = new Matrix(json.getJSONObject("bias"));
    this.gradients = new Matrix(json.getJSONObject("gradients")); 
    this.activation = new LinearActivation();
    this.initializer = new GlorotUniformInitializer();
    this.normalize = false;
  }

  private Layer(Layer parent) {
    this.weights = parent.weights.copy();
    this.bias = parent.bias.copy();
    this.gradients = parent.gradients.copy();
    this.activation = parent.activation;
    this.initializer = parent.initializer;
    this.normalize = parent.normalize;
  }

  public Layer setActivation(ActivationFunction activation) {
    this.activation = activation;
    return this;
  }

  public Layer setInitializer(InitializerFunction initializer) {
    this.initializer = initializer;
    this.initializer.apply(this);
    return this;
  }

  public Layer setNormalize(boolean normalize) {
    this.normalize = normalize;
    return this;
  }

  public int getInputUnits() {
    return this.weights.cols;
  }

  public int getOutputUnits() {
    return this.weights.rows;
  }

  public Layer clone() {
    return new Layer(this);
  }

  public void reset() {
    this.initializer.apply(this);
    this.gradients.zero();
  }

  public void adjustWeight(Matrix delta) {
    this.weights.sub(delta);
    if (this.normalize) {
      this.weights.batchNorm(1.0, 0.0);
    }
  }

  public void adjustBias(Matrix delta) {
    this.bias.sub(delta);
    if (this.normalize) {
      this.bias.batchNorm(1.0, 0.0);
    }
  }

  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setJSONObject("weights", this.weights.toJSON());
    json.setJSONObject("gradients", this.gradients.toJSON());
    json.setJSONObject("bias", this.bias.toJSON());
    return json;
  }
}

interface InitializerFunction {
  void apply(Layer layer);
}

class GlorotUniformInitializer implements InitializerFunction {
  public void apply(Layer layer) {
    layer.weights.randomize(sqrt(6.0 / sqrt(layer.weights.rows + layer.weights.cols)));
    layer.bias.zero(); //randomize(1.0 / sqrt(layer.bias.rows + layer.bias.cols));
    layer.gradients.zero();
  }
}

class LecunUniformInitializer implements InitializerFunction {
  public void apply(Layer layer) {
    layer.weights.randomize(sqrt(6.0 / sqrt(layer.weights.rows)));
    layer.bias.zero(); //randomize(1.0 / sqrt(layer.bias.rows));
    layer.gradients.zero();
  }
}

class HeUniformInitializer implements InitializerFunction {
  public void apply(Layer layer) {
    layer.weights.randomize(sqrt(3.0 / sqrt(layer.weights.rows)));
    layer.bias.zero(); //randomize(2.0 / sqrt(layer.bias.rows));
    layer.gradients.zero();
  }
}

interface LearningRateScheduler {
  void apply(Optimizer optimizer, int epoch);
}

class TimeBasedScheduler implements LearningRateScheduler {
  float decay;
  int step;
  float minRate;

  public TimeBasedScheduler(float decay, int step, float minRate) {
    this.decay = decay;
    this.step = step;
    this.minRate = minRate;
  }

  public void apply(Optimizer optimizer, int epoch) {
    int a = epoch / this.step;
    optimizer.learningRate = max(this.minRate, optimizer.learningRate0 / (1.0 + this.decay * a));
  }
}

class ExponentialScheduler implements LearningRateScheduler {
  float decay;
  int step;
  float minRate;

  public ExponentialScheduler(float decay, int step, float minRate) {
    this.decay = decay;
    this.step = step;
    this.minRate = minRate;
  }

  public void apply(Optimizer optimizer, int epoch) {
    int a = epoch / this.step;
    optimizer.learningRate = max(this.minRate, optimizer.learningRate0 * exp(-this.decay * a));
  }
}

interface ActivationFunction {
  Matrix apply(Matrix input);
  Matrix derivate(Matrix output, Matrix error);
}

class LinearActivation implements ActivationFunction {
  Matrix apply(Matrix input) {
    /*
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
     public final Float apply(Float x, int row, int col, Matrix matrix) {
     return x;
     }
     };
     
     return input.map(fn);
     */
    return input;
  }

  Matrix derivate(Matrix output, Matrix lossRate) {
    /*
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
     public final Float apply(Float y, int row, int col, Matrix matrix) {
     return 1.0;
     }
     };
     
     Matrix m = output.copy();
     Matrix r = m.map(fn).mult(error); 
     return r;
     */
    return lossRate.copy();
  }
}

class SigmoidActivation implements ActivationFunction {
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

class TanhActivation implements ActivationFunction {
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

class ReluActivation implements ActivationFunction {
  Matrix apply(Matrix input) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        return max(0.0, x);
      }
    };
    return input.map(fn);
  }

  Matrix derivate(Matrix output, Matrix lossRate) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix matrix) {
        return (y <= 0.0) ? 0.0 : 1.0;
      }
    };

    Matrix m = output.copy();
    Matrix r = m.map(fn).mult(lossRate); 
    return r;
  }
}

class SoftmaxActivation implements ActivationFunction {
  Matrix apply(Matrix input) {
    if (input.cols > 1) {
      throw new IllegalArgumentException("Softmax must be used on 1D matrix");
    }

    final float c = -input.get(input.argmax(0), 0);

    float temp = 0.0;
    for (int k = 0; k < input.rows; k++) {
      temp += exp(input.get(k, 0) + c);
    } 
    final float sum = temp;

    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        return exp(x + c) / sum;
      }
    };

    return input.map(fn);
  }

  Matrix derivate(Matrix output, Matrix lossRate) {
    if (output.cols > 1) {
      throw new IllegalArgumentException("Softmax must be used on 1D matrix");
    }

    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        final float k = (row == col) ? 1.0 : 0.0;
        return output.get(col, 0) * (k - output.get(row, 0));
      }
    };

    Matrix m = new Matrix(output.rows, output.rows);
    Matrix r = m.map(fn, output).transform(lossRate);   
    return r;
  }
}

abstract class LossFunction {
  public Matrix computeWeightedLoss(Matrix losses, Matrix weights) {
    return weights.transpose().transform(losses);
  }

  abstract public Matrix apply(Matrix output, Matrix target);

  abstract public Matrix derivate(Matrix output, Matrix target);
}

class MeanSquaredError extends LossFunction {
  public Matrix apply(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        float a = output.get(row, col);
        return 0.5 * (y - a) * (y - a);
      }
    };
    return target.copy().map(fn, output);
  }

  public Matrix derivate(Matrix output, Matrix target) {
    return output.copy().sub(target);
  }
}

class SoftmaxCrossEntropy extends LossFunction {
  public Matrix apply(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        float a = output.get(row, col);
        return -y * log(a);
      }
    }; 
    return target.copy().map(fn, output);
  }

  public Matrix derivate(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        float a = output.get(row, col);
        if (a > 0.0) {
          return -y / a;
        } else {
          return 0.0;
        }
      }
    };
    return target.copy().map(fn, output);
  }
}

abstract class Optimizer {
  LearningRateScheduler learningRateScheduler;
  float learningRate0;
  float biasRate0;
  float learningRate;
  float biasRate;
  int epochs;

  public Optimizer() {
    this.learningRateScheduler = null;
    this.learningRate0 = 0.001;
    this.learningRate = 0.001;
    this.biasRate0 = 1.0;
    this.biasRate = 1.0;
    this.epochs = 0;
  }

  public Optimizer setLearningRate(float learningRate) {
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    return this;
  }

  public Optimizer setLearningRateScheduler(LearningRateScheduler learningRateScheduler) {
    this.learningRateScheduler = learningRateScheduler;
    return this;
  }

  public Optimizer setBiasRate(float biasRate) {
    this.biasRate0 = biasRate;
    this.biasRate = biasRate;
    return this;
  }

  public void reset() {
    this.learningRate = this.learningRate0;
    this.epochs = 0;
  }

  public void updateEpochs() {
    this.epochs++;
    if (this.learningRateScheduler != null) {
      this.learningRateScheduler.apply(this, this.epochs);
    }
  }

  public void minimize(Layer layer, Matrix input, Matrix output, Matrix lossRate) {
    this.computeGradients(layer, output, lossRate);
    this.applyGradients(layer, input);
  }

  abstract public void computeGradients(Layer layer, Matrix output, Matrix lossRate);

  public void applyGradients(Layer layer, Matrix input) {
    layer.adjustWeight(layer.gradients.transform(input.transpose()));
    layer.adjustBias(layer.gradients.copy().mult(this.biasRate));
  }
}

class OptimizerSgd extends Optimizer {
  public OptimizerSgd() {
    super();
  }

  public void computeGradients(Layer layer, Matrix output, Matrix lossRate) {
    layer.gradients.mult(0.0).add(lossRate).mult(this.learningRate);
  }
}

class OptimizerMomentum extends Optimizer {
  float momentum;

  public OptimizerMomentum() {
    super();
    this.momentum = 0.9;
  }

  public OptimizerMomentum setMomentum(float momentum) {
    this.momentum = momentum;
    return this;
  }

  public void computeGradients(Layer layer, Matrix output, Matrix lossRate) {
    layer.gradients.mult(this.momentum).add(lossRate.copy().mult(this.learningRate * (1.0 - this.momentum)));
  }
}