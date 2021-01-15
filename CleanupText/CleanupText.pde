ArrayList<HashMap<String, Integer>> F1 = new ArrayList<HashMap<String, Integer>>();
HashMap<String, Integer> F2 = new HashMap<String, Integer>();

ArrayList<HashMap<String, Float>> TF = new ArrayList<HashMap<String, Float>>();
HashMap<String, Float> IDF = new HashMap<String, Float>();

HashMap<String, Float> SCORES = new HashMap<String, Float>();
ArrayList<String> KEYWORDS = new ArrayList<String>();

Table stopwords;

String removeStopWords(String document) {
  for (TableRow row : stopwords.rows()) {
    String stopword = row.getString(0).toLowerCase();
    document = document.replaceAll("^" + stopword, " ");
    document = document.replaceAll(stopword + "$", " ");
    document = document.replaceAll(" " + stopword + " ", " ");
  }
  return document;
}

String cleanupDocument(String document) {
  // Remove parenthesis

  document = document.replaceAll("\\(.*\\)", " ");

  // Remove ponctuations

  document = document.replaceAll("[^a-zA-Z]", " ");

  document  = removeStopWords(document);

  // Remove spaces

  document = document.replaceAll("\\s+", " ").trim();

  return document;
}

HashMap<String, Integer> countWordInDocument(String document) {
  HashMap<String, Integer> result = new HashMap<String, Integer>();

  String[] words = document.split(" ");
  for (String word : words) {
    Integer cnt = result.get(word);
    if (cnt == null) {
      result.put(word, 1);
    } else {
      result.put(word, cnt + 1);
    }
  }
  
  F1.add(result);

  return result;
}

void countWordInAllDocuments(HashMap<String, Integer> statistics) {
  for (String word : statistics.keySet()) {
      Integer cnt = F2.get(word);
      if (cnt == null) {
        F2.put(word, 1);
      } else {
        F2.put(word, cnt + 1);
      }
    }
}

void setup() {
  stopwords = loadTable("StopWords.csv", "csv");

  //Table table = loadTable("WhyDocs.csv", "csv");
  //Table table = loadTable("MainIssuesDocs.csv", "csv");
  Table table = loadTable("UseCasesDocs.csv", "csv");
  
  println(table.getRowCount() + " total rows in table");

  for (TableRow row : table.rows()) {
    String document = row.getString(0).toLowerCase();
    document = cleanupDocument(document);
    HashMap<String, Integer> statistics = countWordInDocument(document);
    countWordInAllDocuments(statistics);
  }
  
  // Calculate TF
  
  for (HashMap<String, Integer> statistics : F1) {
    HashMap<String, Float> result = new HashMap<String, Float>();
    for (String word : statistics.keySet()) {
      Integer cnt = statistics.get(word);  
      result.put(word, log(1 + (float) cnt));
    }
    TF.add(result);
  }
  
  // Calculate IDF
  
  for (String word : F2.keySet()) {
    Integer cnt = F2.get(word);
    IDF.put(word, log((float) F1.size() / (float) cnt));
  }
  
  // Calculate TF_IDF
  
  for (HashMap<String, Float> statistics : TF) {
    String output = "";

    for (String word : statistics.keySet()) {
      Float tf = statistics.get(word);
      Float idf = IDF.get(word);
      float tf_idf = tf * idf;
      
      if(tf_idf >= 2.0f) {
        Float score = SCORES.get(word);
        if(score == null) {
          SCORES.put(word, tf_idf);
        } else {
          SCORES.put(word, max(score, tf_idf));
        }

        if(output.equals("")) {
          output = word;
        } else {
          output += " " + word;
        }
      }
    }
    
    KEYWORDS.add(output);
  }
  
  for(String keywords: KEYWORDS) {
    println(keywords);
  }
  
  //for(String word: SCORES.keySet()) {
  //  println(word + "," + SCORES.get(word));
  //}
}

void draw() {
}
