abstract class NeuralNetwork {
  ArrayList<Layer> layers =  new ArrayList<Layer>();
  ArrayList<Matrix> outputs = new ArrayList<Matrix>();

  public NeuralNetwork() {
  }

  public NeuralNetwork(JSONObject json) {
    JSONArray jsonLayers = json.getJSONArray("layers");
    for (int i  = 0; i < jsonLayers.size(); i++) {
      this.layers.add(new Layer(jsonLayers.getJSONObject(i)));
    }
  }

  abstract public NeuralNetwork clone();

  public NeuralNetwork addLayer(Layer layer) {
    layer.index = this.layers.size();
    this.layers.add(layer);
    return this;
  }

  public void reset() {
    for (Layer l : this.layers) {
      l.reset();
    }
  }

  public Matrix predict(Matrix input) {
    this.outputs.clear();
    this.outputs.add(input);
    for (Layer l : this.layers) {
      Matrix current = this.outputs.get(outputs.size() - 1);
      this.outputs.add(l.activation.apply(xw_plus_b(current, l.weights, l.bias)));
    }
    return this.outputs.get(outputs.size() - 1);
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
  Optimizer optimizer;

  public SequentialNeuralNetwork() {
    super();
    this.loss = null;
    this.optimizer = null;
  }

  public SequentialNeuralNetwork(JSONObject json) {
    super(json);
    this.loss = null;
    this.optimizer = null;
  }

  private SequentialNeuralNetwork(SequentialNeuralNetwork parent) {
    for (Layer l : parent.layers) {
      this.layers.add(l.clone());
    }
    this.loss = parent.loss.clone().compile(this);
    this.optimizer = parent.optimizer.clone().compile(this);
  }

  public SequentialNeuralNetwork clone() {
    return new SequentialNeuralNetwork(this);
  }

  public void reset() {
    super.reset();
    this.optimizer.reset();
  }

  public SequentialNeuralNetwork addLayer(Layer layer) {
    super.addLayer(layer);
    return this;
  }

  public SequentialNeuralNetwork compile(LossFunction loss, Optimizer optimizer) {
    this.loss = loss.compile(this);
    this.optimizer = optimizer.compile(this);
    return this;
  }

  public Matrix fit(Matrix[] inputs, Matrix[] targets, int batchSize, boolean shuffle) {
    if (inputs.length != targets.length) {
      throw new IllegalArgumentException("Inputs and Targets must have same number of elements");
    }

    if (shuffle) {
      Matrix temp;
      for (int i = inputs.length - 1; i > 0; i--) {
        int j = floor(random(i));

        temp = inputs[j];
        inputs[j] = inputs[i];
        inputs[i] = temp;

        temp = targets[j];
        targets[j] = targets[i];
        targets[i] = temp;
      }
    }

    Matrix sum = new Matrix(this.layers.get(this.layers.size() - 1).weights.rows, 1);
    
    for (int t = 0; t < inputs.length; t += batchSize) {
      this.optimizer.zeroGradients();

      int bs = min(t + batchSize, inputs.length);
      for (int b = t; b < bs; b++) {
        Matrix output = this.predict(inputs[b]);
        Matrix lossRate = this.loss.derivate(output, targets[b]);
        this.loss.backward(lossRate);
        sum.add(this.loss.apply(output, targets[b]));
      }

      this.optimizer.step();
    }

    this.optimizer.decayLearningRate();
    
    return sum.div(inputs.length);
  }
}

class GeneticNeuralNetwork extends SequentialNeuralNetwork implements Individual {
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

  public GeneticNeuralNetwork addLayer(Layer layer) {
    super.addLayer(layer);
    return this;
  }

  public void reset() {
    super.reset();
    this.fitness = 0.0;
  }

  public GeneticNeuralNetwork setMutationRate(float mutationRate) {
    this.mutationRate = mutationRate;
    return this;
  }

  public float getFitness() {
    return this.fitness;
  }

  public void setFitness(float fitness) {
    this.fitness = fitness;
  }

  public void mutate() {
    for (Layer l : this.layers) {
      this.mutateLayer(l);
    }
  }

