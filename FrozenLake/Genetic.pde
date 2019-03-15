import java.util.Collections;
import java.util.Comparator;

interface Individual {
  float getFitness();
  
  void setFitness(float f);
  
  void mutate();
}

class Genetic_ {
  ArrayList<Individual> pool;

  void newPool() {
    this.pool = new ArrayList<Individual>();
  }

  Individual selectBest() {
    Individual result = this.pool.get(0);
    float maxFitness = this.pool.get(0).getFitness();
    
    for (int i = this.pool.size() - 1; i > 0; i--) {
      if(this.pool.get(i).getFitness() > maxFitness) {
        result = this.pool.get(i);
        maxFitness = this.pool.get(i).getFitness();
      }
    }
    
    return result;
  }

  Individual selectParent() {
    float sum = 0;
    for (int i = 0; i < this.pool.size(); i++) {
      Individual individual = this.pool.get(i);
      sum += individual.getFitness();
    }
    
    float r = random(1.0);

    int bestIndex = 0;
    while (r > 0) {
      r -= pool.get(bestIndex).getFitness() / sum;
      bestIndex++;
    }
    bestIndex--;

    return pool.get(bestIndex);
  }
}
Genetic_ Genetic = new Genetic_();
