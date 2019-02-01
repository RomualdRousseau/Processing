class Resources_ {
  void loadAll(PApplet parent) {
    this.loadFonts();
    this.loadSprites();
    this.loadSounds(parent);
  }
  
  void loadFonts() {
    textFont(createFont("Broadway", 32));
  }
  
  void loadSprites() {
    CITY_SPRITE = loadImage("city.png");
    BIRD_SPRITE = loadImage("bird.png");
    PILLAR_SPRITE = loadImage("pillar.png");
    STAR_SPRITE = loadImage("star.png");
    BONUS_SPRITE = loadImage("bonus.png");
    TROPHEE_SPRITE = loadImage("trophee.png");
  }
  
  void loadSounds(PApplet parent) {
    POINT_SOUND = new SoundFile(parent, "point.wav");
    CRASH_SOUND = new SoundFile(parent, "crash.wav");
  }
}
Resources_ Resources = new Resources_();
