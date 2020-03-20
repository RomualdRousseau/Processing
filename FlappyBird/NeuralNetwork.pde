import com.github.romualdrousseau.shuju.columns.*;
import com.github.romualdrousseau.shuju.cv.*;
import com.github.romualdrousseau.shuju.*;
import com.github.romualdrousseau.shuju.json.processing.*;
import com.github.romualdrousseau.shuju.math.*;
import com.github.romualdrousseau.shuju.ml.nn.activation.*;
import com.github.romualdrousseau.shuju.ml.nn.initializer.*;
import com.github.romualdrousseau.shuju.ml.nn.loss.*;
import com.github.romualdrousseau.shuju.ml.nn.normalizer.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.*;
import com.github.romualdrousseau.shuju.ml.qlearner.*;
import com.github.romualdrousseau.shuju.nlp.impl.*;
import com.github.romualdrousseau.shuju.transforms.*;
import com.github.romualdrousseau.shuju.ml.nn.*;
import com.github.romualdrousseau.shuju.nlp.*;
import com.github.romualdrousseau.shuju.cv.templatematching.*;
import com.github.romualdrousseau.shuju.genetic.*;
import com.github.romualdrousseau.shuju.math.distribution.*;
import com.github.romualdrousseau.shuju.ml.kmean.*;
import com.github.romualdrousseau.shuju.cv.templatematching.shapeextractor.*;
import com.github.romualdrousseau.shuju.json.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.builder.*;
import com.github.romualdrousseau.shuju.util.*;
import com.github.romualdrousseau.shuju.ml.knn.*;
import com.github.romualdrousseau.shuju.ml.nn.scheduler.*;
import com.github.romualdrousseau.shuju.ml.slr.*;
import com.github.romualdrousseau.shuju.ml.naivebayes.*;

class GeneticNeuralNetwork {
  Layer layer1;
  Layer layer2;
  Optimizer optimizer;
  LearningRateScheduler learningRateScheduler;
  float epochs;
  float fitness;

  public GeneticNeuralNetwork() {
    this.layer1 = null;
    this.layer2 = null;
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = 0.0;
    this.fitness = 0.0;
  }
  
  public GeneticNeuralNetwork(com.github.romualdrousseau.shuju.json.JSONObject json) {
    this.layer1 = new Layer(json.getJSONObject("layer1"));
    this.layer2 = new Layer(json.getJSONObject("layer2"));
    this.optimizer = null;
    this.learningRateScheduler = null;
    this.epochs = json.getFloat("epochs");
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
    this.layer1.reset();
    this.layer2.reset();
    this.epochs = 0.0;
    this.fitness = 0.0;
  }

  public void compile(boolean shuffle, Optimizer optimizer) {
    this.optimizer = optimizer;
    this.learningRateScheduler = null;
    if(shuffle) {
      this.reset();
    }
  }
  
  public Matrix predict(Matrix input) {
    Matrix hidden = this.layer1.feedForward(input);
    Matrix output = this.layer2.feedForward(hidden);
    return output;
  }
  
  public void mutate() {
    this.optimizer.optimize(this.layer1, null, null, null);
    this.optimizer.optimize(this.layer2, null, null, null);

    this.epochs += 1.0;

    if (this.learningRateScheduler != null) {
      this.learningRateScheduler.adapt(this.optimizer, this.epochs);
    }
  }

  public com.github.romualdrousseau.shuju.json.JSONObject toJSON() {
    com.github.romualdrousseau.shuju.json.JSONObject json = JSON.newJSONObject();
    json.setJSONObject("layer1", this.layer1.toJSON());
    json.setJSONObject("layer2", this.layer2.toJSON());
    json.setFloat("epochs", this.epochs);
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
    this(inputUnits, units, new TanhActivationFunction());
  }

  public Layer(int inputUnits, int units, ActivationFunction activation) {
    this.weights = new Matrix(units, inputUnits);
    this.gradients = new Matrix(units, 1);
    this.bias = new Matrix(units, 1);
    this.activation = activation;
  }
  
  public Layer(com.github.romualdrousseau.shuju.json.JSONObject json) {
    this(json, new TanhActivationFunction());
  }
  
  public Layer(com.github.romualdrousseau.shuju.json.JSONObject json, ActivationFunction activation) {
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
    return this.weights.colCount();
  }

  public int getOutputUnits() {
    return this.weights.rowCount();
  }

  public void reset() {
    this.weights.randomize(this.weights.rowCount());
    this.gradients.zero();
    this.bias.randomize(this.bias.rowCount());
  }

  public Layer clone() {
    return new Layer(this);
  }

  public Matrix feedForward(Matrix input) {
    return this.activation.activate(this.weights.transform(input).add(this.bias));
  }

  public Matrix propagateError(Matrix loss) {
    return this.weights.transpose().transform(loss);
  }
  
  public com.github.romualdrousseau.shuju.json.JSONObject toJSON() {
    com.github.romualdrousseau.shuju.json.JSONObject json = JSON.newJSONObject();
    json.setJSONObject("weights", this.weights.toJSON());
    json.setJSONObject("gradients", this.gradients.toJSON());
    json.setJSONObject("bias", this.bias.toJSON());
    return json;
  }
}

interface LearningRateScheduler {
  void adapt(Optimizer optimizer, float epoch);
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

interface ActivationFunction {
  Matrix activate(Matrix input);
  Matrix derivate(Matrix output, Matrix error);
}

class TanhActivationFunction implements ActivationFunction {
  Matrix activate(Matrix input) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        float a = exp(x);
        float b = exp(-x);
        return (a - b) / (a + b);
      }
    };
    return input.map(fn);
  }
  
  Matrix derivate(Matrix output, Matrix error) {
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix matrix) {
        return 1.0 - y * y;
      }
    };
    
    Matrix m = output.copy();

    return m.map(fn).mult(error);
  }
}

class SoftmaxActivationFunction implements ActivationFunction {
  Matrix activate(Matrix input) {
    if(input.colCount() > 1) {
      throw new IllegalArgumentException("Softmax must be used on the output layer");
    }
    
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
        return exp(x);
      }
    };
    
    float sum = 0.0;
    for(int k = 0; k < input.rowCount(); k++) {
      sum += exp(input.get(k, 0));
    }

    return input.map(fn).div(sum);
  }
  
  Matrix derivate(Matrix output, Matrix error) {
    if(output.colCount() > 1) {
      throw new IllegalArgumentException("Softmax must be used on the output layer");
    }
    
    final MatrixFunction<Float, Float> fn = new MatrixFunction<Float, Float>() {
      public final Float apply(Float y, int row, int col, Matrix matrix) {
        return (row == col) ? y * (1 - y) : -y * matrix.get(col, col);
      }
    };
    
    // Matrix m = output.copy().ones().transform(output.transpose());
    Matrix m = new Matrix(output.rowCount(), output.rowCount());
    for(int i = 0; i < m.rowCount(); i++) {
      for(int j = 0; j < m.colCount(); j++) {
        m.set(i, j, output.get(j, 0)); 
      }
    }

    return m.map(fn).transform(error);
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

class OptimizerGenetic extends Optimizer {
  float mutationRate;

  public OptimizerGenetic(float learningRate, float mutationRate) {
    super(learningRate);
    this.mutationRate = mutationRate;
  }

  public void optimize(Layer layer, Matrix input, Matrix output, Matrix error) {
    MatrixFunction<Float, Float> mutationFunc = new MatrixFunction<Float, Float>() {
      public final Float apply(Float x, int row, int col, Matrix matrix) {
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
