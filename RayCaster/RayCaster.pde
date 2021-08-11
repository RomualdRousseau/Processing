public static _ScriptFactory  ScriptFactory;
public static _Input          Input;
public static _Scene          Scene;

HUD hud = new HUD();

void setup() {
  size(640, 400, P3D);
  //fullScreen(P3D);
  frameRate(60);
  
  ScriptFactory = this.new _ScriptFactory();
  Input = this.new _Input();
  Scene = this.new _Scene(this);

  ScriptFactory.init();
  Input.init();
  Scene.init(320, 200);
  
  Scene.start();
}

void draw() {
  Scene.update(1.0 / max(30, frameRate));
  Scene.draw();
  hud.draw();
}
