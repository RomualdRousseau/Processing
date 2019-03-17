String getClassName(String s) {
  String[] m = match(s, "\\$([a-zA-Z0-9]*)");
  return m[1];
}

String infoAboutBrain(Brain brain) {
  String result = "";
  for (Layer layer = brain.model.start.next; layer != null; layer = layer.next) {
    if (layer.prev == brain.model.start) {
      result += layer.weights.W.cols + " -> " + layer.weights.W.rows + " -> " + getClassName(layer.activation.toString()) + " -> ";
    } else if (layer.next == null) {
      result += layer.weights.W.rows + " -> " + getClassName(layer.activation.toString());
    } else {
      result += layer.weights.W.rows + " -> " + getClassName(layer.activation.toString()) + " -> ";
    }
  }
  return result;
}
