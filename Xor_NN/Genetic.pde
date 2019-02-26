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

  void samplePool() {
    this.samplePool(floor(random(this.pool.size())));
  }

  void samplePool(int sampleCount) {
    sampleCount = max(1, sampleCount);

    Collections.sort(this.pool, Collections.reverseOrder(new Comparator<Individual>() {
      public int compare(Individual a, Individual b) {
        float d = a.getFitness() - b.getFitness();
        return (d < 0) ? -1 : ((d > 0) ? 1 : 0);
      }
    }
    ));

    if (this.pool.size() > sampleCount) {
      for (int i = this.pool.size() - 1; i >= sampleCount; i--) {
        this.pool.remove(i);
      }
    }
  }

  void normalizePool() {
    float sum = 0;
    for (int i = 0; i < this.pool.size(); i++) {
      Individual individual = this.pool.get(i);
      sum += individual.getFitness();
    }

    for (int i = 0; i < this.pool.size(); i++) {
      Individual individual = this.pool.get(i);
      individual.setFitness(individual.getFitness() / sum);
    }
  }

  Individual selectParent() {
    float r = random(1.0);

    int bestIndex= 0;
    while (r > 0) {
      r -= pool.get(bestIndex).getFitness();
      bestIndex++;
    }
    bestIndex--;

    return pool.get(bestIndex);
  }
}
Genetic_ Genetic = new Genetic_();
