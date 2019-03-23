class Script {
  float weight;
  float minWeight;
  float maxWeight;
  boolean activated;
  String text;

  Script(String text) {
    this.minWeight = 0.0001;
    this.maxWeight = 1.0;
    this.weight = random(this.minWeight, this.maxWeight);
    this.activated = false;
    this.text = text;
  }
}

ArrayList<Script> scripts = new ArrayList<Script>();

Script pickOne() {
  float sum = 0.0;
  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    sum += script.weight;
  }

  float r = random(1.0);

  int bestIndex = 0;
  while (r > 0) {
    r -= scripts.get(bestIndex).weight / sum;
    bestIndex++;
  }
  bestIndex--;

  return scripts.get(bestIndex);
}

void buildSCript(int l) {
  for (int n = 0; n < l;) {
    Script script = pickOne();
    if(!script.activated) {
      script.activated = true;
      n++;
    }
  }
}

void adjustWeights(float fitness, int l, float a) {
  float compensation = a * fitness * l / (scripts.size() - l);
  
  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    if (script.activated) {
      script.weight = constrain(script.weight + compensation, script.minWeight, script.maxWeight);
    }
    script.activated = false;
  }
  
  float sum = 0.0;
  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    sum += script.weight * script.weight;
  }
  sum = sqrt(sum);

  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    script.weight = constrain(script.weight / sum, script.minWeight, script.maxWeight);
  }
}

float getFitness() {
  if (scripts.get(0).activated && scripts.get(2).activated && scripts.get(4).activated) {
    return 1.0;
  } else {
    return -1.0;
  }
}

void setup() {
  scripts.add(new Script("Pick up soldier"));
  scripts.add(new Script("Unpick soldier"));
  scripts.add(new Script("Pick up portal"));
  scripts.add(new Script("Unpick portal"));
  scripts.add(new Script("Move"));
  scripts.add(new Script("Don't move"));

  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    println(script.weight, script.activated, script.text);
  }
}

void draw() {
  buildSCript(3);

  float fitness = getFitness();
  println(fitness == 1.0 ? "I win" : "I loose");

  adjustWeights(fitness, 3, 0.01);
}
