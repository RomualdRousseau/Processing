public class ComplexClass implements GA2D.Algebra {

	public float[] rev(float[] a) {
		float[] r = new float[2];
		r[0] = a[0];
		r[1] = a[1];
		return r;
	}

	public float[] conj(float[] a) {
		float[] r = new float[2];
		r[0] = a[0];
		r[1] = -a[1];
		return r;
	}

	public float[] dual(float[] a) {
		float[] r = new float[2];
		r[0] = a[1];
		r[1] = a[0];
		return r;
	}

	public float[] add(float[] a, float b) {
		float[] r = new float[2];
		r[0] = a[0] + b;
		r[1] = a[1] + b;
		return r;
	}

	public float[] add(float a, float[] b) {
		float[] r = new float[2];
		r[0] = a + b[0];
		r[1] = a + b[1];
		return r;
	}

	public float[] add(float[] a, float[] b) {
		float[] r = new float[2];
		r[0] = a[0] + b[0];
		r[1] = a[1] + b[1];
		return r;
	}

	public float[] sub(float[] a, float b) {
		float[] r = new float[2];
		r[0] = a[0] - b;
		r[1] = a[1] - b;
		return r;
	}

	public float[] sub(float a, float[] b) {
		float[] r = new float[2];
		r[0] = a - b[0];
		r[1] = a - b[1];
		return r;
	}

	public float[] sub(float[] a, float[] b) {
		float[] r = new float[2];
		r[0] = a[0] - b[0];
		r[1] = a[1] - b[1];
		return r;
	}

	public float[] mul(float[] a, float b) {
		float[] r = new float[2];
		r[0] = a[0] * b;
		r[1] = a[1] * b;
		return r;
	}

	public float[] mul(float a, float[] b) {
		float[] r = new float[2];
		r[0] = a * b[0];
		r[1] = a * b[1];
		return r;
	}

	public float[] mul(float[] a, float[] b) {
		float[] r = new float[2];
		r[0] = a[0] * b[0] - a[1] * b[1];
		r[1] = a[0] * b[1] + a[1] * b[0];
		return r;
	}

	public float[] div(float[] a, float b) {
		float[] r = new float[2];
		r[0] = a[0] / b;
		r[1] = a[1] / b;
		return r;
	}

	public float[] div(float a, float[] b) {
		float[] r = new float[2];
		r[0] = a / b[0];
		r[1] = a / b[1];
		return r;
	}

	public float[] div(float[] a, float[] b) {
		throw new RuntimeException("Not implemented");
	}

	public float[] dot(float[] a, float[] b) {
		float[] r = new float[2];
		r[0] = a[0] * b[0] - a[1] * b[1];
		r[1] = a[0] * b[1] + a[1] * b[0];
		return r;
	}

	public float[] join(float[] a, float[] b) {
		float[] r = new float[2];
		r[0] = a[0] * b[0];
		r[1] = a[0] * b[1] + a[1] * b[0];
		return r;
	}

	public float[] meet(float[] a, float[] b) {
		float[] r = new float[2];
		r[1] = a[1] * b[1];
		r[0] = a[1] * b[0] + a[0] * b[1];
		return r;
	}

	private final static String[] BASIS = { "1", "e1" };
	public String toString(float[] a) {
		StringBuffer output = new StringBuffer();
		boolean firstPass = true;
		for (int i = 0; i < a.length; i++) {
			if (a[i] != 0) {
				if (firstPass) {
					output.append(a[i] + BASIS[i]);
					firstPass = false;
				} else {
					output.append(" " + a[i] + BASIS[i]);
				}
			}
		}
		return output.toString();
	}
}