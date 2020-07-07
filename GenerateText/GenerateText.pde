Corpus corpus = new Corpus();

void setup() {
  size(400, 400);
  
  corpus.loadText("data/internet_archive_scifi_v3.txt");
  
  //saveStrings("data/vocabulary.txt", corpus.vocabulary);
}

void draw() {
}
