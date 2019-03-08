class FloatVector implements Comparable
{
  public FloatVector(float[] data) {
    this.data = data;
  }

  public boolean equals(Object obj) {
    FloatVector other = (FloatVector) obj;
    boolean result = other.data.length == data.length;
    for (int i = 0; i < data.length; i++) {
      result &= other.data[i] == data[i];
    }
    return result;
  }
  
  public int compareTo(Object obj) {
    return 0;
  }
  
  public FloatVector copy() {
    float[] copyData = new float[data.length];
    for (int i = 0; i < data.length; i++) {
      copyData[i] = data[i];
    }
    return new FloatVector(copyData);
  }
  
  public int count() {
    int count  = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] != 0.0) {
        count++;
      }
    }
    return count;
  }
  
  public int maxIndex() {
    int maxIndex = -1;
    float maxValue = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > maxValue) {
        maxIndex = i;
        maxValue = data[i];
      }
    }
    return maxIndex;
  }
  
  public int minIndex() {
    int minIndex = -1;
    float minValue = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] < minValue) {
        minIndex = i;
        minValue = data[i];
      }
    }
    return minIndex;
  }
  
  public float max() {
    float maxValue = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > maxValue) {
        maxValue = data[i];
      }
    }
    return maxValue;
  }
  
  public float min() {
    float minValue = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] < minValue) {
        minValue = data[i];
      }
    }
    return minValue;
  }

  public float sum() {
    float sum = 0;
    for (int i = 0; i < data.length; i++) {
      sum += data[i];
    }
    return sum;
  }

  public float lenght() {
    float sum = 0;
    for (int i = 0; i < data.length; i++) {
      sum += data[i] * data[i];
    }
    return (float) Math.sqrt(sum);
  }
  
  public float get(int i) {
    return data[i];
  }
  
  public float tf(int i) {
    return data[i] / sum();
  }

  public float cosine(FloatVector other) {
    if(other.data.length != data.length) {
      throw new IllegalArgumentException();
    }
    
    float sum = 0;
    for (int i = 0; i < data.length; i++) {
      sum += data[i] * other.data[i];
    }
    return sum;
  }
  
  public FloatVector normalize() {
    float w = 1.0 / lenght();
    for (int i = 0; i < data.length; i++) {
      data[i] *= w;
    }
    return this;
  }
  
  public FloatVector add(FloatVector other) {
    if(other.data.length != data.length) {
      throw new IllegalArgumentException();
    }
    
    for (int i = 0; i < data.length; i++) {
      data[i] += other.data[i];
    }
    return this;
  }

  public FloatVector sub(FloatVector other) {
    if(other.data.length != data.length) {
      throw new IllegalArgumentException();
    }
    
    for (int i = 0; i < data.length; i++) {
      data[i] -= other.data[i];
    }
    return this;
  }

  public FloatVector mul(float c) {
    for (int i = 0; i < data.length; i++) {
      data[i] *= c;
    }
    return this;
  }

  public FloatVector div(float c) {
    for (int i = 0; i < data.length; i++) {
      data[i] /= c;
    }
    return this;
  }

  public FloatVector limitMin(float c) {
    for (int i = 0; i < data.length; i++) {
      data[i] = Math.min(data[i], c);
    }
    return this;
  }

  public FloatVector limitMax(float c) {
    for (int i = 0; i < data.length; i++) {
      data[i] = Math.max(data[i], c);
    }
    return this;
  }
  
  public String toString() {
    String s = "";
    for (int i = 0; i < data.length; i++) {
      s += String.format("%.2f ", data[i]);
    }
    return s.trim();
  }
  
  public String toString(String[] lexicalItems) {
    String s = "";
    for (int i = 0; i < data.length; i++) {
      if(data[i] != 0.0) {
        s += String.format("%s ", lexicalItems[i]);
      }
    }
    return s.trim();
  }

  protected float[] data;
}
