import processing.serial.*;

class Servo
{
  public int servos[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  public int trims[] = {
    -5, -25, -10,
    15, -10, 5,
    0, 0, -5,
    5, -10, 0};
  
  public Servo(Serial port)
  {
    this.port = port;
  }
  
  public void updateServos()
  {
    String cmd = "";
    for(int i = 0; i < 6; i++) {
      double degree = this.servos[i] + this.trims[i];
      int ms = (int) (1400.0 + 800.0 * degree / 90.0);
      if(ms < 600) ms = 600;
      if(ms > 2200) ms = 2200;
      cmd += "#" + (i + 1) + "P" + ms;
    }
    for(int i = 6; i < 12; i++) {
      double degree = this.servos[i] + this.trims[i];
      int ms = (int) (1400.0 + 800.0 * degree / 90.0);
      if(ms < 600) ms = 600;
      if(ms > 2200) ms = 2200;
      cmd += "#" + (i + 1) + "P" + ms;
    }
    cmd += "T10\n\r";
    this.port.write(cmd);
  }
  
  private Serial port;
}