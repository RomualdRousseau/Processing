public class PGA2DClass implements GA2D.Algebra {

	public float[] rev(float[] a) {
		float[] r = new float[8];
		r[0] = a[0];
		r[1] = a[1];
		r[2] = a[2];
		r[3] = a[3];
		r[4] = -a[4];
		r[5] = -a[5];
		r[6] = -a[6];
		r[7] = -a[7];
		return r;
	}

	public float[] conj(float[] a) {
		float[] r = new float[8];
		r[0] = a[0];
		r[1] = -a[1];
		r[2] = -a[2];
		r[3] = -a[3];
		r[4] = -a[4];
		r[5] = -a[5];
		r[6] = -a[6];
		r[7] = a[7];
		return r;
	}

	public float[] dual(float[] a) {
		float[] r = new float[8];
		r[0] = a[7];
		r[1] = a[6];
		r[2] = a[5];
		r[3] = a[4];
		r[4] = a[3];
		r[5] = a[2];
		r[6] = a[1];
		r[7] = a[0];
		return r;
	}

	public float[] add(float[] a, float b) {
		float[] r = new float[8];
		r[0] = a[0] + b;
		r[1] = a[1] + b;
		r[2] = a[2] + b;
		r[3] = a[3] + b;
		r[4] = a[4] + b;
		r[5] = a[5] + b;
		r[6] = a[6] + b;
		r[7] = a[7] + b;
		return r;
	}

	public float[] add(float a, float[] b) {
		float[] r = new float[8];
		r[0] = a + b[0];
		r[1] = a + b[1];
		r[2] = a + b[2];
		r[3] = a + b[3];
		r[4] = a + b[4];
		r[5] = a + b[5];
		r[6] = a + b[6];
		r[7] = a + b[7];
		return r;
	}

	public float[] add(float[] a, float[] b) {
		float[] r = new float[8];
		r[0] = a[0] + b[0];
		r[1] = a[1] + b[1];
		r[2] = a[2] + b[2];
		r[3] = a[3] + b[3];
		r[4] = a[4] + b[4];
		r[5] = a[5] + b[5];
		r[6] = a[6] + b[6];
		r[7] = a[7] + b[7];
		return r;
	}

	public float[] sub(float[] a, float b) {
		float[] r = new float[8];
		r[0] = a[0] - b;
		r[1] = a[1] - b;
		r[2] = a[2] - b;
		r[3] = a[3] - b;
		r[4] = a[4] - b;
		r[5] = a[5] - b;
		r[6] = a[6] - b;
		r[7] = a[7] - b;
		return r;
	}

	public float[] sub(float a, float[] b) {
		float[] r = new float[8];
		r[0] = a - b[0];
		r[1] = a - b[1];
		r[2] = a - b[2];
		r[3] = a - b[3];
		r[4] = a - b[4];
		r[5] = a - b[5];
		r[6] = a - b[6];
		r[7] = a - b[7];
		return r;
	}

	public float[] sub(float[] a, float[] b) {
		float[] r = new float[8];
		r[0] = a[0] - b[0];
		r[1] = a[1] - b[1];
		r[2] = a[2] - b[2];
		r[3] = a[3] - b[3];
		r[4] = a[4] - b[4];
		r[5] = a[5] - b[5];
		r[6] = a[6] - b[6];
		r[7] = a[7] - b[7];
		return r;
	}

	public float[] mul(float[] a, float b) {
		float[] r = new float[8];
		r[0] = a[0] * b;
		r[1] = a[1] * b;
		r[2] = a[2] * b;
		r[3] = a[3] * b;
		r[4] = a[4] * b;
		r[5] = a[5] * b;
		r[6] = a[6] * b;
		r[7] = a[7] * b;
		return r;
	}

	public float[] mul(float a, float[] b) {
		float[] r = new float[8];
		r[0] = a * b[0];
		r[1] = a * b[1];
		r[2] = a * b[2];
		r[3] = a * b[3];
		r[4] = a * b[4];
		r[5] = a * b[5];
		r[6] = a * b[6];
		r[7] = a * b[7];
		return r;
	}

	public float[] mul(float[] a, float[] b) {
		float[] r = new float[8];
		r[0] = a[0] * b[0] + a[2] * b[2] + a[3] * b[3] - a[6] * b[6];
		r[1] = a[0] * b[1] + a[1] * b[0] - a[2] * b[4] - a[3] * b[5] + a[4] * b[2] + a[5] * b[3] - a[6] * b[7] - a[7] * b[6];
		r[2] = a[0] * b[2] + a[2] * b[0] - a[3] * b[6] + a[6] * b[3];
		r[3] = a[0] * b[3] + a[2] * b[6] + a[3] * b[0] - a[6] * b[2];
		r[4] = a[0] * b[4] + a[1] * b[2] - a[2] * b[1] + a[3] * b[7] + a[4] * b[0] - a[5] * b[6] + a[6] * b[5] + a[7] * b[3];
		r[5] = a[0] * b[5] + a[1] * b[3] - a[2] * b[7] - a[3] * b[1] + a[4] * b[6] + a[5] * b[0] - a[6] * b[4] - a[7] * b[2];
		r[6] = a[0] * b[6] + a[2] * b[3] - a[3] * b[2] + a[6] * b[0];
		r[7] = a[0] * b[7] + a[1] * b[6] - a[2] * b[5] + a[3] * b[4] + a[4] * b[3] - a[5] * b[2] + a[6] * b[1] + a[7] * b[0];
		return r;
	}

	public float[] div(float[] a, float b) {
		float[] r = new float[8];
		r[0] = a[0] / b;
		r[1] = a[1] / b;
		r[2] = a[2] / b;
		r[3] = a[3] / b;
		r[4] = a[4] / b;
		r[5] = a[5] / b;
		r[6] = a[6] / b;
		r[7] = a[7] / b;
		return r;
	}

	public float[] div(float a, float[] b) {
		float[] r = new float[8];
		r[0] = a / b[0];
		r[1] = a / b[1];
		r[2] = a / b[2];
		r[3] = a / b[3];
		r[4] = a / b[4];
		r[5] = a / b[5];
		r[6] = a / b[6];
		r[7] = a / b[7];
		return r;
	}

	public float[] div(float[] a, float[] b) {
		throw new RuntimeException("Not implemented");
	}

	public float[] dot(float[] a, float[] b) {
		float[] r = new float[8];
		r[0] = a[0] * b[0] + a[2] * b[2] + a[3] * b[3] - a[6] * b[6];
		r[1] = a[0] * b[1] + a[1] * b[0] - a[2] * b[4] - a[3] * b[5] + a[4] * b[2] + a[5] * b[3] - a[6] * b[7] - a[7] * b[6];
		r[2] = a[0] * b[2] + a[2] * b[0] - a[3] * b[6] + a[6] * b[3];
		r[3] = a[0] * b[3] + a[2] * b[6] + a[3] * b[0] - a[6] * b[2];
		r[4] = a[0] * b[4] + a[3] * b[7] + a[4] * b[0] + a[7] * b[3];
		r[5] = a[0] * b[5] - a[2] * b[7] + a[5] * b[0] - a[7] * b[2];
		r[6] = a[0] * b[6] + a[6] * b[0];
		r[7] = a[0] * b[7] + a[7] * b[0];
		return r;
	}

	public float[] join(float[] a, float[] b) {
		float[] r = new float[8];
		r[0] = a[0] * b[0];
		r[1] = a[0] * b[1] + a[1] * b[0];
		r[2] = a[0] * b[2] + a[2] * b[0];
		r[3] = a[0] * b[3] + a[3] * b[0];
		r[4] = a[0] * b[4] + a[1] * b[2] - a[2] * b[1] + a[4] * b[0];
		r[5] = a[0] * b[5] + a[1] * b[3] - a[3] * b[1] + a[5] * b[0];
		r[6] = a[0] * b[6] + a[2] * b[3] - a[3] * b[2] + a[6] * b[0];
		r[7] = a[0] * b[7] + a[1] * b[6] - a[2] * b[5] + a[3] * b[4] + a[4] * b[3] - a[5] * b[2] + a[6] * b[1] + a[7] * b[0];
		return r;
	}

	public float[] meet(float[] a, float[] b) {
		float[] r = new float[8];
		r[7] = a[7] * b[7];
		r[6] = a[7] * b[6] + a[6] * b[7];
		r[5] = a[7] * b[5] + a[5] * b[7];
		r[4] = a[7] * b[4] + a[4] * b[7];
		r[3] = a[7] * b[3] + a[6] * b[5] - a[5] * b[6] + a[3] * b[7];
		r[2] = a[7] * b[2] + a[6] * b[4] - a[4] * b[6] + a[2] * b[7];
		r[1] = a[7] * b[1] + a[5] * b[4] - a[4] * b[5] + a[1] * b[7];
		r[0] = a[7] * b[0] + a[6] * b[1] - a[5] * b[2] + a[4] * b[3] + a[3] * b[4] - a[2] * b[5] + a[1] * b[6] + a[0] * b[7];
		return r;
	}

	public float norm(float[] a) {
		return (float) Math.sqrt(mul(a, conj(a))[0]);
	}

	private final static String[] BASIS = { "1", "e1", "e2", "e3", "e12", "e13", "e23", "e123" };
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