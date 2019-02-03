static final boolean ANDROID = false;

/*
 * Uncomment for Android Mode
 *
void requestAllPermissions() {
  requestPermission("android.permission.READ_EXTERNAL_STORAGE", "readExternalStorageGranted");
  requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "writeExternalStorageGranted");
}

File getExternalStorageDirectory() {
  return android.os.Environment.getExternalStorageDirectory();
}

void readExternalStorageGranted(boolean granted) {
  // Just ignore the notification
}

void writeExternalStorageGranted(boolean granted) {
  // Just ignore the notification
}
*/

/*
 * Uncomment for Java Mode
 */
void requestAllPermissions() {
}

File getExternalStorageDirectory() {
  return null;
}
