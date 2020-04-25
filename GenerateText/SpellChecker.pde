class _SpellChecker {

  public void init() {
    this.dictionary = loadStrings("data/words_alpha.txt");
    
    for (int i = 0; i < dictionary.length; i++) {
      this.dictionary[i] = this.dictionary[i].toLowerCase().replaceAll("[^a-z-']", "");
    }
  }
 
  public String correct(String word) {
    float max = 0.0f;
    int index = -1;

    for (int j = 0; j < dictionary.length; j++) {
      
      float similarity = FuzzyString.JaroWinkler(word, this.dictionary[j]);
      
      if (similarity > max && similarity > 0.9f) {
        max = similarity;
        index = j;
      }
    }

    if (index >= 0) {
      return this.dictionary[index];
    } else {
      return word;
    }
  }

  private String[] dictionary;
}
_SpellChecker SpellChecker = new _SpellChecker();
