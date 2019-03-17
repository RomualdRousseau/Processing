class Brain {
  Model model;
  Optimizer optimizer;
  Loss criterion;
  float accuracy;
  float mean;

  Brain() {
    if (BRAIN_MODEL.equals("Softmax")) {
      this.buildModelSoftmax();
    } else if (BRAIN_MODEL.equals("Huber")) {
      this.buildModelHuber();
    } else if (BRAIN_MODEL.equals("MSE")) {
      this.buildModelMSE();
    } 
    this.accuracy = 0.0;
    this.mean = 1.0;
  }

  Matrix predict(PVector point) {
    Matrix input = new Matrix(new float[] { point.x, point.y });
    return this.model.model(input).detach();
  }

  void fit(ArrayList<PVector> points) {
    if (points.size() == 0 || this.mean < 1e-4) {
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
    this.model.add(new Layer(2, BRAIN_HIDDEN_NEURONS, LeakyRelu, GlorotUniformInitializer, BatchNormalizer));
    this.model.add(new Layer(BRAIN_HIDDEN_NEURONS, 2, Softmax));

    this.optimizer = new OptimizerAdam(this.model);

    this.criterion = new Loss(SoftmaxCrossEntropy);
  }

  void buildModelMSE() {
    this.model = new Model();
    this.model.add(new Layer(2, BRAIN_HIDDEN_NEURONS, Tanh));
    this.model.add(new Layer(BRAIN_HIDDEN_NEURONS, 2, Linear));

    this.optimizer = new OptimizerSgd(this.model, 0.1, new ExponentialScheduler(0.0001, 1, 0.001));

    this.criterion = new Loss(MeanSquaredError);
  }

  void buildModelHuber() {
    this.model = new Model();
    this.model.add(new Layer(2, BRAIN_HIDDEN_NEURONS, Relu));
    this.model.add(new Layer(BRAIN_HIDDEN_NEURONS, 2, Linear));

    this.optimizer = new OptimizerRMSProp(this.model);

    this.criterion = new Loss(Huber);
  }
}
