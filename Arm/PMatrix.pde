class PMatrix {
  public final int M;            // number of rows
  public final int N;            // number of columns
  public final float[][] data;   // M-by-N array

  // create M-by-N matrix of 0's
  public PMatrix(int M, int N) {
    this.M = M;
    this.N = N;
    data = new float[M][N];
  }

  // create matrix based on 2d array
  public PMatrix(float[][] data) {
    M = data.length;
    N = data[0].length;
    this.data = new float[M][N];
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        this.data[i][j] = data[i][j];
  }

  // create matrix based on PVector
  public PMatrix(PVector v) {
    M = 3;
    N = 1;
    this.data = new float[M][N];
    this.data[0][0] = v.x;
    this.data[1][0] = v.y;
    this.data[2][0] = v.z;
  }

  public PMatrix random() {
    PMatrix A = this;
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        A.data[i][j] = (float) Math.random();
    return A;
  }

  public PMatrix identity() {
    PMatrix A = this;
    if (A.M != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        A.data[i][j] = (i == j) ? 1 : 0;
    return A;
  }
  
  public PMatrix rotateX(float a) {
    PMatrix A = this;
    if (A.M != A.N && A.N != 3) throw new RuntimeException("Illegal matrix dimensions.");
    A.data[0][0] = 1; A.data[0][1] = 0;      A.data[0][2] = 0;
    A.data[1][0] = 0; A.data[1][1] = cos(a); A.data[1][2] = -sin(a);
    A.data[2][0] = 0; A.data[2][1] = sin(a); A.data[2][2] = cos(a);
    return A;
  }
  
  public PMatrix rotateY(float a) {
    PMatrix A = this;
    if (A.M != A.N && A.N != 3) throw new RuntimeException("Illegal matrix dimensions.");
    A.data[0][0] = cos(a);  A.data[0][1] = 0; A.data[0][2] = sin(a);
    A.data[1][0] = 0;       A.data[1][1] = 1; A.data[1][2] = 0;
    A.data[2][0] = -sin(a); A.data[2][1] = 0; A.data[2][2] = cos(a);
    return A;
  }

  public PMatrix rotateZ(float a) {
    PMatrix A = this;
    if (A.M != A.N && A.N != 3) throw new RuntimeException("Illegal matrix dimensions.");
    A.data[0][0] = cos(a); A.data[0][1] = -sin(a); A.data[0][2] = 0;
    A.data[1][0] = sin(a); A.data[1][1] = cos(a);  A.data[1][2] = 0;
    A.data[2][0] = 0;      A.data[2][1] = 0;       A.data[2][2] = 1;
    return A;
  }

  // does A = B exactly?
  public boolean equals(PMatrix B) {
    PMatrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        if (A.data[i][j] != B.data[i][j]) return false;
    return true;
  }

  // return C = A + B
  public PMatrix add(PMatrix B) {
    PMatrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    PMatrix C = new PMatrix(M, N);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        C.data[i][j] = A.data[i][j] + B.data[i][j];
    return C;
  }

  // return C = A - B
  public PMatrix sub(PMatrix B) {
    PMatrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    PMatrix C = new PMatrix(M, N);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        C.data[i][j] = A.data[i][j] - B.data[i][j];
    return C;
  }

  // return C = A * B
  public PMatrix mult(PMatrix B) {
    PMatrix A = this;
    if (A.N != B.M) throw new RuntimeException("Illegal matrix dimensions.");
    PMatrix C = new PMatrix(A.M, B.N);
    for (int i = 0; i < C.M; i++)
      for (int j = 0; j < C.N; j++)
        for (int k = 0; k < A.N; k++)
          C.data[i][j] += (A.data[i][k] * B.data[k][j]);
    return C;
  }

  // create and return the transpose of the invoking matrix
  public PMatrix transpose() {
    PMatrix A = new PMatrix(N, M);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        A.data[j][i] = this.data[i][j];
    return A;
  }

  public PMatrix inverse() {
    return solve((new PMatrix(N, N)).identity());
  }

  // return x = A^-1 b, assuming A is square and has full rank
  public PMatrix solve(PMatrix rhs) {
    if (M != N || rhs.M != N)
      throw new RuntimeException("Illegal matrix dimensions.");

    // create copies of the data
    PMatrix A = new PMatrix(this);
    PMatrix b = new PMatrix(rhs);

    // Gaussian elimination with partial pivoting
    for (int i = 0; i < N; i++) {

      // find pivot row and swap
      int max = i;
      for (int j = i + 1; j < N; j++)
        if (Math.abs(A.data[j][i]) > Math.abs(A.data[max][i]))
          max = j;
      A.swap(i, max);
      b.swap(i, max);

      // singular
      if (A.data[i][i] == 0.0) throw new RuntimeException("Matrix is singular.");

      // pivot within b
      for (int j = i + 1; j < N; j++) {
        float m = A.data[j][i] / A.data[i][i];
        for (int k = 0; k < N; k++) {
          b.data[j][k] -= b.data[i][k] * m;
        }
      }

      // pivot within A
      for (int j = i + 1; j < N; j++) {
        float m = A.data[j][i] / A.data[i][i];
        for (int k = i + 1; k < N; k++) {
          A.data[j][k] -= A.data[i][k] * m;
        }
        A.data[j][i] = 0.0;
      }
    }

    // back substitution
    PMatrix x = new PMatrix(N, b.N);
    for (int i = 0; i < b.N; i++) {
      for (int j = N - 1; j >= 0; j--) {
        float t = 0.0;
        for (int k = j + 1; k < N; k++)
          t += A.data[j][k] * x.data[k][i];
        x.data[j][i] = (b.data[j][i] - t) / A.data[j][j];
      }
    }
    return x;
  }

  // print matrix to standard output
  public void show() {
    for (int i = 0; i < M; i++) {
      for (int j = 0; j < N; j++) 
        print(data[i][j], " ");
      println();
    }
  }

  // copy constructor
  private PMatrix(PMatrix A) { 
    this(A.data);
  }

  // swap rows i and j
  private void swap(int i, int j) {
    float[] temp = data[i];
    data[i] = data[j];
    data[j] = temp;
  }
}