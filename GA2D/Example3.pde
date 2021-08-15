AlgebraGraphFunction example3 = C -> (g, dt) -> g.pixels((x, y) -> {
    int n = 35;
    float[] z = C.set(0, 0);
    float[] c = C.set(x * 1.75 - 1, y * 2);
    while (sqrt(z[0] * z[0] + z[1] * z[1]) < 2.0 && n-- > 0) z = C.add(C.mul(z, z), c);
    return constrain(map(n, 0, 25, 255, 79), 79, 255);
});
