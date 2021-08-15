public abstract class Graph
{
  public float zoom = 50;
  public float mouseX = 0;
  public float mouseY = 0;

  protected PGraphics canvas;
  protected GraphFunction inline;

  public Graph(PApplet applet) {
    canvas = applet.g;
  }
  
  public Graph apply(GraphFunction inline_) {
    inline = inline_;
    return this;
  }
  
  public abstract void draw();
  
  public abstract void pixels(BiFunction<Float, Float, Float> inline);

  public abstract void point(float[] p, String label, boolean moveable);

  public abstract void segment(float[] p1, float[] p2, String label);

  public abstract void line(float[] l, String label);
}

public interface GraphFunction
{
  void draw(Graph graph, float dt);
}

public class Graph2D extends Graph
{
  public Graph2D(PApplet applet) {
    super(applet);
  }

  public void draw() {
    canvas.background(79);
    canvas.translate(width/2, height/2);

    float wh = width/2;
    float hh = height/2;

    canvas.stroke(64);
    canvas.strokeWeight(1);
    canvas.line(0, -hh, 0, hh);
    canvas.line(-wh, 0, wh, 0);

    for (float i = 0; i < wh; i+=zoom) {
      canvas.line(-i, -2, -i, +2);
      canvas.line(i, -2, i, +2);
    }

    for (float i = 0; i < hh; i+=zoom) {
      canvas.line(-2, -i, +2, -i);
      canvas.line(-2, i, +2, i);
    }
    
    inline.draw(this, 1 / frameRate);
  }
  
  public void pixels(BiFunction<Float, Float, Float> inline) {
    final int hw = width / 2;
    final int hh = height / 2;
  
    loadPixels();
    for (int y = -hw; y < hw; y++) {
      for (int x = -hh; x < hw; x++) {
        pixels[(y + hw) * width + x + hw] = color(inline.apply((float) x / hw, (float) y / hh));
      }
    }
    updatePixels();
  }

  public void point(float[] p, String label, boolean moveable) {
    float x = p[5] / p[6];
    float y = p[4] / p[6];

    if (moveable) {
      canvas.stroke(64);
      canvas.line(x * zoom, 0, x * zoom, -y * zoom);
      canvas.line(0, -y * zoom, x * zoom, -y * zoom);
    }

    if (moveable) {
      canvas.stroke(255, 255, 0);
      canvas.fill(255, 255, 0);
    } else {
      canvas.stroke(192);
      canvas.fill(192);
    }

    canvas.strokeWeight(8);
    canvas.point(x * zoom, -y * zoom);

    canvas.text(label, x * zoom + 5, -y * zoom - 5);
  }

  public void segment(float[] p1, float[] p2, String label) {
    float x1 = p1[5] / p1[6];
    float y1 = p1[4] / p1[6];

    float x2 = p2[5] / p2[6];
    float y2 = p2[4] / p2[6];

    float xm = (x1 + x2) / 2;
    float ym = (y1 + y2) / 2;

    canvas.stroke(255, 255, 255, 128);
    canvas.strokeWeight(1);
    canvas.line(x1 * zoom, -y1 * zoom, x2 * zoom, -y2 * zoom);

    canvas.fill(255);
    canvas.pushMatrix();
    canvas.translate(xm * zoom, -ym * zoom);
    canvas.rotate(-new PVector(x2 - x1, y2 - y1).heading());
    canvas.text(label, 0, 0);
    canvas.popMatrix();
  }

  public void line(float[] l, String label) {
    float x1, y1, x2, y2;
    if (abs(l[2]) > abs(l[3])) {
      y1 = -height/2;
      x1 = (l[1] + l[3] * y1) / l[2];

      y2 = height/2;
      x2 = (l[1] + l[3] * y2) / l[2];
    } else {
      x1 = -width/2;
      y1 = (-l[1] + l[2] * x1) / l[3];

      x2 = width/2;
      y2 = (-l[1] + l[2] * x2) / l[3];
    }

    float xm = (x1 + x2) / 2;
    float ym = (y1 + y2) / 2;

    canvas.stroke(255, 255, 255, 128);
    canvas.strokeWeight(1);
    canvas.line(x1 * zoom, -y1 * zoom, x2 * zoom, -y2 * zoom);

    canvas.fill(255);
    canvas.pushMatrix();
    canvas.translate(xm * zoom, -ym * zoom);
    canvas.rotate(-new PVector(x2 - x1, y2 - y1).heading());
    canvas.text(label, 0, 0);
    canvas.popMatrix();
  }
}
