class Corpus {
  public String[] vocabulary;
  
  public DataSet dataSet;
  
  public void loadText(String filePath) {
    SpellChecker.init();
    
    print("Read and clean data ... ");
    String data = cleanupData(readData(filePath));
    println("done");
    
    print("Build corpus ... ");
    ArrayList<String[]> corpus = buildCorpus(data);
    println("done");
    
    print("Build vocabulary ... ");
    this.vocabulary = buildVocabulary(corpus);
    println("done");
    
    print("Build dataset ... ");
    this.dataSet = buildDataSet(corpus, vocabulary);
    println("done");
    
    println(data.length(), vocabulary.length, dataSet.rows().size());
  }

  private String readData(String filePath) {
    BufferedReader reader = createReader(filePath);

    try {
      String data = reader.readLine().toLowerCase().substring(0, 128 * 1024);
      reader.close();
      return data;
    } 
    catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  private String cleanupData(String data) {
    // normalize few words
    data = data.replaceAll("u\\.s\\.", "usa");
    data = data.replaceAll("no\\.", "no");
    data = data.replaceAll("inc\\.", "inc");

    // cleanup
    data = data.replaceAll(QUOTES, "");
    data = data.replaceAll(DASHES, "");
    data = data.replaceAll(END_OF_SENTENCE, ".");
    data = data.replaceAll(PUNCTUATIONS, " ");
    data = data.replaceAll(SPACES, " ");

    // cleanup spaces around end of sentence 
    data = data.replaceAll(" ?\\. ?", ".");

    return data;
  }

  private ArrayList<String[]> buildCorpus(String data) {
    ArrayList<String[]> corpus = new ArrayList<String[]>();

    String[] lines = data.split("\\.");
    for (String line : lines) if (line.length() > 0) { 
      String[] tokens = line.split(" ");

      for (int i = 0; i < tokens.length; i++) {
        tokens[i] = SpellChecker.correct(tokens[i]);
      }

      corpus.add(tokens);
    }

    return corpus;
  }

  private String[] buildVocabulary(ArrayList<String[]> corpus) {
    java.util.TreeSet<String> dictionary = new java.util.TreeSet<String>();

    for (String[] tokens : corpus) { 
      for (String token : tokens) {
        dictionary.add(token);
      }
    }

    dictionary.add(".");

    return dictionary.toArray(new String[dictionary.size()]);
  }

  private DataSet buildDataSet(ArrayList<String[]> corpus, String[] dictionary) {
    DataSet dataSet = new DataSet();
    StringColumn currWord = new StringColumn(new com.github.romualdrousseau.shuju.nlp.StringList(dictionary));
    StringColumn nextWord = new StringColumn(new com.github.romualdrousseau.shuju.nlp.StringList(dictionary));

    for (String[] tokens : corpus) { 
      for (int i = 0; i < tokens.length - 1; i++) {
        dataSet.addRow(new DataRow()
          .addFeature(currWord.valueOf(tokens[i]))
          .setLabel(nextWord.valueOf(tokens[i + 1])));
      }
      dataSet.addRow(new DataRow()
        .addFeature(currWord.valueOf(tokens[tokens.length - 1]))
        .setLabel(nextWord.valueOf(".")));
    }

    return dataSet;
  }
}