  public JSONObject toJSON() {
    JSONObject json = super.toJSON();
    json.setFloat("mutationRate", this.mutationRate);
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
  int index;
  float biasRate;
  Matrix weights;
  Matrix bias;
  Matrix gradientWeights;
  Matrix gradientBias;
  ActivationFunction activation;
  InitializerFunction initializer; 
  boolean normalize;

  public Layer(int inputUnits, int units) {
    this.index = -1;
    this.biasRate = 1.0;
    this.weights = new Matrix(units, inputUnits);
    this.bias = new Matrix(units, 1);
    this.normalize = false;

    this.gradientWeights = new Matrix(this.weights.rows, this.weights.cols);
    this.gradientBias = new Matrix(this.bias.rows, 1);
    this.activation = new LinearActivation();
    this.initializer = new GlorotUniformInitializer();

    this.initializer.apply(this);
  }

  public Layer(JSONObject json) {
    this.index = json.getInt("index");
    this.biasRate = json.getFloat("biasRate");
    this.weights = new Matrix(json.getJSONObject("weights"));
    this.bias = new Matrix(json.getJSONObject("bias"));
    this.normalize = json.getBoolean("normalize");

    this.gradientWeights = new Matrix(this.weights.rows, this.weights.cols);
    this.gradientBias = new Matrix(this.bias.rows, 1);
    this.activation = new LinearActivation();
    this.initializer = new GlorotUniformInitializer();

    this.initializer.apply(this);
  }

  private Layer(Layer parent) {
    this.index = parent.index;
    this.biasRate = parent.biasRate;
    this.weights = parent.weights.copy();
    this.bias = parent.bias.copy();
    this.normalize = parent.normalize;

    this.gradientWeights = new Matrix(this.weights.rows, this.weights.cols);
    this.gradientBias = new Matrix(this.bias.rows, 1);
    this.activation = parent.activation;
    this.initializer = parent.initializer;

    this.initializer.apply(this);
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

  public Layer setBiasRate(float biasRate) {
    this.biasRate = biasRate;
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
    this.zeroGradients();
  }

  public void zeroGradients() {
    this.gradientWeights.zero();
    this.gradientBias.zero();
  }

  public void adjustWeights(Matrix delta) {
    this.weights.sub(delta);
    if (this.normalize) {
      this.weights.l2Norm();
    }
  }

  public void adjustBias(Matrix delta) {
    this.bias.sub(delta);
    if (this.normalize) {
      this.bias.l2Norm();
    }
  }

  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setInt("index", this.index);
    json.setFloat("biasRate", this.biasRate);
    json.setBoolean("normalize", this.normalize);
    json.setJSONObject("weights", this.weights.toJSON());
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
  }
}

class LecunUniformInitializer implements InitializerFunction {
  public void apply(Layer layer) {
    layer.weights.randomize(sqrt(6.0 / sqrt(layer.weights.rows)));
    layer.bias.zero(); //randomize(1.0 / sqrt(layer.bias.rows));
  }
}

class HeUniformInitializer implements InitializerFunction {
  public void apply(Layer layer) {
    layer.weights.randomize(sqrt(3.0 / sqrt(layer.weights.rows)));
    layer.bias.zero(); //randomize(2.0 / sqrt(layer.bias.rows));
  }
}

interface LearningRateScheduler {
  void apply(Optimizer optimizer, int epoch);
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
  NeuralNetwork model;

  abstract public LossFunction clone();

  public LossFunction compile(NeuralNetwork model) {
    this.model = model;
    return this;
  }

  public Matrix computeWeightedLoss(Matrix losses, Matrix weights) {
    return weights.transpose().transform(losses);
  }

  public void backward(Matrix lossRate) {
    ArrayList<Layer> layers =  this.model.layers;
    ArrayList<Matrix> outputs = this.model.outputs;
    int output = layers.size() - 1;

    if (outputs.size() < layers.size() + 1) {
      throw new IllegalArgumentException("Predict should run before backward");
    }

    lossRate = this.minimize(layers.get(output), outputs.get(output), outputs.get(output + 1), lossRate);

    for (int hidden = output - 1; hidden >= 0; hidden--) {
      lossRate = this.computeWeightedLoss(lossRate, layers.get(hidden + 1).weights);
      lossRate = this.minimize(layers.get(hidden), outputs.get(hidden), outputs.get(hidden + 1), lossRate);
    }
  }

  abstract public Matrix apply(Matrix output, Matrix target);

  abstract public Matrix derivate(Matrix output, Matrix target);

  private Matrix minimize(Layer layer, Matrix input, Matrix output, Matrix lossRate) {
    Matrix newLossRate = layer.activation.derivate(output, lossRate);
    layer.gradientWeights.add(newLossRate.transform(input.transpose()));
    layer.gradientBias.add(newLossRate.copy().mult(layer.biasRate));
    return newLossRate;
  }
}

class MeanSquaredError extends LossFunction {
  public LossFunction clone() {
    return new MeanSquaredError();
  }

  public Matrix apply(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        float a = y - output.get(row, col);
        return 0.5 * a * a;
      }
    };
    return target.copy().map(fn, output);
  }

  public Matrix derivate(Matrix output, Matrix target) {
    return output.copy().sub(target);
  }
}

class Huber extends LossFunction {
  public LossFunction clone() {
    return new Huber();
  }

  public Matrix apply(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix output) {
        float a = y - output.get(row, col);
        if (abs(a) <= 1) {
          return 0.5 * a * a;
        } else {
          return abs(a) - 0.5;
        }
      }
    };
    return target.copy().map(fn, output);
  }

  public Matrix derivate(Matrix output, Matrix target) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix target) {
        float a = y - target.get(row, col);
        if (a < -1.0) {
          return -1.0;
        } else if (a <= 1.0) {
          return a;
        } else {
          return 1.0;
        }
      }
    };
    return output.copy().map(fn, target);
  }
}

