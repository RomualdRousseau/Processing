float a = 0;
float b = 0;

@FunctionalInterface
interface TriFunction<A,B,C,R> {

    R apply(A a, B b, C c);

    default <V> TriFunction<A, B, C, V> andThen(
                                Function<? super R, ? extends V> after) {
        java.util.Objects.requireNonNull(after);
        return (A a, B b, C c) -> after.apply(apply(a, b, c));
    }
}

Consumer<Float> example2(Algebra A) {

  float[] S = { 1, 0, 0, 0, 0, 0, 0, 0 };
  float[] E0 = { 0, 1, 0, 0, 0, 0, 0, 0 };
  float[] E1 = { 0, 0, 1, 0, 0, 0, 0, 0 };
  float[] E2 = { 0, 0, 0, 1, 0, 0, 0, 0 };
  float[] E01;
  float[] E20;
  float[] E12;
  float[] E012;

  E01 = A.join(E0, E1);
  E20 = A.join(E2, E0);
  E12 = A.join(E1, E2);
  E012 = A.join(A.join(E0, E1), E2);
  
  BiFunction<Float, Float, float[]> POINT = (x, y) -> A.dual(A.add(A.add(A.mul(E1, x), A.mul(E2, y)), E0));
  
  BiFunction<float[], float[], float[]> LINE = (p1, p2) -> A.meet(p2, p1);
  
  BiFunction<float[], Float, float[]> ROTOR = (p, a) -> A.add(A.mul(S, cos(a / 2)), A.mul(p, sin(a / 2)));
  
  BiFunction<float[], Float, float[]> TRANSLATION = (p, l) -> A.add(S, A.mul(E20, l / 2));
  
  TriFunction<float[], Float, Float, float[]> MOTOR = (p, a, l) -> A.mul(ROTOR.apply(p, a), TRANSLATION.apply(p, l));

  return (dt) -> {
    
    float[] P1 = POINT.apply(myMouseX, myMouseY);
    point(P1, "P1", true);
    float[] P2 = POINT.apply(2.0, 2.0);
    point(P2, "P2", false);

    float[] M1 = MOTOR.apply(P1, a, 2.0);
    float[] P3 = A.mul(A.mul(M1, P1), A.rev(M1));
    point(P3, "P3", false);

    float[] M2 = MOTOR.apply(P3, b, 1.0);
    float[] P4 = A.mul(A.mul(M2, P3), A.rev(M2));
    point(P4, "P4", false);
    
    float[] M3 = MOTOR.apply(P4, b, 0.5);
    float[] P5 = A.mul(A.mul(M2, P4), A.rev(M2));
    point(P5, "P5", false);
    
    float[] l1 = LINE.apply(P2, P1);
    line(l1, "l1");
    float[] l2 = LINE.apply(P3, P1);
    line(l2, "l2");
    float[] l3 = LINE.apply(P4, P3);
    line(l3, "l3");
    float[] l4 = LINE.apply(P5, P4);
    line(l4, "l4");

    a += dt;
    b += 0.5 * dt;
  };
}
