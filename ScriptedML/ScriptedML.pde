Environment env = new Environment();
int score = 0;
int episodes = 0;

void setup() {
  size(400, 400);

  scripts.add(new Script(0));
  scripts.add(new Script(1));
  scripts.add(new Script(2));
  scripts.add(new Script(3));
  scripts.add(new Script(4));
  scripts.add(new Script(5));
  
  env.reset();
  buildSCript(3);
}

void draw() {
  Observation obs;
  
  env.render();
  fill(255);
  text(String.format("%d %d", score, episodes), 150, 16);
  
  if (env.busy()) {
    return;
  }
  
  Script script = getNextScript(); 
   
  if(script != null) {
    obs = env.step(script.action);
  } else {
    obs = env.getLastObservation();
  }
  
  if(!obs.done && obs.async) {
    return;
  }

  if(obs.reward == 1.0) {
    score++;
  }
  
  adjustWeights(obs.reward, 2, 0.01);

  episodes++;
  
  env.reset();
  buildSCript(3);
}
