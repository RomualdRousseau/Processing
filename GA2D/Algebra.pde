import java.net.*;
import javax.tools.*;
import java.nio.file.*;
import java.nio.charset.*;
import java.util.function.*;

public interface Algebra
{
  float[] rev(float[] a);

  float[] conj(float[] a);

  float[] dual(float[] a);

  float[] add(float[] a, float b);

  float[] add(float a, float[] b);

  float[] add(float[] a, float[] b);

  float[] sub(float[] a, float b);

  float[] sub(float a, float[] b);

  float[] sub(float[] a, float[] b);

  float[] mul(float a, float[] b);

  float[] mul(float[] a, float b);

  float[] mul(float[] a, float[] b);

  float[] div(float a, float[] b);

  float[] div(float[] a, float b);

  float[] div(float[] a, float[] b);

  float[] dot(float[] a, float[] b);

  float[] join(float[] a, float[] b);

  float[] meet(float[] a, float[] b);

  String toString(float[] a);
}

Consumer<Float> Algebra(String className, String[] basis, int[] grades, String[][] cayley, Function<Algebra, Consumer<Float>> inline) {
  className += "_AlgebraClass"; // Avoid name collision
  return inline.apply(compileAlgebra(className, generateAlgebra(className, basis, grades, cayley)));
}

String generateAlgebra(String className, String[] basis, int[] grades, String[][] cayley) {
  StringBuffer source = new StringBuffer("public class " + className + " implements GA2D.Algebra {\n");
  compile_rev(source, grades);
  compile_conj(source, grades);
  compile_dual(source, grades);
  compile_ops(source, basis, '+', "add", true, true);
  compile_ops(source, basis, '-', "sub", true, true);
  compile_ops(source, basis, '*', "mul", true, false);
  compile_mul(source, basis, cayley);
  compile_ops(source, basis, '/', "div", true, false);
  compile_div(source, basis, cayley);
  compile_dot(source, basis, cayley);
  compile_join(source, basis, cayley);
  compile_meet(source, basis, cayley);
  compile_toString(source, basis);
  source.append("}");
  return source.toString();
}

Algebra compileAlgebra(String className, String source) {
  try {
   
    Path javaFile = Paths.get(dataPath(className + ".java"));
    Files.write(javaFile, source.getBytes(StandardCharsets.UTF_8));

    JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
    compiler.run(null, null, null, javaFile.toFile().getAbsolutePath());
    Path javaClass = javaFile.getParent().resolve(className + ".class");

    URL classUrl = javaClass.getParent().toFile().toURI().toURL();
    URLClassLoader classLoader = URLClassLoader.newInstance(new URL[]{classUrl});
    Class<?> clazz = Class.forName(className, true, classLoader);
    return (Algebra) clazz.getDeclaredConstructor().newInstance();
  }
  catch(Exception x) {
    throw new RuntimeException(x);
  }
}

