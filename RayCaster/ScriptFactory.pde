import org.python.core.Py;
import org.python.core.PyString;
import org.python.core.PyObject;
import org.python.core.PyException;
import org.python.core.PySystemState;
import org.python.util.PythonInterpreter;

public class _ScriptFactory {

  private HashMap<String, PyObject> scriptClasses;

  public void init() {
    this.reload();
  }
  
  public void reload() {
    
    scriptClasses = new HashMap<String, PyObject>();
    
    String scriptPath = sketchPath("scripts");
    println("Looking for scripts in " + scriptPath);

    PySystemState sys = Py.getSystemState();
    sys.path.append(new PyString(scriptPath));

    try {
      PythonInterpreter interpreter = new PythonInterpreter();

      for (File filename : listFiles(scriptPath)) {
        if (!filename.getName().endsWith(".py")) {
          continue;
        }

        String scriptName = filename.getName().substring(0, filename.getName().length() - 3);
        println("Found and load script "  + scriptName);

        interpreter.exec("from " + scriptName + " import " + scriptName);
        this.scriptClasses.put(scriptName, interpreter.get(scriptName));
      }
      
      interpreter.close();
    }
    catch(Exception x) {
      x.printStackTrace();
    }
  }

  public Behavior newInstance(String scriptName) {
    PyObject behaviorObject = this.scriptClasses.get(scriptName).__call__();
    return (Behavior)behaviorObject.__tojava__(Behavior.class);
  }
}
