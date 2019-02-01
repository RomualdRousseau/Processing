abstract class NeuralNetwork {
  Layer layer1;
  Layer layer2;
  Optimizer optimizer;
  LearningRateScheduler learningRateScheduler;
  float epochs;

  public NeuralNetwork() {
    this.layer1 = null;
    this.layer2 = null;
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = 0.0;
  }
  
  public NeuralNetwork(JSONObject json) {
    this.layer1 = new Layer(json.getJSONObject("layer1"));
    this.layer2 = new Layer(json.getJSONObject("layer2"));
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = json.getFloat("epochs");
  }
  
  public abstract NeuralNetwork clone();

  public void reset() {
    this.layer1.reset();
    this.layer2.reset();
    this.epochs = 0.0;
  }

  public Matrix predict(Matrix input) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);
    return output;
  }
  
  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setJSONObject("layer1", this.layer1.toJSON());
    json.setJSONObject("layer2", this.layer2.toJSON());
    json.setFloat("epochs", this.epochs);
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
    this.layer1 = parent.layer1.clone();
    this.layer2 = parent.layer2.clone();
    this.loss = parent.loss;
    this.optimizer = parent.optimizer;
    this.learningRateScheduler = parent.learningRateScheduler;
    this.epochs = 0.0;
  }

  public NeuralNetwork clone() {
    return new SequentialNeuralNetwork(this);
  }
  
  public void compile(boolean shuffle, LossFunction loss, Optimizer optimizer) {
    this.compile(shuffle, loss, optimizer, null);
  }

  public void compile(boolean shuffle, LossFunction loss, Optimizer optimizer, LearningRateScheduler learningRateScheduler) {
    this.loss = loss;
    this.optimizer = optimizer;
    this.learningRateScheduler = learningRateScheduler;
    if(shuffle) {
      this.reset();
    }
  }

  public void fit(Matrix[] inputs, Matrix[] targets, int epochs, int batchSize, boolean shuffle) {
    for (int e = 0; e < epochs; e++) {
      for (int b = 0; b < batchSize; b++) {
        for (int t = 0; t < inputs.length; t++) {
          int i = (shuffle) ? floor(random(inputs.length)) : t;
          this.fitOne(inputs[i], targets[i]);
        }
      }

      this.epochs += 1.0;

      if (this.learningRateScheduler != null) {
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
}

class GeneticNeuralNetwork extends NeuralNetwork {
  float fitness;

  public GeneticNeuralNetwork() {
    super();
    this.fitness = 0.0;
  }
  
  public GeneticNeuralNetwork(JSONObject json) {
    super(json);
    this.fitness = json.getFloat("fitness");
  }

  private GeneticNeuralNetwork(GeneticNeuralNetwork parent) {
    this.layer1 = parent.layer1.clone();
    this.layer2 = parent.layer2.clone();
    this.optimizer = parent.optimizer;
    this.learningRateScheduler = parent.learningRateScheduler;
    this.epochs = 0.0;
    this.fitness = 0.0;
  }

  public GeneticNeuralNetwork clone() {
    return new GeneticNeuralNetwork(this);
  }
  
  public void reset() {
    super.reset();
    this.fitness = 0.0;
  }
  
  public void compile(boolean shuffle, Optimizer optimizer) {
    this.compile(shuffle, optimizer, null);
  }

  public void compile(boolean shuffle, Optimizer optimizer, LearningRateScheduler learningRateScheduler) {
    this.optimizer = optimizer;
    this.learningRateScheduler = learningRateScheduler;
    if(shuffle) {
      this.reset();
    }
  }

  public void mutate() {
    this.optimizer.optimize(this.layer1, null, null, null);
    this.optimizer.optimize(this.layer2, null, null, null);

    this.epochs += 1.0;

    if (this.learningRateScheduler != null) {
      this.learningRateScheduler.adapt(this.optimizer, this.epochs);
    }
  }

  public JSONObject toJSON() {
    JSONObject json = super.toJSON();
    json.setFloat("fitness", this.fitness);
    return json;
  }
}

class Layer {
  Matrix weights;
  Matrix gradients;
  Matrix bias;
  ActivationFunction activation;

  public Layer(int inputUnits, int units) {
    this(inputUnits, units, new LinearActivationFunction());
  }

  public Layer(int inputUnits, int units, ActivationFunction activation) {
    this.weights = new Matrix(units, inputUnits);
    this.gradients = new Matrix(units, 1);
    this.bias = new Matrix(units, 1);
    this.activation = activation;
  }
  
  public Layer(JSONObject json) {
    this(json, new LinearActivationFunction());
  }
  
  public Layer(JSONObject json, ActivationFunction activation) {
    this.weights = new Matrix(json.getJSONObject("weights"));
    this.gradients = new Matrix(json.getJSONObject("gradients"));
    this.bias = new Matrix(json.getJSONObject("bias"));
    this.activation = activation;
  }

  private Layer(Layer parent) {
    this.weights = parent.weights.copy();
    this.gradients = parent.gradients.copy();
    this.bias = parent.bias.copy();
    this.activation = parent.activation;
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

  public Layer clone() {
    return new Layer(this);
  }

  public Matrix feedForward(Matrix input) {
    return this.weights.transform(input).add(this.bias).map(this.activation.apply);
  }

  public Matrix feedBackLoss(Matrix loss) {
    return this.weights.transpose().transform(loss);
  }
  
  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setJSONObject("weights", this.weights.toJSON());
    json.setJSONObject("gradients", this.gradients.toJSON());
    json.setJSONObject("bias", this.bias.toJSON());
    return json;
  }
}

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

interface LossFunction {
  Matrix apply(Matrix output, Matrix target);
}

class MeanSquaredErrorFunction implements LossFunction {
  public Matrix apply(Matrix output, Matrix target) {
    return target.copy().sub(output);
  }
}

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

  abstract void optimize(Layer layer, Matrix input, Matrix output, Matrix error);
}

class OptimizerSgd extends Optimizer {
  public OptimizerSgd(float learningRate) {
    super(learningRate);
  }

  public OptimizerSgd(float learningRate, float biasRate) {
    super(learningRate, biasRate);
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error).mult(this.learningRate);
    Matrix delta = gradient.transform(input.transpose());
    layer.weights.add(delta);
    layer.bias.add(gradient.mult(this.biasRate));
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

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Matrix gradient = output.copy().map(layer.activation.derivate).mult(error).mult(this.learningRate);
    layer.gradients.mult(this.momentum).add(gradient.mult(1.0 - this.momentum));
    Matrix delta = layer.gradients.transform(input.transpose());
    layer.weights.add(delta);
    layer.bias.add(layer.gradients.mult(this.biasRate));
  }
}

class OptimizerGenetic extends Optimizer {
  float mutationRate;

  public OptimizerGenetic(float learningRate, float mutationRate) {
    super(learningRate);
    this.mutationRate = mutationRate;
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    Function<Float, Float> mutationFunc = new Function<Float, Float>() {
      public final Float apply(Float x) {
        if (random(1.0) < mutationRate) {
          return x + randomGaussian() * learningRate;
        } else {
          return x;
        }
      }
    };
    layer.weights.map(mutationFunc);
    layer.bias.map(mutationFunc);
  }
}
