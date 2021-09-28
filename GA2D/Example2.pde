import java.util.function.*;

float a = 0;

AlgebraGraphFunction example2 = A -> {

  final float[] S  = { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  final float[] E0 = { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  final float[] E1 = { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  final float[] E2 = { 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  final float[] E01 = A.join(E0, E1);
  final float[] E02 = A.join(E0, E2);
  final float[] E12 = A.join(E1, E2);
  final float[] E012 = A.join(A.join(E0, E1), E2);
  
  final BiFunction<Float, Float, float[]> POINT = (x, y) -> A.dual(A.add(A.add(A.mul(E1, x), A.mul(E2, y)), E0));
  
  final BiFunction<float[], float[], float[]> LINE = (p1, p2) -> A.meet(p2, p1);
  
  final BiFunction<float[], Float, float[]> ROTOR = (p, a) -> A.add(A.mul(S, cos(a / 2)), A.mul(p, sin(a / 2)));
  
  final BiFunction<float[], Float, float[]> TRANSLATION = (p, l) -> A.add(S, A.mul(E02, l / 2));
  
  final BiFunction<float[], Float, BiFunction<float[], Float, float[]>> MOTOR = (p, l) -> ROTOR.andThen(x -> A.mul(x, TRANSLATION.apply(p, l)));

  final BiFunction<float[], float[], float[]> TRANSFORM = (p, m) -> A.mul(A.mul(m, p), A.rev(m));
  
  return (g, dt) -> {
    
    float[] P1 = POINT.apply(g.mouseX, g.mouseY);
    g.point(P1, "P1", true);
    float[] P2 = POINT.apply(2.0, 2.0);
    g.point(P2, "P2", false);

    float[] M1 = MOTOR.apply(P1, 2.0).apply(P1, a);
    float[] P3 = TRANSFORM.apply(P1, M1);
    g.point(P3, "P3", false);

    float[] M2 = MOTOR.apply(P3, 1.0).apply(P3, a * 2);
    float[] P4 = TRANSFORM.apply(P3, M2);
    g.point(P4, "P4", false);
    
    float[] M3 = MOTOR.apply(P4, 0.5).apply(P4, a * 4);
    float[] P5 = TRANSFORM.apply(P4, M3);
    g.point(P5, "P5", false);
    
    float[] l1 = LINE.apply(P2, P1);
    g.line(l1, "l1");
    g.segment(P3, P1, "");
    g.segment(P4, P3, "");
    g.segment(P5, P4, "");

    a += dt;
  };
};
