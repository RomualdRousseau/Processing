static final int EPISODE_DURATION = 1000;
static final int EPISODE_MAX = 1000;
static final float DISCOUNT_RATE = 0.95;
static final int BATCH_SIZE = 64;
static final float GREEDY_MAX = 1.0;
static final float GREEDY_MIN = 0.05;
static final float GREEDY_DECAY = 0.018;
static final float LEARNING_RATE_MAX = 0.1;
static final float LEARNING_RATE_MIN = 0.001;
static final float LEARNING_RATE_DECAY = 0.018;
static final float MUTATION_RATE = 0.1;
static final int POPULATION_SIZE = 100;
static final int GENERATION_SIZE = 100;

int[] memoryReplaySizeDistribution = { 1000, 10000, 100000 };
int[] targetSyncRateDistribution = { 100, 1000, 10000 };
int[] qnetworkHiddenCountDistribution = { 8, 12, 16, 20, 24, 28, 32 };

DQN oneDQN;

void setup() {
  size(400, 400, P2D);

  oneDQN = new DQN(new Game(), 100000, 10000, 32);
  oneDQN.compile();
}

void draw() {
  print(String.format("Individual %d: %d %d %d processing ...", 0, 
    oneDQN.memoryReplaySize, 
    oneDQN.targetSyncRate, 
    oneDQN.qnetworkHiddenCount));

  for (int i  = 0; i < 10; i++) {
    oneDQN.learn();
  }

  println(String.format("%d %f %f %d %d", 
    oneDQN.episodeCount, 
    oneDQN.greedyRate, 
    oneDQN.qnetwork.optimizer.learningRate, 
    oneDQN.episodeCount, 
    floor(oneDQN.getFitness())));

  background(51);
  oneDQN.game.show();
}

void hyperParameters() {
  ArrayList<DQN> population = new ArrayList<DQN>();

  for (int g = 0; g < GENERATION_SIZE; g++) {
    println("Generation: " + g);

    if (g == 0) {
      for (int i  = 0; i < POPULATION_SIZE; i++) {
        DQN newDQN = new DQN(new Game());
        newDQN.compile();
        population.add(newDQN);
      }
    } else {
      Genetic.samplePool();
      Genetic.normalizePool();
      for (int i = 0; i < POPULATION_SIZE; i++) {
        DQN newDQN = new DQN(new Game(), (DQN) Genetic.selectParent());
        newDQN.mutate();
        newDQN.compile();
        population.add(newDQN);
      }

      DQN dqn = (DQN) Genetic.pool.get(0);
      println(String.format("Best Individual: %d %d %d %d", 
        dqn.memoryReplaySize, 
        dqn.targetSyncRate, 
        dqn.qnetworkHiddenCount, 
        floor(dqn.getFitness())));
    }

    Genetic.newPool();

    for (int i = population.size() - 1; i >= 0; i--) {
      DQN dqn = population.get(i);

      print(String.format("Individual %d: %d %d %d processing ...", i, 
        dqn.memoryReplaySize, 
        dqn.targetSyncRate, 
        dqn.qnetworkHiddenCount));

      while (dqn.episodeCount < EPISODE_MAX) {
        dqn.learn();
      }

      Genetic.pool.add(dqn);
      population.remove(dqn);

      println(String.format("%f %f %d %d", 
        dqn.greedyRate, 
        dqn.qnetwork.optimizer.learningRate, 
        dqn.episodeCount, 
        floor(dqn.getFitness())));
    }
  }

  Genetic.samplePool(1);
  DQN dqn = (DQN) Genetic.pool.get(0);
  println(String.format("Best Individual: %d %d %d %d", 
    dqn.memoryReplaySize, 
    dqn.targetSyncRate, 
    dqn.qnetworkHiddenCount, 
    floor(dqn.getFitness())));
}
