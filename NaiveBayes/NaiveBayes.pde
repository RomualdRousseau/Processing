import com.github.romualdrousseau.shuju.columns.*;
import com.github.romualdrousseau.shuju.cv.*;
import com.github.romualdrousseau.shuju.*;
import com.github.romualdrousseau.shuju.json.jackson.*;
import com.github.romualdrousseau.shuju.json.processing.*;
import com.github.romualdrousseau.shuju.math.*;
import com.github.romualdrousseau.shuju.ml.nn.activation.*;
import com.github.romualdrousseau.shuju.ml.nn.initializer.*;
import com.github.romualdrousseau.shuju.ml.nn.loss.*;
import com.github.romualdrousseau.shuju.ml.nn.normalizer.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.*;
import com.github.romualdrousseau.shuju.ml.qlearner.*;
import com.github.romualdrousseau.shuju.nlp.impl.*;
import com.github.romualdrousseau.shuju.transforms.*;
import com.github.romualdrousseau.shuju.math.distribution.*;
import com.github.romualdrousseau.shuju.ml.kmean.*;
import com.github.romualdrousseau.shuju.ml.nn.*;
import com.github.romualdrousseau.shuju.ml.nn.optimizer.builder.*;
import com.github.romualdrousseau.shuju.nlp.*;
import com.github.romualdrousseau.shuju.util.*;
import com.github.romualdrousseau.shuju.cv.templatematching.*;
import com.github.romualdrousseau.shuju.genetic.*;
import com.github.romualdrousseau.shuju.cv.templatematching.shapeextractor.*;
import com.github.romualdrousseau.shuju.json.*;
import com.github.romualdrousseau.shuju.ml.knn.*;
import com.github.romualdrousseau.shuju.ml.naivebayes.*;
import com.github.romualdrousseau.shuju.ml.nn.scheduler.*;
import com.github.romualdrousseau.shuju.ml.slr.*;

DataSet dataset;
PImage domain;

int getClassColor(Vector y) {
  switch(y.argmax()) {
  case 0:
    return color(255, 0, 0);
  case 1:
    return color(0, 255, 0);
  case 2:
    return color(0, 0, 255);
  case 3:
    return color(255, 255, 0);
  case 4:
    return color(0, 255, 255); 
  case 5:
    return color(255, 0, 255); 
  default:
    return color(51, 51, 51);
  }
}

void demo() {
  dataset = DataSet.makeBlobs(1000, 2, 5);
  
  com.github.romualdrousseau.shuju.ml.naivebayes.NaiveBayes nbc = new com.github.romualdrousseau.shuju.ml.naivebayes.NaiveBayes();
  nbc.fit(dataset.featuresAsVectorArray(), dataset.labelsAsVectorArray());

  domain = new PImage(width, height);
  domain.loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      Vector yt = nbc.predict(new Vector(new float[]{ map(x, 0, width, -10, 10), map(y, 0, height, -10, 10) }));
      domain.pixels[y * width + x] = getClassColor(yt);
    }
  }
  domain.updatePixels();
}

void setup() {
  size(800, 800);
  demo();
}

void draw() {
  background(51);

  for (DataRow row : dataset.rows()) {
    fill(getClassColor(row.label()));
    float x = map(row.features().get(0).get(0), -10, 10, 0, width);
    float y = map(row.features().get(0).get(1), -10, 10, 0, height);
    circle(x, y, 10);
  }

  tint(255, 126);
  image(domain, 0, 0);
}

void keyPressed() {
  demo();
}
