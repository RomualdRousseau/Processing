interface BaseGame {
  int getActionCount();

  int getStateCount();

  float[] getState();

  float getReward();

  boolean isGameOver();

  boolean isWon();

  void restart(int episode);

  void runOneStep(int a);
  
  void show();
}

class DQN implements Individual {
  BaseGame game;

  int memoryReplaySize;
  int qnetworkHiddenCount;
  int targetSyncRate;
  int targetSyncTime;
  int episodeCount;
  int episodeStep;
  float greedyRate;
  boolean trainingMode = true;

  GeneticNeuralNetwork qnetwork;
  GeneticNeuralNetwork qtarget;
  MemoryReplay memoryReplay;

  DQN(BaseGame game) {
    this(game, 
      memoryReplaySizeDistribution[floor(random(memoryReplaySizeDistribution.length))],
      targetSyncRateDistribution[floor(random(targetSyncRateDistribution.length))],
      qnetworkHiddenCountDistribution[floor(random(qnetworkHiddenCountDistribution.length))]);
  }

  DQN(BaseGame game, DQN parent) {
    this(game, 
      parent.memoryReplaySize, 
      parent.targetSyncRate, 
      parent.qnetworkHiddenCount);
  }

  DQN(BaseGame game, int memoryReplaySize, int targetSyncRate, int qnetworkHiddenCount) {
    this.game = game;
    this.memoryReplaySize = memoryReplaySize;
    this.qnetworkHiddenCount = qnetworkHiddenCount;
    this.targetSyncTime = 0;
    this.targetSyncRate = targetSyncRate;
    this.episodeCount = 0;
    this.episodeStep = 0;
    this.greedyRate = 1.0;
    this.trainingMode = true;
  }

  public float getFitness() {
    return this.qnetwork.fitness;
  }

  public void setFitness(float fitness) {
    this.qnetwork.fitness = fitness;
  }

  public void mutate() {
    if (random(1.0) < MUTATION_RATE) {
      this.memoryReplaySize += constrain(floor(random(-100, 100)), 1000, 100000);
    }
    if (random(1.0) < MUTATION_RATE) {
      this.targetSyncRate += constrain(floor(random(-100, 100)), 100, 10000);
    }
    if (random(1.0) < MUTATION_RATE) {
      this.qnetworkHiddenCount += constrain(floor(random(-4, 4)), 8, 32);
    }
  }

  public void compile() {
    this.memoryReplay = new MemoryReplay(this.memoryReplaySize);
    this.qnetwork = this.buildModel(this.qnetworkHiddenCount);
    this.qtarget = qnetwork.clone();
  }
  
  public int predict(float[] s) {
    int a;
    float r;

    if (trainingMode) {
      r = this.greedyRate;
      this.greedyRate = max(GREEDY_MIN, this.greedyRate * exp(-GREEDY_DECAY / EPISODE_DURATION));
    } else {
      r = GREEDY_MIN;
    }

    if (random(1.0) < r) {
      a = floor(random(this.game.getActionCount()));
    } else {
      a = qnetwork.predict(new Matrix(s)).argmax(0);
    }

    return a;
  }

  public void learn() {
    float[] s = this.game.getState();
    int a = this.predict(s);
    this.game.runOneStep(a);

    this.fit(s, a);

    episodeStep++;
    if (game.isGameOver() || episodeStep >= EPISODE_DURATION) {
      if (game.isWon()) {
        this.qnetwork.fitness += 1.0;
      }
      episodeStep = 0;
      episodeCount++;
      this.game.restart(episodeCount);
    }
  }

  public void fit(float[] s, int a) {
    if (!trainingMode) {
      return;
    }

    this.memoryReplay.add(s, a, this.game.getReward(), this.game.getState(), this.game.isGameOver());

    if (this.memoryReplay.size() < this.memoryReplaySize) {
      return;
    }
    
    this.qnetwork.optimizer.zeroGradients();

    int[] batch = this.memoryReplay.pickSample(BATCH_SIZE);
    
    for (int b = 0; b < batch.length; b++) {
      MemorySlot m = this.memoryReplay.slots.getData(batch[b]);

      Matrix output_1 = this.qnetwork.predict(new Matrix(m.s_1));
      
      Matrix output = this.qnetwork.predict(new Matrix(m.s));

      Matrix target = output.copy();
      if (m.done) {
        target.set(m.a, 0, m.reward);
      } else {
        Matrix q_a_s_1 = this.qtarget.predict(new Matrix(m.s_1));
        //float maxQ = q_a_s_1.get(q_a_s_1.argmax(0), 0);
        float maxQ = q_a_s_1.get(output_1.argmax(0), 0);
        target.set(m.a, 0, m.reward + DISCOUNT_RATE * maxQ);
      }
      float error = abs(output.get(m.a, 0) - target.get(m.a, 0));
      
      Matrix lossRate = this.qnetwork.loss.derivate(output, target);
      this.qnetwork.loss.backward(lossRate);

      this.memoryReplay.update(batch[b], error);
    }
    
    this.qnetwork.optimizer.step();

    this.qnetwork.optimizer.decayLearningRate();

    this.targetSyncTime++;
    if (this.targetSyncTime >= targetSyncRate) {
      this.qtarget = this.qnetwork.clone();
      this.targetSyncTime = 0;
    }
  }

  public GeneticNeuralNetwork buildModel(int qnetworkHiddenCount) {
    Layer layer1 = new Layer(game.getStateCount(), qnetworkHiddenCount)
      .setActivation(new ReluActivation())
      .setInitializer(new GlorotUniformInitializer())
      .setNormalize(false);

    Layer layer2 = new Layer(layer1.getOutputUnits(), game.getActionCount())
      .setActivation(new LinearActivation())
      .setInitializer(new GlorotUniformInitializer())
      .setNormalize(false);

    Optimizer optimizer = new OptimizerRMSProp();

    LossFunction loss = new Huber();

    GeneticNeuralNetwork model = (GeneticNeuralNetwork) new GeneticNeuralNetwork()
      .setMutationRate(0.1)
      .addLayer(layer1)
      .addLayer(layer2)
      .compile(loss, optimizer);

    return model;
  }
}
