String getDataPath(String relativeFilename){
  if (ANDROID) {
   File externalDir = getExternalStorageDirectory();
   if (externalDir == null ){
     return null;
   }
   String sketchName= this.getClass().getSimpleName();
   File sketchSdDir = new File(externalDir, sketchName);
   File finalDir =  new File(sketchSdDir, relativeFilename);
   return finalDir.getAbsolutePath();
  } else {
    return dataPath(relativeFilename);
  }
}

void ensureDataPathExist() {
  if (ANDROID) {
    new File(getDataPath("")).mkdirs();
    JSONObject jsonBrain = loadJSONObject("melody.json");
    saveJSONObject(jsonBrain, getDataPath("melody.json"));
  }
}

boolean fileExistsInData(String fileName) {
  return new File(getDataPath(fileName)).exists();
}

void deleteFileInData(String fileName) {
  File file = new File(getDataPath(fileName));
  if(file.exists()) { 
    file.delete();
  }
}

boolean isSpaceBarPressed(GameMode mode_) {
  if (mode_ == GameMode.ALL || mode == mode_) {
    if (mousePressed && mouseY <= mapToScreenY(80) || keyPressed && key == ' ') {
      delay(200); // Avoid Debounce; crude but it works
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}
