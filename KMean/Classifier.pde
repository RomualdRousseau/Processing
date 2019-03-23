static final int K = 3;

final MatrixFunction<Float, Float> MSE =  new MatrixFunction<Float, Float>() {
  Float apply(Float v, int row, int col, Matrix matrix) {
    float a = v - matrix.get(row, 0);
    return a * a;
  }
};

class Classifier {
  Matrix weights;

  Matrix predict(Matrix data) {
    return new Matrix(this.weights.copy().map(MSE, data).flatten()).sqrt().mult(-1).exp();
  }

  void fit(Matrix[] data, Matrix[] labels) {
    expectation(data, labels);
    maximation(data, labels);
  }

  void initializer(Matrix[] data) {
    this.weights = new Matrix(data[0].rows, 0);
    for (int j = 0; j < K; j++) {
      int n = floor(random(data.length));
      this.weights = this.weights.concat(data[n]);
    }
  }

  void expectation(Matrix[] data, Matrix[] labels) {
    for (int i = 0; i < data.length; i++) {
      labels[i] = new Matrix(oneHot(argmin(this.weights.copy().map(MSE, data[i]).flatten()), K));
    }
  }

  void maximation(Matrix[] data, Matrix[] labels) {
    this.weights = new Matrix(this.weights.rows, 0);

    for (int j = 0; j < K; j++) {
      Matrix sum = new Matrix(this.weights.rows, 1, 0);
      float count = 0;
      for (int i = 0; i < data.length; i++) {
        if (labels[i].argmax(0) == j) {
          sum.add(data[i]);
          count++;
        }
      }
 
      this.weights = this.weights.concat(sum.div(count));
    }
  }
}
