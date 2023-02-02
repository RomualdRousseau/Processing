public static float det(float[][] m) {
  float[] minors = {
    m[1][1] * m[2][2] - m[1][2] * m[2][1], m[1][0] * m[2][2] - m[1][2] * m[2][0], m[1][0] * m[2][1] - m[1][1] * m[2][0]
  };

  float[] cofactors = {
    minors[0], -minors[1], minors[2]
  };

  return m[0][0] * cofactors[0] + m[0][1] * cofactors[1] + m[0][2] * cofactors[2];
}

public static float[][] inv(float[][] m) {
  float[][] minors = {
    { m[1][1] * m[2][2] - m[1][2] * m[2][1], m[1][0] * m[2][2] - m[1][2] * m[2][0], m[1][0] * m[2][1] - m[1][1] * m[2][0] },
    { m[0][1] * m[2][2] - m[0][2] * m[2][1], m[0][0] * m[2][2] - m[0][2] * m[2][0], m[0][0] * m[2][1] - m[0][1] * m[2][0] },
    { m[0][1] * m[1][2] - m[0][2] * m[1][1], m[0][0] * m[1][2] - m[0][2] * m[1][0], m[0][0] * m[1][1] - m[0][1] * m[1][0] }
  };

  float[][] cofactors = {
    {  minors[0][0], -minors[0][1], minors[0][2] },
    { -minors[1][0], minors[1][1], -minors[1][2] },
    {  minors[2][0], -minors[2][1], minors[2][2] }
  };

  float[][] adjugates = {
    { cofactors[0][0], cofactors[1][0], cofactors[2][0] },
    { cofactors[0][1], cofactors[1][1], cofactors[2][1] },
    { cofactors[0][2], cofactors[1][2], cofactors[2][2] }
  };

  float invDet = 1.0 / (m[0][0] * cofactors[0][0] + m[0][1] * cofactors[0][1] + m[0][2] * cofactors[0][2]);

  return new float[][] {
    { invDet * adjugates[0][0], invDet * adjugates[0][1], invDet * adjugates[0][2] },
    { invDet * adjugates[1][0], invDet * adjugates[1][1], invDet * adjugates[1][2] },
    { invDet * adjugates[2][0], invDet * adjugates[2][1], invDet * adjugates[2][2] }
  };
}

public static PVector matmul(PVector v, float[][] m) {
  return new PVector(
    m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z,
    m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z,
    m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z
    );
}

public static float[][] matmul(float[][] m1, float[][] m2) {
  return new float[][] {
    { m1[0][0] * m2[0][0] + m1[0][1] * m2[1][0] + m1[0][2] * m2[2][0], m1[0][0] * m2[0][1] + m1[0][1] * m2[1][1] + m1[0][2] * m2[2][1], m1[0][0] * m2[0][2] + m1[0][1] * m2[1][2] + m1[0][2] * m2[2][2] },
    { m1[1][0] * m2[0][0] + m1[1][1] * m2[1][0] + m1[1][2] * m2[2][0], m1[1][0] * m2[0][1] + m1[1][1] * m2[1][1] + m1[1][2] * m2[2][1], m1[1][0] * m2[0][2] + m1[1][1] * m2[1][2] + m1[1][2] * m2[2][2] },
    { m1[2][0] * m2[0][0] + m1[2][1] * m2[1][0] + m1[2][2] * m2[2][0], m1[2][0] * m2[0][1] + m1[2][1] * m2[1][1] + m1[2][2] * m2[2][1], m1[2][0] * m2[0][2] + m1[2][1] * m2[1][2] + m1[2][2] * m2[2][2] }
  };
}
