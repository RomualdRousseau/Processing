AlgebraGraphFunction example1 = A -> {

  final float[] S = { 1, 0, 0, 0, 0, 0, 0, 0 };
  final float[] E0 = { 0, 1, 0, 0, 0, 0, 0, 0 };
  final float[] E1 = { 0, 0, 1, 0, 0, 0, 0, 0 };
  final float[] E2 = { 0, 0, 0, 1, 0, 0, 0, 0 };
  final float[] E01 = A.join(E0, E1);
  final float[] E02 = A.join(E0, E2);
  final float[] E12 = A.join(E1, E2);
  final float[] E012 = A.join(A.join(E0, E1), E2);

  return (g, dt) -> {

    float[] P1 = A.dual(A.add(A.add(A.mul(E1, g.mouseX), A.mul(E2, g.mouseY)), E0));
    g.point(P1, "P1", true);
    float[] P2 = A.dual(A.add(A.add(A.mul(E1, 2), A.mul(E2, 2)), E0));
    g.point(P2, "P2", false);
    float[] l1 = A.meet(P2, P1);
    g.line(l1, "l1");

    float[] P3 = A.dual(A.add(A.add(A.mul(E1, 0.5), A.mul(E2, 2.5)), E0));
    g.point(P3, "P3", false);
    float[] P4 = A.dual(A.add(A.add(A.mul(E1, 2), A.mul(E2, -2)), E0));
    g.point(P4, "P4", false);
    float[] l2 = A.meet(P4, P3);
    g.line(l2, "l2");

    float[] P7 = A.join(l2, l1);
    g.point(P7, "P7", false);

    float[] P8 = A.mul(A.dot(P1, l2), l2);
    g.point(P8, "P8", false);

    float[] P9 = A.mul(A.mul(l1, P4), l1);
    g.point(P9, "P9", false);

    float[] R1 = A.add(A.mul(S, cos(PI / 4)), A.mul(P1, sin(PI / 4)));
    float[] l3 = A.mul(A.mul(R1, l2), A.rev(R1));
    g.line(l3, "l3");

    float[] T1 = A.add(S, A.mul(E02, -1.5));
    float[] l4 = A.mul(A.mul(T1, l3), A.rev(T1));
    g.line(l4, "l4");
  };
};
