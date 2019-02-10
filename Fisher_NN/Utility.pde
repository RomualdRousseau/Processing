float[] categoricalFeature(String s, String[] vocabulary) {
  float[] result = new float[3];
  for (int i = 0; i < vocabulary.length; i++) {
    result[i] = s.equals(vocabulary[i]) ? 1.0 : 0.0;
  }
  return result;
}

ArrayList<Float[]> shuffle(ArrayList<Float[]> dataSet) {
  ArrayList<Float[]> result = new ArrayList<Float[]>();
  while (dataSet.size() > 0) {
    int r = floor(random(dataSet.size()));
    Float[] data = dataSet.get(r);
    dataSet.remove(r);
    result.add(data);
  }
  return result;
}

void normalize(ArrayList<Float[]> dataSet, int i) {
  float min = dataSet.get(0)[i];
  for (Float[] data : dataSet) {
    if(data[i] < min) {
      min = data[i];
    }
  }
  
  float max = dataSet.get(0)[i];
  for (Float[] data : dataSet) {
    if(data[i] > max) {
      max = data[i];
    }
  }
  
  float w = 1.0 / (max - min);

  for (Float[] data : dataSet) {
    data[i] = (data[i] - min) * w;
  }
}

ArrayList<Float[]> subset(ArrayList<Float[]> dataSet, int min, int max) {
  ArrayList<Float[]> result = new ArrayList<Float[]>();
  for (int i = min; i < max; i++) {
    Float[] data = dataSet.get(i);
    result.add(data);
  }
  return result;
}
