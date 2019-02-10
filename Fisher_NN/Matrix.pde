static final float EPSILON = 1e-8;

interface MatrixFunction<T, R> {
  R apply(T v, int row, int col, Matrix matrix);
}

class Matrix {
  int rows;
  int cols;
  float[][] data;

  public Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.data = new float[this.rows][this.cols];
  }

  public Matrix(int rows, int cols, float v) {
    this.rows = rows;
    this.cols = cols;
    this.data = new float[this.rows][this.cols];
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = v;
      }
    }
  }

  public Matrix(float[] v) {
    this.rows = v.length;
    this.cols = 1;
    this.data = new float[this.rows][this.cols];
    for (int i = 0; i < this.rows; i++) {
      this.data[i][0] = v[i];
    }
  }

  public Matrix(Float[] v) {
    this.rows = v.length;
    this.cols = 1;
    this.data = new float[this.rows][this.cols];
    for (int i = 0; i < this.rows; i++) {
      this.data[i][0] = v[i];
    }
  }

  public Matrix(JSONObject json) {
    this.rows = json.getInt("rows");
    this.cols = json.getInt("cols");
    this.data = new float[this.rows][this.cols];
    JSONArray jsonData = json.getJSONArray("data");
    for (int i = 0; i < this.rows; i++) {
      JSONArray jsonRow = jsonData.getJSONArray(i);
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = jsonRow.getFloat(j);
      }
    }
  }
  
  public float get(int row, int col) {
    return this.data[row][col];
  }

  public Matrix zero() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = 0.0;
      }
    }
    return this;
  }

  public Matrix ones() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = 1.0;
      }
    }
    return this;
  }

  public Matrix identity() {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = (i == j) ? 1.0 : 0.0;
      }
    }
    return this;
  }

  public Matrix mutate(float rate, float variance) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        if (random(1.0) < rate) {
          this.data[i][j] += randomGaussian() * variance;
        }
      }
    }
    return this;
  }

  public Matrix randomize() {
    this.randomize(1.0);
    return this;
  }

  public Matrix randomize(float n) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = random(-n, n);
      }
    }
    return this;
  }

  public Matrix add(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] += m.data[i][j];
      }
    }
    return this;
  }

  public Matrix sub(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] -= m.data[i][j];
      }
    }
    return this;
  }

  public Matrix mult(float n) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] *= n;
      }
    }
    return this;
  }

  public Matrix mult(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] *= m.data[i][j];
      }
    }
    return this;
  }

  public Matrix div(float n) {
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] /= n;
      }
    }
    return this;
  }

  public Matrix div(Matrix m) {
    if (this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] /= m.data[i][j];
      }
    }
    return this;
  }

  public Matrix map(MatrixFunction<Float, Float> fn) {
    if (fn == null) {
      throw new IllegalArgumentException("function is not defined");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = fn.apply(this.data[i][j], i, j, this);
      }
    }
    return this;
  }

  public Matrix map(MatrixFunction<Float, Float> fn, Matrix other) {
    if (fn == null) {
      throw new IllegalArgumentException("function is not defined");
    }
    for (int i = 0; i < this.rows; i++) {
      for (int j = 0; j < this.cols; j++) {
        this.data[i][j] = fn.apply(this.data[i][j], i, j, other);
      }
    }
    return this;
  }
  
  public Matrix l2Norm() {
    for (int j = 0; j < this.cols; j++) {
      float sum = 0.0;
      for (int i = 0; i < this.rows; i++) {
        sum += this.data[i][j] * this.data[i][j];
      }
      sum = sqrt(sum);
      for (int i = 0; i < this.rows; i++) {
        this.data[i][j] /= sum;
      }
    }
    return this;
  }

  public Matrix copy() {
    Matrix result = new Matrix(this.rows, this.cols);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[i][j];
      }
    }
    return result;
  }

  public Matrix transpose() {
    Matrix result = new Matrix(this.cols, this.rows);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[j][i];
      }
    }
    return result;
  }

  public Matrix transform(Matrix m) {
    if (this.cols != m.rows) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    Matrix result = new Matrix(this.rows, m.cols);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        float sum = 0.0;
        for (int k = 0; k < this.cols; k++) {
          sum += this.data[i][k] * m.data[k][j];
        }
        result.data[i][j] = sum;
      }
    }
    return result;
  }

  public int argmax(int col) {
    int result = 0;
    float maxValue = this.data[0][col];
    for (int i = 1; i < this.rows; i++) {
      if (this.data[i][col] > maxValue) {
        maxValue = this.data[i][col];
        result = i;
      }
    }
    return result;
  }
  
  public float flatten(int col) {
    float sum = 0.0;
    for(int i = 0; i < this.rows; i++) {
      sum += this.data[i][col];
    }
    return sum;
  }

  public JSONObject toJSON() {
    JSONArray jsonData = new JSONArray();
    for (int i = 0; i < this.rows; i++) {
      JSONArray jsonRow = new JSONArray();
      for (int j = 0; j < this.cols; j++) {
        jsonRow.setFloat(j, this.data[i][j]);
      }
      jsonData.setJSONArray(i, jsonRow);
    }
    JSONObject json = new JSONObject();
    json.setInt("rows", this.rows);
    json.setInt("cols", this.cols);
    json.setJSONArray("data", jsonData);
    return json;
  }

  public void print2() {
    for (int i = 0; i < this.rows; i++) {
      print("| ");
      for (int j = 0; j < this.cols; j++) {
        if (j == this.cols - 1) {
          print(String.format("%.5f", this.data[i][j]));
        } else {
          print(String.format("%.5f\t", this.data[i][j]));
        }
      }
      println(" |");
    }
  }
}
