boolean inMap2D = false;
boolean inMap3D = false;

void mouseMoved() {
  if (0 <= mouseX && mouseX < width / 2 && 0 <= mouseY && mouseY < height / 2) {
    inMap2D = true;
    inMap3D = false;
  } else if (width / 2 <= mouseX && mouseX < width && 0 <= mouseY && mouseY < height / 2) {
    inMap2D = false;
    inMap3D = true;
  } else {
    inMap2D = false;
    inMap3D = false;
  }
}

void mouseClicked() {
  if (inMap2D) {
    float x = map(mouseX, 0, width / 2, 0, 1);
    float y = map(mouseY, 0, height / 2, 0, 1);
    float z =  (mouseButton == LEFT) ? 0 : 1;
    points.add(new PVector(x, y, z));
    Brain.dataChanged = true;
  }
}

void mouseDragged() {
  if (inMap3D) {
    if (mouseButton == LEFT) {
      map3D_angleY += (mouseX - pmouseX) * 0.01;
      map3D_angleX -= (mouseY - pmouseY) * 0.01;
    } else if (mouseButton == RIGHT) {
      map3D_zoom += sgn(pmouseY - mouseY);
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (inMap3D) {
    map3D_zoom += -event.getCount();
  }
}

void keyPressed() {
  if (keyCode == actionMap[0].keyCode) {
    points.clear();
    Brain.optimizer.reset();
  } else if (keyCode == actionMap[1].keyCode) {
    points.clear();
    Brain.model.reset();
    Brain.optimizer.reset();
  } else if (keyCode == actionMap[2].keyCode) {
    selectOutput("Select a file to write to:", "fileOutput");
  } else if (keyCode == actionMap[3].keyCode) {
    selectInput("Select a file to read from:", "fileinput");
  }
}

void fileOutput(File selection) {
  if (selection != null) {
    saveJSONArray(Brain.model.toJSON(), selection.getAbsolutePath());
  }
}

void fileinput(File selection) {
  if (selection != null) {
    Brain.model.fromJSON(loadJSONArray(selection.getAbsolutePath()));
  }
}
