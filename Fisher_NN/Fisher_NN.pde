//import java.util.List;
//import java.io.IOException;
//import java.nio.file.Files;
//import java.nio.file.Paths;

static final String[] flowerWords = {
  "I. setosa", 
  "I. versicolor", 
  "I. virginica"
};

final int iterationCount = 100;
final int timeStepX = 10;

GeneticNeuralNetwork model;
Matrix[] trainingInputs;
Matrix[] trainingTargets;
Matrix[] testInputs;
Matrix[] testTargets;

FloatList timeLine1 = new FloatList();
FloatList timeLine2 = new FloatList();

public ArrayList<Float[]> loadDataSet(String fileName) throws IOException {
  ArrayList<Float[]> result = new ArrayList<Float[]>();
  Table table = loadTable(fileName, "header");  
  for (TableRow row : table.rows()) {
    Float[] dataRow = new Float[7];
    float[] label = categoricalFeature(row.getString(5), flowerWords);
    dataRow[0] = row.getFloat(1);
    dataRow[1] = row.getFloat(2);
    dataRow[2] = row.getFloat(3);
    dataRow[3] = row.getFloat(4); 
    dataRow[4] = label[0];
    dataRow[5] = label[1];
    dataRow[6] = label[2];
    result.add(dataRow);
  }
  return result;
}

void setup() {
  size(800, 800); 
  colorMode(HSB, 360, 100, 100, 100);

  model = new GeneticNeuralNetwork()
    .setMutationRate(0.1);

  model.layer1 = new Layer(4, 4)
    .setActivation(new TanhActivation())
    .setInitializer(new GlorotUniformInitializer())
    .setNormalize(true);

  model.layer2 = new Layer(model.layer1.getOutputUnits(), 3)
    .setActivation(new SoftmaxActivation())
    .setInitializer(new GlorotUniformInitializer())
    .setNormalize(false);

  model.compile(
    new SoftmaxCrossEntropy(), 
    new OptimizerMomentum()
    .setLearningRate(0.01)
    .setLearningRateScheduler(new ExponentialScheduler(0.00001, 10000, 0.001)));

  ArrayList<Float[]> fisherSet = null;
  try {
    fisherSet = loadDataSet("fisher's data.csv");
  }
  catch(Exception x) {
    x.printStackTrace();
  }

  // Prepare the data
  normalize(fisherSet, 0);
  normalize(fisherSet, 1);
  normalize(fisherSet, 2);
  normalize(fisherSet, 3);
  fisherSet = shuffle(fisherSet);

  // Partition the data: 80% training, 20% test
  int p = floor(fisherSet.size() * 0.8);
  ArrayList<Float[]> training = subset(fisherSet, 0, p);
  ArrayList<Float[]> test = subset(fisherSet, p, fisherSet.size());

  // Training to Matrix
  trainingInputs = new Matrix[training.size()];
  trainingTargets = new Matrix[training.size()];
  for (int i = 0; i < training.size(); i++) {
    Float[] data = training.get(i);
    trainingInputs[i] = new Matrix(4, 1);
    trainingInputs[i].data[0][0] = data[0];
    trainingInputs[i].data[1][0] = data[1];
    trainingInputs[i].data[2][0] = data[2];
    trainingInputs[i].data[3][0] = data[3];
    trainingTargets[i] = new Matrix(3, 1);
    trainingTargets[i].data[0][0] = data[4];
    trainingTargets[i].data[1][0] = data[5];
    trainingTargets[i].data[2][0] = data[6];
  }

  // Test to Matrix
  testInputs = new Matrix[test.size()];
  testTargets = new Matrix[test.size()];
  for (int i = 0; i < test.size(); i++) {
    Float[] data = test.get(i); 
    testInputs[i] = new Matrix(4, 1);
    testInputs[i].data[0][0] = data[0];
    testInputs[i].data[1][0] = data[1];
    testInputs[i].data[2][0] = data[2];
    testInputs[i].data[3][0] = data[3];
    testTargets[i] = new Matrix(3, 1);
    testTargets[i].data[0][0] = data[4];
    testTargets[i].data[1][0] = data[5];
    testTargets[i].data[2][0] = data[6];
  }
}

void draw() {
  background(51);

  float error = 0.0;
  for (int i = 0; i < iterationCount; i++) {
    error += model.fit(trainingInputs, trainingTargets, 64, true).flatten(0);
  }
  error /= iterationCount;
  
  timeLine1.append(error);
  if (timeLine1.size() > width / timeStepX + 1) {
    timeLine1.remove(0);
  }

  strokeWeight(4);
  for (int i = 0; i < trainingInputs.length; i++) {
    float x = map(trainingInputs[i].data[0][0], 0, 1.0, 0, width);
    float y = map(trainingInputs[i].data[2][0], 0, 1.0, height, 0);
    float c = map(trainingTargets[i].argmax(0), 0, 3, 0, 360);
    stroke(c, 100, 100);
    point(x, y);
  }

  int success = 0;
  for (int i = 0; i < testInputs.length; i++) {
    Matrix r = model.predict(testInputs[i]);
    int i1 = r.argmax(0);
    int i2 = testTargets[i].argmax(0);
    if (i1 == i2) {
      success++;
    }

    float x = map(testInputs[i].data[0][0], 0, 1.0, 0, width);
    float y = map(testInputs[i].data[2][0], 0, 1.0, height, 0);
    float c = map(i2, 0, 3, 0, 360);
    strokeWeight(8);
    stroke(c, 100, 100);
    point(x, y);
    if (i1 != i2) {
      c = map(i1, 0, 3, 0, 360);
      strokeWeight(16);
      stroke(c, 100, 100, 50);
      point(x, y);
    }
  }
  float accuracy = (float) success / (float) testInputs.length;

  timeLine2.append(accuracy);
  if (timeLine2.size() > width / timeStepX + 1) {
    timeLine2.remove(0);
  }

  noFill();
  strokeWeight(2);
  stroke(300, 100, 100);
  beginShape();
  for (int i = 0; i < timeLine1.size(); i++) {
    float x = map(i, 0, width / timeStepX, 0, width);
    float y = map(timeLine1.get(i), 0, 1.0, height, 0);
    vertex(x, y);
  }
  endShape();
  
  
  
  stroke(60, 100, 100);
  beginShape();
  for (int i = 0; i < timeLine2.size(); i++) {
    float x = map(i, 0, width / timeStepX, 0, width);
    float y = map(timeLine2.get(i), 0, 1.0, height, 0);
    vertex(x, y);
  }
  endShape();
}

void keyPressed() {
  if (key == ' ') {
    println("transfer model");
    model.optimizer.reset();
    model.mutate();
  } else if (key == 'n') {
    println("new model");
    model.reset();
  }
}
