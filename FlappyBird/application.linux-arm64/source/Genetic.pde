class Genetic_ {
  ArrayList<Bird> pool;
  
  void newPool() {
    this.pool = new ArrayList<Bird>();
  }
  
  void calculateFitness() {
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      float b = 1.0 / (1.0 + abs(bird.altitude - PILLAR_SPACING / 2));
      bird.brain.fitness = bird.life * (0.95 + 0.05 * b); // Give a 5% bonus if the bird flies around the center of the pillars
    }
  }
  
  void samplePool() {
    this.samplePool(floor(random(1.0) * this.pool.size()));
  }
  
  void samplePool(int sampleCount) {
    Collections.sort(this.pool, Collections.reverseOrder(new Comparator<Bird>() {
      public int compare(Bird a, Bird b) {
        float d = a.brain.fitness - b.brain.fitness;
        return (d < 0) ? -1 : ((d > 0) ? 1 : 0);
      }
    }
    ));
    
    if(this.pool.size() > sampleCount) {
      for (int i = this.pool.size() - 1; i >= sampleCount; i--) {
        this.pool.remove(i);
      }
    }
  }
  
  void normalizePool() {
    float sum = 0;
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      sum += bird.brain.fitness;
    }
    
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      bird.brain.fitness /= sum;
    }
  }

  Bird selectParent() {
    float r = random(1.0);
  
    Bird bestBird = null;
    int bestBirdIndex= 0;
    while (r > 0) {
      r -= pool.get(bestBirdIndex).brain.fitness;
      bestBirdIndex++;
    }
    bestBirdIndex--;
    bestBird = pool.get(bestBirdIndex);
    
    return bestBird;
  }
}
Genetic_ Genetic = new Genetic_();
