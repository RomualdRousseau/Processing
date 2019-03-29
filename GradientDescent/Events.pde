void mouseMoved() {
  if (0 <= mouseX && mouseX < width / 2 && 0 <= mouseY && mouseY < height / 2) {
    Map2D.active = true;
    Map3D.active = false;
  } else if (width / 2 <= mouseX && mouseX < width && 0 <= mouseY && mouseY < height / 2) {
    Map2D.active = false;
    Map3D.active = true;
  } else {
    Map2D.active = false;
    Map3D.active = false;
  }
}

void mouseClicked() {
  if (Map2D.active) {
    float x = map(mouseX, 0, width / 2, 0, 1);
    float y = map(mouseY, 0, height / 2, 0, 1);
    float z =  (mouseButton == LEFT) ? 0 : 1;
    Map2D.points.add(new PVector(x, y, z));
    Brain.dataChanged = true;
  }
}

void mouseDragged() {
  if (Map3D.active) {
    if (mouseButton == LEFT) {
      Map3D.view.y += (mouseX - pmouseX) * 0.01;
      Map3D.view.x -= (mouseY - pmouseY) * 0.01;
    } else if (mouseButton == RIGHT) {
      Map3D.view.z += sgn(pmouseY - mouseY);
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (Map3D.active) {
    Map3D.view.z += -event.getCount();
  }
}

void keyPressed() {
  if (keyCode == actionMap[0].keyCode) {
    Map2D.points.clear();
    Brain.optimizer.reset();
  } else if (keyCode == actionMap[1].keyCode) {
    Map2D.points.clear();
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
