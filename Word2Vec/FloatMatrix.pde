class FloatMatrix
{
  public int size() {
    return data.size();
  }
  
  public FloatVector get(int i) {
    return data.get(i);
  }
  
  public boolean put(FloatVector v) {
    if(data.indexOf(v) < 0) {
      data.add(v);
      return true;
    }
    else {
      return false;
    }
  }
  
  public void add(FloatVector v) {
      data.add(v);
  }
  
  public float idf(int i) {
    float sum = 0;
    for (int j = 0; j < data.size(); j++) {
      sum += data.get(j).get(i);
    }
    return (float) Math.log((float) data.size() / sum);
  }
  
  public FloatMatrix normalize() {
    for (int i = 0; i < data.size(); i++) {
      data.get(i).normalize();
    }
    return this;
  }
  
  public FloatVector cosine(FloatVector v) {
    float[] result = new float[data.size()]; 
    for (int i = 0; i < data.size(); i++) {
      result[i] = data.get(i).cosine(v);
    }
    return new FloatVector(result);
  }

  private ArrayList<FloatVector> data = new ArrayList<FloatVector>();
}
