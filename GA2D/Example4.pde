float[] buffer = new float[1000];
float t = 0;

AlgebraGraphFunction example4 = C -> {
  
  final int N = 100;
  final float[] S = C.set(1, 0);
  final float[] E1 = C.set(0, 1);

  final BiFunction<float[], Float, float[]> ROTOR = (p, a) -> C.add(C.mul(S, cos(a)), C.mul(p, sin(a)));
  final Function<float[], BiFunction<float[], Float, float[]>> DFT = (l) -> ROTOR.andThen(x -> C.mul(l, x));

  final float[][] data = new float[N][];
  for(int i = 0; i < data.length; i++) {
    //data[i] = C.set(sin(map(i, 0, data.length, -PI, PI)), 0);
    data[i] = C.set(random(-1, 1), 0);
  }

  final float[][] X = new float[N][];
  for(int k = 0; k < N; k++) {
    X[k] = C.set(0, 0);
    for(int n = 0; n < N; n++) {
      X[k] = C.add(X[k], DFT.apply(data[n]).apply(C.conj(E1), 2 * PI * k * n / N));
    }
    X[k] = C.div(X[k], N);
  }
  
  return (g, dt) -> {
    
    float[] x = C.set(0, 0);
    for(int n = 0; n < N - 1; n++) {
      x = C.add(x, DFT.apply(X[n]).apply(E1, 2 * PI * t * n / N));
    }
    
    for (int i = buffer.length - 1; i > 0; i--) {
      buffer[i] = buffer[i - 1];
    }
    buffer[0] = x[1];
    
    noFill();
    
    stroke(128);
    
    strokeWeight(1);
    beginShape();
    float[] P = C.set(0, 0);
    vertex(P[0] * g.zoom - 100, -P[1] * g.zoom);
    for(int n = 0; n < N - 1; n++) {
      circle(P[0] * g.zoom - 100, -P[1] * g.zoom, C.norm(X[n]) * 2 * g.zoom);
      P = C.add(P, DFT.apply(X[n]).apply(E1, 2 * PI * t * n / N));
      vertex(P[0] * g.zoom - 100, -P[1] * g.zoom);
    }
    endShape();
    
    stroke(255);
    
    strokeWeight(4);
    point(x[0] * g.zoom - 100, -x[1] * g.zoom);
    
    strokeWeight(1);
    beginShape();
    vertex(x[0] * g.zoom - 100, -x[1] * g.zoom);
    for (int i = 0; i < buffer.length; i++) {
      vertex(i * g.zoom / 50, -buffer[i] * g.zoom);
    }
    endShape();
    
    t += dt * 20;
  };
};
