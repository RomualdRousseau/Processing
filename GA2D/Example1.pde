Consumer<Float> example1(Algebra A) {

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

  return (dt) -> {

    float[] P1 = A.dual(A.add(A.add(A.mul(E1, myMouseX), A.mul(E2, myMouseY)), E0));
    point(P1, "P1", true);
    float[] P2 = A.dual(A.add(A.add(A.mul(E1, 2), A.mul(E2, 2)), E0));
    point(P2, "P2", false);
    float[] l1 = A.meet(P2, P1);
    line(l1, "l1");

    float[] P3 = A.dual(A.add(A.add(A.mul(E1, 0.5), A.mul(E2, 2.5)), E0));
    point(P3, "P3", false);
    float[] P4 = A.dual(A.add(A.add(A.mul(E1, 2), A.mul(E2, -2)), E0));
    point(P4, "P4", false);
    float[] l2 = A.meet(P4, P3);
    line(l2, "l2");

    float[] P7 = A.join(l2, l1);
    point(P7, "P7", false);

    float[] P8 = A.mul(A.dot(P1, l2), l2);
    point(P8, "P8", false);

    float[] P9 = A.mul(A.mul(l1, P4), l1);
    point(P9, "P9", false);

    float[] R1 = A.add(A.mul(S, cos(PI / 4)), A.mul(P1, sin(PI / 4)));
    float[] l3 = A.mul(A.mul(R1, l2), A.rev(R1));
    line(l3, "l3");

    float[] T1 = A.add(S, A.mul(E20, 1.5));
    float[] l4 = A.mul(A.mul(T1, l3), A.rev(T1));
    line(l4, "l4");
  };
}
