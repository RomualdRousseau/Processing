import com.github.romualdrousseau.nari.*;

import com.github.romualdrousseau.shuju.columns.*;
import com.github.romualdrousseau.shuju.cv.*;
import com.github.romualdrousseau.shuju.*;
import com.github.romualdrousseau.shuju.json.jackson.*;
import com.github.romualdrousseau.shuju.json.processing.*;
import com.github.romualdrousseau.shuju.math.*;
import com.github.romualdrousseau.shuju.ml.nn.activation.*;
import com.github.romualdrousseau.shuju.ml.nn.initializer.*;
import com.github.romualdrousseau.shuju.ml.nn.loss.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.builder.*;
import com.github.romualdrousseau.shuju.ml.nn.*;
import com.github.romualdrousseau.shuju.ml.qlearner.*;
import com.github.romualdrousseau.shuju.nlp.*;
import com.github.romualdrousseau.shuju.util.*;
import com.github.romualdrousseau.shuju.cv.templatematching.*;
import com.github.romualdrousseau.shuju.genetic.*;
import com.github.romualdrousseau.shuju.math.distribution.*;
import com.github.romualdrousseau.shuju.ml.kmean.*;
import com.github.romualdrousseau.shuju.cv.templatematching.shapeextractor.*;
import com.github.romualdrousseau.shuju.json.*;
import com.github.romualdrousseau.shuju.ml.nn.layer.builder.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.*;
import com.github.romualdrousseau.shuju.ml.nn.scheduler.*;
import com.github.romualdrousseau.shuju.ml.slr.*;
import com.github.romualdrousseau.shuju.transforms.*;
import com.github.romualdrousseau.shuju.ml.knn.*;
import com.github.romualdrousseau.shuju.ml.nn.layer.*;
import com.github.romualdrousseau.shuju.nlp.impl.*;
import com.github.romualdrousseau.shuju.ml.naivebayes.*;

final static int K = 64;

Tensor2D[] data = new Tensor2D[1000];
Tensor2D[] labels = new Tensor2D[1000];

color[] palette =  new color[K];

KMean kmean = new KMean(K);

void setup() {
  size(1000, 1000);
  frameRate(1);

  try {
    //prepareLynXCRMCustomer("inputs/lynxcrm_customers.csv");
    //prepareZuelligCustomer("inputs/zuellig_customers.csv");
    mapZuelligLynXCRMCustomers();
  }
  catch(Exception x) {
    println(x);
  }

  for (int i = 0; i < data.length; i++) {
    data[i] = new Tensor2D(new float[] { random(1), random(1) });
    labels[i] = new Tensor2D(1, K).oneHot(int(random(K)));
  }

  for (int i = 0; i < K; i++) {
    palette[i] = color(i * 2, i * 2 + 64, i * 2 + 128);
  }
}

void draw() {
  background(51);

  for (int e = 0; e < 100; e++) {
    kmean.fit(data, labels);
  }

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      Tensor2D point = new Tensor2D(new float[] {map(x, 0, width, 0, 1), map(y, 0, height, 0, 1)});
      Tensor2D label = kmean.predict(point);
      int k = label.argmax(0, 1);
      //float[] v = new Tensor2D(1, K).oneHot(k).getFloats(0);
      //float r = map(v[0], 0, 1, 128, 255);
      //float g = map(v[1], 0, 1, 128, 255);
      //float b = map(v[2], 0, 1, 128, 255);
      stroke(palette[k], 128);
      point(x, y);
    }
  }

  noStroke();

  for (int i = 0; i < data.length; i++) {
    Tensor2D point = data[i];
    Tensor2D label = labels[i];

    int k = label.argmax(0, 1);
    //float[] v = new Tensor2D(1, K).oneHot(label.argmax(0, 1)).getFloats(0);
    //float r = map(v[0], 0, 1, 128, 255);
    //float g = map(v[1], 0, 1, 128, 255);
    //float b = map(v[2], 0, 1, 128, 255);
    fill(palette[k]);

    float x = map(point.get(0, 0), 0, 1, 0, width);
    float y = map(point.get(0, 1), 0, 1, 0, height);
    ellipse(x, y, 5, 5);
  }
}

void keyPressed() {
  for (int i = 0; i < data.length; i++) {
    data[i] = new Tensor2D(new float[] { random(1), random(1) });
  }
}