void compile_ops(StringBuffer source, String[] basis, char op, String name, boolean commutatif, boolean scalarOnly) {

  source.append("\n");
  source.append("\t").append("public float[] " + name + "(float[] a, float b) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
  for (int i = 0; i < basis.length; i++) {
    source.append("\t\t").append("r[" + i + "] = a[" + i + "] " + op + " b").append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");

  if (commutatif) {
    source.append("\n");
    source.append("\t").append("public float[] " + name + "(float a, float[] b) {").append("\n");
    source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
    for (int i = 0; i < basis.length; i++) {
      source.append("\t\t").append("r[" + i + "] = a " + op + " b[" + i + "]").append(";\n");
    }
    source.append("\t\t").append("return r").append(";\n");
    source.append("\t").append("}").append("\n");
  }

  if (scalarOnly) {
    source.append("\n");
    source.append("\t").append("public float[] " + name + "(float[] a, float[] b) {").append("\n");
    source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
    for (int i = 0; i < basis.length; i++) {
      source.append("\t\tr").append("[" + i + "] = a[" + i + "] " + op + " b[" + i + "]").append(";\n");
    }
    source.append("\t\t").append("return r").append(";\n");
    source.append("\t").append("}").append("\n");
  }
}

void compile_rev(StringBuffer source, int[] grades) {
  String[] code = new String[grades.length];

  for (int i = 0; i < grades.length; i++) {

    int n = grades[i] * (grades[i] - 1) / 2;

    if (code[i] == null) {
      code[i] = "r[" + i + "] = ";
    }
    if (n  % 2 == 0) {
      code[i] += "a[" + i + "]";
    } else {
      code[i] += "-a[" + i + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] rev(float[] a) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + grades.length + "]").append(";\n");
  for (String line: code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_conj(StringBuffer source, int[] grades) {
  String[] code = new String[grades.length];

  for (int i = 0; i < grades.length; i++) {

    int n = grades[i] * (grades[i] - 1) / 2;

    if (code[i] == null) {
      code[i] = "r[" + i + "] = ";
    }
    if (grades[i] % 2 == n % 2) {
      code[i] += "a[" + i + "]";
    } else {
      code[i] += "-a[" + i + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] conj(float[] a) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + grades.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_dual(StringBuffer source, int[] grades) {
  String[] code = new String[grades.length];

  for (int i = 0; i < grades.length; i++) {
    if (code[i] == null) {
      code[i] = "r[" + i + "] = ";
    }
    code[i] += "a[" + (grades.length - i - 1) + "]";
  }

  source.append("\n");
  source.append("\t").append("public float[] dual(float[] a) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + grades.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_mul(StringBuffer source, String[] basis, String[][] cayley) {
  String[] code = new String[basis.length];

  for (int i = 0; i < cayley.length; i++) {
    for (int j = 0; j < cayley[i].length; j++) {

      String symbol = cayley[i][j];
      if (symbol.equals("0")) {
        continue;
      }

      float c = 1;
      if (symbol.startsWith("-")) {
        symbol = symbol.substring(1);
        c *= -1;
      }

      int k = java.util.Arrays.asList(basis).indexOf(symbol);

      if (code[k] == null) {
        code[k] = "r[" + k + "] = ";
        if (c < 1) {
          code[k] += "-";
        }
      } else {
        if (c < 1) {
          code[k] += " - ";
        } else {
          code[k] += " + ";
        }
      }
      code[k] += "a[" + i + "] * b[" + j + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] mul(float[] a, float[] b) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_div(StringBuffer source, String[] basis, String[][] cayley) {
  source.append("\n");
  source.append("\tpublic float[] div(float[] a, float[] b) {").append("\n");
  source.append("\t\tthrow new RuntimeException(\"Not implemented\");").append("\n");
  source.append("\t}").append("\n");
}

void compile_join(StringBuffer source, String[] basis, String[][] cayley) {
  String[] code = new String[basis.length];

  for (int i = 0; i < cayley.length; i++) {
    for (int j = 0; j < cayley[i].length; j++) {

      if (!basis[i].equals("1") && !basis[j].equals("1") && is_axis_colineaire(basis[i], basis[j])) {
        continue;
      }

      String symbol = cayley[i][j];
      if (symbol.equals("0")) {
        continue;
      }

      float c = 1;
      if (symbol.startsWith("-")) {
        symbol = symbol.substring(1);
        c *= -1;
      }

      int k = java.util.Arrays.asList(basis).indexOf(symbol);

      if (code[k] == null) {
        code[k] = "r[" + k + "] = ";
        if (c < 1) {
          code[k] += "-";
        }
      } else {
        if (c < 1) {
          code[k] += " - ";
        } else {
          code[k] += " + ";
        }
      }
      code[k] += "a[" + i + "] * b[" + j + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] join(float[] a, float[] b) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_dot(StringBuffer source, String[] basis, String[][] cayley) {
  String[] code = new String[basis.length];

  for (int i = 0; i < cayley.length; i++) {
    for (int j = 0; j < cayley[i].length; j++) {

      if (!basis[i].equals("1") && !basis[j].equals("1") && is_axis_orthogonal(basis[i], basis[j])) {
        continue;
      }

      String symbol = cayley[i][j];
      if (symbol.equals("0")) {
        continue;
      }

      float c = 1;
      if (symbol.startsWith("-")) {
        symbol = symbol.substring(1);
        c *= -1;
      }

      int k = java.util.Arrays.asList(basis).indexOf(symbol);

      if (code[k] == null) {
        code[k] = "r[" + k + "] = ";
        if (c < 1) {
          code[k] += "-";
        }
      } else {
        if (c < 1) {
          code[k] += " - ";
        } else {
          code[k] += " + ";
        }
      }
      code[k] += "a[" + i + "] * b[" + j + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] dot(float[] a, float[] b) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_meet(StringBuffer source, String[] basis, String[][] cayley) {
  String[] code = new String[basis.length];

  for (int i = 0; i < cayley.length; i++) {
    for (int j = 0; j < cayley[i].length; j++) {

      if (!basis[i].equals("1") && !basis[j].equals("1") && is_axis_colineaire(basis[i], basis[j])) {
        continue;
      }

      String symbol = cayley[i][j];
      if (symbol.equals("0")) {
        continue;
      }

      float c = 1;
      if (symbol.startsWith("-")) {
        symbol = symbol.substring(1);
        c *= -1;
      }

      int k = java.util.Arrays.asList(basis).indexOf(symbol);

      if (code[k] == null) {
        code[k] = "r[" + (basis.length - k - 1) + "] = ";
        if (c < 1) {
          code[k] += "-";
        }
      } else {
        if (c < 1) {
          code[k] += " - ";
        } else {
          code[k] += " + ";
        }
      }
      code[k] += "a[" + (basis.length - i - 1) + "] * b[" + (basis.length - j - 1) + "]";
    }
  }

  source.append("\n");
  source.append("\t").append("public float[] meet(float[] a, float[] b) {").append("\n");
  source.append("\t\t").append("float[] r = new float[" + basis.length + "]").append(";\n");
  for (String line : code) {
    source.append("\t\t").append(line).append(";\n");
  }
  source.append("\t\t").append("return r").append(";\n");
  source.append("\t").append("}").append("\n");
}

void compile_toString(StringBuffer source, String[] basis) {

  source.append("\n");
  source.append("\t").append("private final static String[] BASIS = { ");
  boolean firstPass = true;
  for (String token : basis) {
    if (firstPass) {
      source.append("\"" + token + "\"");
      firstPass = false;
    } else {
      source.append(", \"" + token + "\"");
    }
  }
  source.append(" }").append(";\n");

  source.append("\t").append("public String toString(float[] a) {").append("\n");
  source.append("\t\t").append("StringBuffer output = new StringBuffer()").append(";\n");
  source.append("\t\t").append("boolean firstPass = true").append(";\n");
  source.append("\t\t").append("for (int i = 0; i < a.length; i++) {").append("\n");
  source.append("\t\t\t").append("if (a[i] != 0) {").append("\n");
  source.append("\t\t\t\t").append("if (firstPass) {").append("\n");
  source.append("\t\t\t\t\t").append("output.append(a[i] + BASIS[i])").append(";\n");
  source.append("\t\t\t\t\t").append("firstPass = false").append(";\n");
  source.append("\t\t\t\t").append("} else {").append("\n");
  source.append("\t\t\t\t\t").append("output.append(\" \" + a[i] + BASIS[i])").append(";\n");
  source.append("\t\t\t\t").append("}").append("\n");
  source.append("\t\t\t").append("}").append("\n");
  source.append("\t\t").append("}").append("\n");
  source.append("\t\t").append("return output.toString()").append(";\n");
  source.append("\t").append("}").append("\n");
}

boolean is_axis_colineaire(String s1, String s2) {

  if (s1.startsWith("e")) {
    s1 = s1.substring(1);
  } else {
    throw new RuntimeException("Syntax error in cayley expression:" + s1);
  }
  if (s2.startsWith("e")) {
    s2 = s2.substring(1);
  } else {
    throw new RuntimeException("Syntax error in cayley expression:" + s2);
  }

  if (s1.equals(s2)) {
    return true;
  }

  boolean found = false;
  if (s1.length() < s2.length()) {
    for (int i = 0; i < s1.length(); i++) {
      found |= s2.indexOf(s1.charAt(i)) >= 0;
    }
  } else {
    for (int i = 0; i < s2.length(); i++) {
      found |= s1.indexOf(s2.charAt(i)) >= 0;
    }
  }
  return found;
}
boolean is_axis_orthogonal(String s1, String s2) {

  if (s1.startsWith("e")) {
    s1 = s1.substring(1);
  } else {
    throw new RuntimeException("Syntax error in cayley expression:" + s1);
  }
  if (s2.startsWith("e")) {
    s2 = s2.substring(1);
  } else {
    throw new RuntimeException("Syntax error in cayley expression:" + s2);
  }

  if (s1.equals(s2)) {
    return false;
  }

  boolean found = true;
  if (s1.length() < s2.length()) {
    for (int i = 0; i < s1.length(); i++) {
      found &= s2.indexOf(s1.charAt(i)) >= 0;
    }
  } else {
    for (int i = 0; i < s2.length(); i++) {
      found &= s1.indexOf(s2.charAt(i)) >= 0;
    }
  }
  return !found;
}
