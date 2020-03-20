class Node {
  int col;
  String v;

  Node(int col, String v) {
    this.col = col;
    this.v = v;
  }
}

class Context {
  public int group = 0;
  public int col = 0;
  public int row = 0;
  public boolean hasHeader = false;
  public boolean firstRow = true;

  ArrayList<String> metas = new ArrayList<String>();
  ArrayList<Node> pivots = new ArrayList<Node>();
  ArrayList<Node> headers = new ArrayList<Node>();
  ArrayList<String> values = new ArrayList<String>();

  public void func(String c) {
    //println(group, c);
    
    int g = (group - 1) % 3;
    
    if (g == 0) {
      if (c.equals("m")) {
        if (hasHeader) {
          pivots.add(new Node(col, c));
        } else {
          metas.add(c);
        }
      } else if (!c.equals("$")) {
        headers.add(new Node(col, c));
        hasHeader = true;
      }
    } else if (g == 1) {
      if (c.equals("$")) {
        if(firstRow) {
          for (String m : metas) {
            print(m);
          }

          for (Node h : headers) {
            print(h.v);
          }

          print(pivots.get(0).v);
          println("h");
          
          firstRow = false;
        }
        
        for (Node p : pivots) {
          for (String m : metas) {
            print(m);
          }

          for (Node h : headers) {
            print(values.get(h.col));
          }

          print(p.v);
          println(values.get(p.col));
        }
        values.clear();
      } else {
        values.add(c);
      }
    } else if (g == 2) {
      metas.clear();
      pivots.clear();
      headers.clear();
      values.clear();
    }

    col++;
    if (c.equals("$")) {
      col = 0;
      row++;
      hasHeader = false;
    }
  }
}
