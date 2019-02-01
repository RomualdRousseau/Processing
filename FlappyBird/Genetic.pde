class Genetic_ {
  ArrayList<Bird> pool;
  
  void newPool() {
    this.pool = new ArrayList<Bird>();
  }
  
  void samplePool() {
    Collections.sort(this.pool, Collections.reverseOrder(new Comparator<Bird>() {
      public int compare(Bird a, Bird b) {
        return a.life - b.life;
      }
    }
    ));
    
    if(this.pool.size() > POOL_SAMPLE) {
      for (int i = this.pool.size() - 1; i >= POOL_SAMPLE; i--) {
        this.pool.remove(i);
      }
    }
  }
  
  void calculateFitness() {
    float sum = 0;
    for (int i = 0; i < this.pool.size(); i++) {
      sum += this.pool.get(i).life;
    }
    
    for (int i = 0; i < this.pool.size(); i++) {
      Bird bird = this.pool.get(i);
      bird.brain.fitness = bird.life / sum;
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
