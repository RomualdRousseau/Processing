ArrayList<Script> scripts = new ArrayList<Script>();
int state  = 0;

class Script {
  float weight;
  float minWeight;
  float maxWeight;
  boolean activated;
  int action;

  Script(int action) {
    this.minWeight = 0.0001;
    this.maxWeight = 1.0;
    this.weight = random(this.minWeight, this.maxWeight);
    this.activated = false;
    this.action = action;
  }
}

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

  return scripts.get(max(0, bestIndex));
}

void buildSCript(int l) {
  for (int n = 0; n < l; ) {
    Script script = pickOne();
    if (!script.activated) {
      script.activated = true;
      n++;
    }
  }
  state = 0;
}

Script getNextScript() {
  while (state < scripts.size() && !scripts.get(state).activated) state++;
  if (state >= scripts.size()) {
    return null;
  }

  return scripts.get(state++);
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

void printScripts() {
  for (int i = 0; i < scripts.size(); i++) {
    Script script = scripts.get(i);
    println(script.weight, script.activated, script.action);
  }
}