class SoftmaxCrossEntropy extends LossFunction {
  public LossFunction clone() {
    return new SoftmaxCrossEntropy();
  }

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
  NeuralNetwork model;
  LearningRateScheduler learningRateScheduler;
  float learningRate0;
  float learningRate;
  int epochs;

  public Optimizer() {
    this.learningRateScheduler = null;
    this.learningRate0 = 0.001;
    this.learningRate = 0.001;
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

  public void reset() {
    this.learningRate = this.learningRate0;
    this.epochs = 0;
  }

  public Optimizer compile(NeuralNetwork model) {
    this.model = model;
    return this;
  }

  public void decayLearningRate() {
    this.epochs++;
    if (this.learningRateScheduler != null) {
      this.learningRateScheduler.apply(this, this.epochs);
    }
  }

  public void zeroGradients() {
    for (Layer l : this.model.layers) {
      l.zeroGradients();
    }
  }

  public void step() {
    for (Layer layer : this.model.layers) {
      this.applyGradients(layer);
    }
  }

  abstract public Optimizer clone();

  abstract public void applyGradients(Layer layer);
}

class OptimizerSgd extends Optimizer {
  float momentum;
  Matrix[] velocityWeights;
  Matrix[] velocityBias;

  public OptimizerSgd() {
    super();
    this.momentum = 0.0;
  }

  public OptimizerSgd setMomentum(float momentum) {
    this.momentum = momentum;
    return this;
  }

  public void reset() {
    super.reset();

    for (Layer layer : model.layers) {
      int i = layer.index;
      this.velocityWeights[i].zero();
      this.velocityBias[i].zero();
    }
  }

  public Optimizer compile(NeuralNetwork model) {
    super.compile(model);

    this.velocityWeights = new Matrix[model.layers.size()];
    this.velocityBias = new Matrix[model.layers.size()];

    for (Layer layer : model.layers) {
      int i = layer.index;
      this.velocityWeights[i] = new Matrix(layer.gradientWeights.rows, layer.gradientWeights.cols);
      this.velocityBias[i] = new Matrix(layer.gradientBias.rows, layer.gradientBias.cols);
    }

    return this;
  }

  public Optimizer clone() {
    return new OptimizerSgd().setMomentum(this.momentum);
  }

  public void applyGradients(Layer layer) {
    int i = layer.index;

    this.velocityWeights[i].mult(this.momentum).add(layer.gradientWeights.copy().mult((1.0 - this.momentum) * this.learningRate));
    this.velocityBias[i].mult(this.momentum).add(layer.gradientBias.copy().mult((1.0 - this.momentum) * this.learningRate));

    layer.adjustWeights(this.velocityWeights[i]);
    layer.adjustBias(this.velocityBias[i]);
  }
}

class OptimizerRMSProp extends Optimizer {
  float momentum;
  Matrix[] cacheWeights;
  Matrix[] cacheBias;

  public OptimizerRMSProp() {
    super();
    this.momentum = 0.9;
  }

  public OptimizerRMSProp setMomentum(float momentum) {
    this.momentum = momentum;
    return this;
  }

  public void reset() {
    super.reset();

    for (Layer layer : model.layers) {
      int i = layer.index;
      this.cacheWeights[i].zero();
      this.cacheBias[i].zero();
    }
  }

  public Optimizer compile(NeuralNetwork model) {
    super.compile(model);

    this.cacheWeights = new Matrix[model.layers.size()];
    this.cacheBias = new Matrix[model.layers.size()];

    for (Layer layer : model.layers) {
      int i = layer.index;
      this.cacheWeights[i] = new Matrix(layer.gradientWeights.rows, layer.gradientWeights.cols);
      this.cacheBias[i] = new Matrix(layer.gradientBias.rows, layer.gradientBias.cols);
    }

    return this;
  }

  public Optimizer clone() {
    return new OptimizerRMSProp().setMomentum(this.momentum);
  }

  public void applyGradients(Layer layer) {
    int i = layer.index;
    final float learningRate = this.learningRate;
    
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix cache) {
        float a = cache.get(row, col);
        return y * learningRate / sqrt(a + EPSILON);
      }
    };

    this.cacheWeights[i].mult(this.momentum).add(layer.gradientWeights.copy().pow(2.0).mult((1.0 - this.momentum)));
    this.cacheBias[i].mult(this.momentum).add(layer.gradientBias.copy().pow(2.0).mult((1.0 - this.momentum)));

    layer.adjustWeights(layer.gradientWeights.copy().map(fn, this.cacheWeights[i]));
    layer.adjustBias(layer.gradientBias.copy().map(fn, this.cacheBias[i]));
  }
}
