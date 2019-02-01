int distribution[] = new int[18];
float avg;
int median;

void setup() {
  size(500, 500);
  textSize(16);
  noLoop();
  
  for(int i = 0; i < 6; i++) {
    distribution[i] = 0;
  }
  
  float sum = 0;
  float count = 0;
  Table table = loadTable("Sample.csv", "header");  
  for (TableRow row : table.rows()) {
    int idx = ((int) row.getDouble(0)) - 1;
    if(idx < 0) idx = 0;
    distribution[idx]++;
    sum += row.getDouble(0);
    count++;
  }
  avg = sum / count;
  println(count);
  println(avg);
  
  sum = 0;
  for(int i = 0; i < distribution.length; i++) {
    sum += distribution[i];
    if(sum > count / 2) {
      median = i;
      break;
    }
  }
  println(median);
}

void draw() {
  int s = width / distribution.length;
  for(int i = 0; i < distribution.length; i++) {
    rect(i * s, height - distribution[i] * s / 4, s, distribution[i] * s / 4);
  }
  stroke(255, 0, 0);
  line(avg * s, 0, avg * s, height);
  stroke(0, 0, 255);
  line(median * s, 0, median * s, height);
  save("graph.png");
}
