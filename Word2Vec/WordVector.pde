class WordVector
{
  public FloatMatrix facts() {
    return facts;
  }

  public FloatMatrix labels() {
    return labels;
  }

  public FloatVector vectorize(String s, String[] lexicalItems) {
    float[] result = new float[lexicalItems.length];

    String[] tokens = s.split(" ");

    for (int i = 0; i < tokens.length; i++) {
      for (int j = 0; j < lexicalItems.length; j++) {
        result[j] = max(result[j], similarity(lexicalItems[j], tokens[i].toLowerCase()));
      }
    }

    return new FloatVector(result);
  }

  public WordVector infer(float[][] somefacts, float[][] somelabels) {
    boolean generatedNewFacts;

    do {
      generatedNewFacts = false;
      
      for (int i = 0; i < somefacts.length; i++) {
        FloatVector newFact = new FloatVector(somefacts[i]);
        FloatVector newLabel = new FloatVector(somelabels[i]);
        ArrayList<FloatVector> newFacts = new ArrayList<FloatVector>();
        ArrayList<FloatVector> newLabels = new ArrayList<FloatVector>();
        findNewFacts(newFact, newLabel, newFacts, newLabels);

        if (facts.put(newFact)) {
          labels.add(newLabel);
          generatedNewFacts = true;
        }

        for (int j = 0; j < newFacts.size(); j++) if (facts.put(newFacts.get(j))) {
          labels.add(newLabels.get(j));
          generatedNewFacts = true;
        }
      }
    } while (generatedNewFacts);
    
    return this;
  }

  public FloatVector closest(FloatVector v) {
    return labels.get(facts.cosine(v).maxIndex());
  }

  public void printSorted(String[] lexicalItems) {
    /*
    java.util.TreeMap<String, ArrayList<String>> tm = new java.util.TreeMap<String, ArrayList<String>>();
    for (int i = 0; i < facts.size(); i++) {
      String key = labels.get(i).toString(lexicalItems);
      if(tm.containsKey(key)) {
        ArrayList<String> values = tm.get(key);
        values.add(facts.get(i).toString(lexicalItems));
      }
      else {
        ArrayList<String> values = new ArrayList<String>();
        values.add(facts.get(i).toString(lexicalItems));
        tm.put(key, values);
      }
    }
    */
    
    java.util.TreeMap<FloatVector, ArrayList<FloatVector>> tm = new java.util.TreeMap<FloatVector, ArrayList<FloatVector>>();
    for (int i = 0; i < facts.size(); i++) {
      FloatVector key = labels.get(i);
      if(tm.containsKey(key)) {
        ArrayList<FloatVector> values = tm.get(key);
        values.add(facts.get(i));
      }
      else {
        ArrayList<FloatVector> values = new ArrayList<FloatVector>();
        values.add(facts.get(i));
        tm.put(key, values);
      }
    }
   
    java.util.Iterator i = tm.entrySet().iterator();
    while(i.hasNext()) {
      java.util.Map.Entry me = (java.util.Map.Entry) i.next();
      print(me.getValue());
      print(" -> ");
      println(me.getKey());
    }
  }

  private void findNewFacts(FloatVector newFact, FloatVector newLabel, ArrayList<FloatVector> newFacts, ArrayList<FloatVector> newLabels) {
    for (int i = 0; i < facts.size(); i++) {
      FloatVector label = labels.get(i);
      if (!label.equals(newLabel)) {
        continue;
      }

      FloatVector fact = facts.get(i);
      FloatVector subject = fact.copy().add(newFact).div(2.0);
      FloatVector complement1 = newFact.copy().sub(subject).mul(2.0).limitMax(0.0);
      FloatVector complement2 = fact.copy().sub(subject).mul(2.0).limitMax(0.0);

      for (int j = 0; j < facts.size(); j++) {
        FloatVector fact2 = facts.get(j);
        if (fact2.cosine(complement2) <= 0) {
          continue;
        }

        FloatVector newFact2 = fact2.copy().sub(complement2).add(complement1);
        if (newFact2.min() == 0.0) {
          newFacts.add(newFact2);
          newLabels.add(labels.get(j));
        }
      }
    }
  }

  private float similarity(String s, String t) {
    int s_len = s.length();
    int t_len = t.length();

    if (s_len == 0 && t_len == 0) return 1;

    int match_distance = Integer.max(s_len, t_len) / 2 - 1;

    boolean[] s_matches = new boolean[s_len];
    boolean[] t_matches = new boolean[t_len];

    int matches = 0;
    int transpositions = 0;

    for (int i = 0; i < s_len; i++) {
      int start = Integer.max(0, i-match_distance);
      int end = Integer.min(i+match_distance+1, t_len);

      for (int j = start; j < end; j++) {
        if (t_matches[j]) continue;
        if (s.charAt(i) != t.charAt(j)) continue;
        s_matches[i] = true;
        t_matches[j] = true;
        matches++;
        break;
      }
    }

    if (matches == 0) return 0;

    int k = 0;
    for (int i = 0; i < s_len; i++) {
      if (!s_matches[i]) continue;
      while (!t_matches[k]) k++;
      if (s.charAt(i) != t.charAt(k)) transpositions++;
      k++;
    }

    return ((((float)matches / s_len) +
      ((float)matches / t_len) +
      (((float)matches - transpositions/2.0) / matches)) / 3.0);
  }

  private FloatMatrix facts = new FloatMatrix();
  private FloatMatrix labels = new FloatMatrix();
}
