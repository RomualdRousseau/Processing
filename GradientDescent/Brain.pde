class Brain_ {
  Model model;
  Optimizer optimizer;
  Loss criterion;
  float accuracy;
  float mean;
  boolean dataChanged;
  
  Brain_() {
    this.accuracy = 0.0;
    this.mean = 1.0;
    this.dataChanged = false;
  }

  void init(String modelName) {
    if (modelName.equals("Softmax")) {
      this.buildModelSoftmax();
    } else if (modelName.equals("Huber")) {
      this.buildModelHuber();
    } else if (modelName.equals("MSE")) {
      this.buildModelMSE();
    }
  }

  Matrix predict(PVector point) {
    Matrix input = new Matrix(new float[] { point.x, point.y });
    return this.model.model(input).detach();
  }

  void fit(ArrayList<PVector> points) {
    if (!this.dataChanged && (points.size() == 0 || this.mean < 1e-4)) {
      this.dataChanged = false;
      return;
    }

    for (int n = 0; n < BRAIN_CLOCK; n++) {
      float sumAccu = 0.0;
      float sumMean = 0.0;

      this.optimizer.zeroGradients();

      for (int i = 0; i < points.size(); i++) {
        PVector point = points.get(i);

        Matrix input = new Matrix(new float[] { point.x, point.y });
        Matrix target = new Matrix(oneHot(int(point.z), 2));

        Layer output = this.model.model(input);
        Loss loss = this.criterion.loss(output, target);
        loss.backward();

        sumAccu += (output.output.argmax(0) == target.argmax(0)) ? 1 : 0;
        sumMean += loss.value.flatten(0);

        if (Float.isNaN(sumMean)) {
          sumMean = 0.0;
          println(loss.value);
          println(target);
          println(output.detach());
        }
      }

      this.optimizer.step();

      this.accuracy = constrain(sumAccu / points.size(), 0, 1);
      this.mean = constrain(sumMean / points.size(), 0, 1);
    }
  }

  void buildModelSoftmax() {
    this.model = new Model();
    
    this.model.add(new LayerBuilder()
      .setInputUnits(2)
      .setUnits(BRAIN_HIDDEN_NEURONS)
      .setActivation(LeakyRelu)
      .setNormalizer(BatchNormalizer)
      .build());
      
    this.model.add(new LayerBuilder()
      .setInputUnits(BRAIN_HIDDEN_NEURONS)
      .setUnits(BRAIN_HIDDEN_NEURONS)
      .setActivation(LeakyRelu)
      .setNormalizer(BatchNormalizer)
      .build());
      
    this.model.add(new LayerBuilder()
      .setInputUnits(BRAIN_HIDDEN_NEURONS)
      .setUnits(2)
      .setActivation(Softmax)
      .build());
    
    this.optimizer = new OptimizerAdamBuilder().build(this.model);

    this.criterion = new Loss(SoftmaxCrossEntropy);
  }

  void buildModelMSE() {
    this.model = new Model();
    
    this.model.add(new LayerBuilder()
      .setInputUnits(2)
      .setUnits(BRAIN_HIDDEN_NEURONS)
      .setActivation(Tanh)
      .build());
      
    this.model.add(new LayerBuilder()
      .setInputUnits(BRAIN_HIDDEN_NEURONS)
      .setUnits(2)
      .setActivation(Linear)
      .build());

    this.optimizer = new OptimizerSgdBuilder()
      .setLearningRate(0.1)
      .setScheduler(new ExponentialScheduler(0.0001, 1, 0.001))
      .build(this.model);

    this.criterion = new Loss(MeanSquaredError);
  }

  void buildModelHuber() {
    this.model = new Model();
    
    this.model.add(new LayerBuilder()
      .setInputUnits(2)
      .setUnits(BRAIN_HIDDEN_NEURONS)
      .setActivation(Relu)
      .build());
      
    this.model.add(new LayerBuilder()
      .setInputUnits(BRAIN_HIDDEN_NEURONS)
      .setUnits(2)
      .setActivation(Linear)
      .build());

    this.optimizer = new OptimizerRMSPropBuilder().build(this.model);

    this.criterion = new Loss(Huber);
  }
  
  String toString() {
    String result = "";
    for (Layer layer = this.model.start.next; layer != null; layer = layer.next) {
      if (layer.prev == this.model.start) {
        result += String.format("%d -> %d -> %s ->", layer.weights.W.cols, layer.weights.W.rows, getClassInfo(layer.activation));
      } else if (layer.next == null) {
        result += String.format("%d -> %s", layer.weights.W.rows, getClassInfo(layer.activation));
      } else {
        result += String.format("%d -> %s ->", layer.weights.W.rows, getClassInfo(layer.activation));
      }
    }
    return result;
  }
}
Brain_ Brain = new Brain_();
