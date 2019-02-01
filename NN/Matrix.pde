import java.util.function.Function;

class Matrix {
  int rows;
  int cols;
  float[][] data;
  
  public Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.data = new float[this.rows][this.cols];
    this.reset();
  }
  
  public Matrix(float[] v) {
    this.rows = v.length;
    this.cols = 1;
    this.data = new float[this.rows][this.cols];
    for(int i = 0; i < this.rows; i++) {
      this.data[i][0] = v[i];
    }
  }
  
  public void reset() {
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] = 0.0;
      }
    }
  }
  
  public void randomize() {
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] = random(-1.0, 1.0);
      }
    }
  }
  
  public void randomize(int n) {
    float a = 1.0 / sqrt(n);
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] = random(-a, a);
      }
    }
  }
  
  public Matrix add(Matrix m) {
    if(this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] += m.data[i][j];
      }
    }
    return this;
  }
  
  public Matrix sub(Matrix m) {
    if(this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] -= m.data[i][j];
      }
    }
    return this;
  }
  
  public Matrix mult(float n) {
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] *= n;
      }
    }
    return this;
  }
  
  public Matrix mult(Matrix m) {
    if(this.rows != m.rows || this.cols != m.cols) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] *= m.data[i][j];
      }
    }
    return this;
  }
  
  public Matrix map(Function<Float,Float> fn) {
    if(fn == null) {
      throw new IllegalArgumentException("function is not defined");
    }
    for(int i = 0; i < this.rows; i++) {
      for(int j = 0; j < this.cols; j++) {
        this.data[i][j] = fn.apply(this.data[i][j]);
      }
    }
    return this; 
  }  
  
  public Matrix copy() {
    Matrix result = new Matrix(this.rows, this.cols);
    for(int i = 0; i < result.rows; i++) {
      for(int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[i][j];
      }
    }
    return result;
  }
  
  public Matrix transpose() {
    Matrix result = new Matrix(this.cols, this.rows);
    for(int i = 0; i < result.rows; i++) {
      for(int j = 0; j < result.cols; j++) {
        result.data[i][j] = this.data[j][i];
      }
    }
    return result;
  }
  
  public Matrix transform(Matrix m) {
    if(this.cols != m.rows) {
      throw new IllegalArgumentException("cols of A must match rows of B.");
    }
    Matrix result = new Matrix(this.rows, m.cols);
    for(int i = 0; i < result.rows; i++) {
      for(int j = 0; j < result.cols; j++) {
        float sum = 0.0;
        for(int k = 0; k < this.cols; k++) {
          sum += this.data[i][k] * m.data[k][j];
        }
        result.data[i][j] = sum;
      }
    }
    return result;
  }
  
  public void print() {
    for(int i  = 0; i < this.rows; i++) {
      println(this.data[i]);
    }
  }
}
