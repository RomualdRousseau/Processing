static final int EPISODE_DURATION = 1000;
static final int EPISODE_MAX = 1000;
static final float DISCOUNT_RATE = 0.95;
static final int BATCH_SIZE = 32;
static final float GREEDY_MAX = 1.0;
static final float GREEDY_MIN = 0.05;
static final float GREEDY_DECAY = 0.018;
static final float LEARNING_RATE_MAX = 0.001;
static final float LEARNING_RATE_MIN = 0.0001;
static final float LEARNING_RATE_DECAY = 0.018;
static final float MUTATION_RATE = 0.1;
static final int POPULATION_SIZE = 10;
static final int GENERATION_SIZE = 10;

void setup() {
  size(400, 400, P2D);
  thread("hyperParameters");
}

void draw() {
  background(51);
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

    while (population.size() > 0) {

      for (int i = 0; i < population.size(); i++) {
        DQN dqn = population.get(i);
        println(String.format("Individual: %d %d %d %d %f %f %d %d %d%%", i, 
          dqn.memoryReplaySize, 
          dqn.targetSyncRate, 
          dqn.qnetworkHiddenCount, 
          dqn.greedyRate, 
          dqn.qnetwork.optimizer.learningRate, 
          dqn.episodeCount, 
          floor(dqn.getFitness()), 
          floor(dqn.episodeCount * 100 / EPISODE_MAX)));
      }

      for (int i = population.size() - 1; i >= 0; i--) {
        DQN dqn = population.get(i);
        dqn.learn();
        if (dqn.episodeCount == EPISODE_MAX) {
          Genetic.pool.add(dqn);
          population.remove(i);
        }
      }
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
