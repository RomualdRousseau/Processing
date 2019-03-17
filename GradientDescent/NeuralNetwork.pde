interface ActivationFunc {
  Matrix apply(Matrix x);
  Matrix derivate(Matrix y);
}

interface LossFunc {
  Matrix apply(Matrix output, Matrix target);
  Matrix derivate(Matrix output, Matrix target);
}

interface InitializerFunc {
  void apply(Matrix m);
}

interface NormalizerFunc {
  void apply(Matrix m);
}

interface LearningRateScheduler {
  void apply(Optimizer optimizer);
}

class Parameters {
  Matrix W, G, M, V;

  Parameters(int units) {
    this(1, units);
  }

  Parameters(int inputUnits, int units) {
    this.W = new Matrix(units, inputUnits);
    this.G = new Matrix(units, inputUnits);
    this.M = new Matrix(units, inputUnits);
    this.V = new Matrix(units, inputUnits);
  }

  void reset() {
    this.W.zero();
    this.G.zero();
    this.M.zero();
    this.V.zero();
  }
}

class Layer {
  Parameters weights;
  Parameters biases;
  ActivationFunc activation;
  InitializerFunc initializer;
  NormalizerFunc normalizer;
  Matrix output;
  float bias;
  Layer prev;
  Layer next;

  Layer() {
    this(0, 0, null, null, null);
  }

  Layer(int inputUnits, int units) {
    this(inputUnits, units, null, null, null);
  }

  Layer(int inputUnits, int units, ActivationFunc activation) {
    this(inputUnits, units, activation, null, null);
  }

  Layer(int inputUnits, int units, ActivationFunc activation, InitializerFunc initializer) {
    this(inputUnits, units, activation, initializer, null);
  }

  Layer(int inputUnits, int units, ActivationFunc activation, InitializerFunc initializer, NormalizerFunc normalizer) {
    this.weights = new Parameters(inputUnits, units);
    this.biases = new Parameters(units);
    this.activation = (activation == null) ? Linear : activation;
    this.initializer = (initializer == null) ? GlorotUniformInitializer : initializer;
    this.normalizer = normalizer;
    this.output = null;
    this.bias = 1.0;
    this.prev = null;
    this.next = null;
    this.reset();
  }

  void reset() {
    this.weights.reset();
    this.initializer.apply(this.weights.W);
    this.biases.reset();
  }

  void adjustGradients(Parameters p, Matrix g) {
    p.W.sub(g);
    if (this.normalizer != null) {
      this.normalizer.apply(p.W);
    }
  }
  
  Matrix detach() {
    return this.output;
  }
}

class Model {
  Layer start;
  Layer end;

  Model() {
    this.start = new Layer();
    this.end = this.start;
  }

  void reset() {
    for (Layer layer = this.start.next; layer != null; layer = layer.next) {
      layer.reset();
    }
  }

  void add(Layer layer) {
    layer.prev = this.end;  
    this.end.next = layer;
    this.end = layer;
  }

  Layer model(Matrix input) {
    this.start.output = input;
    for (Layer layer = this.start.next; layer != null; layer = layer.next) {
      Matrix net = xw_plus_b(layer.prev.output, layer.weights.W, layer.biases.W); 
      layer.output = layer.activation.apply(net);
    }
    return this.end;
  }
}

class Loss {
  LossFunc lossFunc;
  Matrix value;
  Matrix rate;
  Layer output;

  Loss(LossFunc lossFunc) {
    this.lossFunc = lossFunc;
  }

  Loss loss(Layer output, Matrix target) {
    this.value = this.lossFunc.apply(output.output, target);
    this.rate = this.lossFunc.derivate(output.output, target);
    this.output = output;
    return this;
  }

  Loss backward() {
    Matrix error = this.rate;
    for (Layer layer = this.output; layer.prev != null; layer = layer.prev) {
      // An equation for the error in the output layer
      //error = layer.activation.derivate(layer.output).squarify(true).transform(error);
      error = diag_mul_b(error, layer.activation.derivate(layer.output));
      // An equation for the rate of change of the error with respect to any weight in the network
      Matrix deltaWeigths = error.transform(layer.prev.output, false, true);
      // An equation for the rate of change of the error with respect to any bias in the network
      Matrix deltaBiases = error.copy().mult(layer.prev.bias);
      // An equation for the error in terms of the error in the next layer
      error = layer.weights.W.transform(error, true, false);
      // Updates the weights and the biases by their deltas
      layer.weights.G.add(deltaWeigths);
      layer.biases.G.add(deltaBiases);
    }
    return this;
  }
}

abstract class Optimizer {
  Model model;
  LearningRateScheduler scheduler;
  float learningRate0, learningRate;
  int epoch;

  Optimizer(Model model) {
    this(model, 0.001, null);
  }

  Optimizer(Model model, float learningRate) {
    this(model, learningRate, null);
  }

  Optimizer(Model model, float learningRate, LearningRateScheduler scheduler) {
    this.model = model;
    this.learningRate0 = learningRate;
    this.learningRate = learningRate;
    this.epoch = 1;
    this.scheduler = scheduler;
  }

  void reset() {
    this.learningRate = this.learningRate0;
    this.epoch = 1;
  }

  void zeroGradients() {
    for (Layer layer = this.model.start.next; layer != null; layer = layer.next) {
      layer.weights.G.zero();
      layer.biases.G.zero();
    }
  }

  void step() {
    for (Layer layer = this.model.start.next; layer != null; layer = layer.next) {
      layer.adjustGradients(layer.weights, this.computeGradients(layer.weights));
      layer.adjustGradients(layer.biases, this.computeGradients(layer.biases));
    }

    this.epoch++;

    if (this.scheduler != null) {
      this.scheduler.apply(this);
    }
  }

  abstract Matrix computeGradients(Parameters p);
}
