//Servo servo = new Servo(new Serial(this, "/dev/ttyACM0", 115200)); //<>//

Bone pivot;
Bone back1;
Bone back2;
Bone back3;

Bone[] shoulder = new Bone[4];
Bone[] arm = new Bone[4];
Bone[] forearm = new Bone[4];
Bone[] claw = new Bone[4];

BonePhysics[] clawPhysics = new BonePhysics[4];

PrintWriter outputRecording;
boolean isRecording = false;

void setup() {
  size(640, 640, P3D);
  noStroke();

  pivot = new Bone(null, DOF0, new float[] {0, 0, -HALF_PI}, 100); 
  back1 = new Bone(pivot, DOF0, new float[] {0, -HALF_PI, 0}, 50);
  back2 = new Bone(pivot, DOF0, new float[] {0, HALF_PI, 0}, 50);
  back3 = new Bone(back2, DOF0, new float[] {0, HALF_PI, 0}, 100);

  shoulder[0] = new Bone(back1, DOF0, new float[] {0, -QUARTER_PI, 0}, 100);
  arm[0] = new Bone(shoulder[0], DOFY, new float[] {0, -QUARTER_PI, 0}, 70);
  forearm[0] = new Bone(arm[0], DOFZ, new float[] {0, -QUARTER_PI, HALF_PI}, 50);
  claw[0] = new Bone(forearm[0], DOFZ, new float[] {0, -QUARTER_PI, -HALF_PI * 3 / 4}, 110);

  shoulder[1] = new Bone(back1, DOF0, new float[]{0, QUARTER_PI, PI}, 100);
  arm[1] = new Bone(shoulder[1], DOFY, new float[]{0, QUARTER_PI, PI}, 70);
  forearm[1] = new Bone(arm[1], DOFZ, new float[]{0, QUARTER_PI, PI - HALF_PI}, 50);
  claw[1] = new Bone(forearm[1], DOFZ, new float[]{0, QUARTER_PI, PI + HALF_PI * 3 / 4}, 110);

  shoulder[2] = new Bone(back2, DOF0, new float[] {0, QUARTER_PI, 0}, 100);
  arm[2] = new Bone(shoulder[2], DOFY, new float[] {0, QUARTER_PI, 0}, 70);
  forearm[2] = new Bone(arm[2], DOFZ, new float[] {0, QUARTER_PI, HALF_PI}, 50);
  claw[2] = new Bone(forearm[2], DOFZ, new float[] {0, QUARTER_PI, -HALF_PI * 3 / 4}, 110);

  shoulder[3] = new Bone(back2, DOF0, new float[]{0, -QUARTER_PI, PI}, 100);
  arm[3] = new Bone(shoulder[3], DOFY, new float[]{0, -QUARTER_PI, PI}, 70);
  forearm[3] = new Bone(arm[3], DOFZ, new float[]{0, -QUARTER_PI, PI - HALF_PI}, 50);
  claw[3] = new Bone(forearm[3], DOFZ, new float[]{0, -QUARTER_PI, PI + HALF_PI * 3 / 4}, 110);

  for (int i = 0; i < 4; i++) {
    clawPhysics[i] = new FallingPhysics(claw[i].getTipVector());
  }

  outputRecording = createWriter("rawdata.csv");
}

void draw() {
  if (isRecording) {
    outputRecording.println("shoulder;" + frameCount + ";" + shoulder[0].dofAxis + ";" + shoulder[0].locAngle[0] + ";" + shoulder[0].locAngle[1] + ";" + shoulder[0].locAngle[2]);
    outputRecording.println("arm;" + frameCount + ";" + arm[0].dofAxis + ";" + arm[0].locAngle[0] + ";" + arm[0].locAngle[1] + ";" + arm[0].locAngle[2]);
    outputRecording.println("forearm;" + frameCount + ";" + forearm[0].dofAxis + ";" + forearm[0].locAngle[0] + ";" + forearm[0].locAngle[1] + ";" + forearm[0].locAngle[2]);
    outputRecording.println("claw;" + frameCount + ";" + claw[0].dofAxis + ";" + claw[0].locAngle[0] + ";" + claw[0].locAngle[1] + ";" + claw[0].locAngle[2]);
    outputRecording.flush();
  }

  for (int i = 0; i < 4; i++) {
    claw[i].updatePhysics(clawPhysics[i], 1.0 / frameRate);
  }

  background(220);

  // setup lights
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, -0.4, 0.4, -0.4);

  // set camera
  float a = TWO_PI * ((float)mouseX - width * 0.5) / width;
  camera(width * sin(a), -height + mouseY, width * cos(a), 0, 0, 0, 0, 1, 0);

  pushMatrix();
  translate(x, -y, 0);

  pivot.draw();
  back1.draw();
  back2.draw();
  back3.draw();

  for (int i = 0; i < 4; i++) {
    shoulder[i].draw();
    arm[i].draw();
    forearm[i].draw();
    claw[i].draw();
  }

  translate(0, 0, -200);

  back1.draw();
  back2.draw();

  for (int i = 0; i < 4; i++) {
    shoulder[i].draw();
    arm[i].draw();
    forearm[i].draw();
    claw[i].draw();
  }

  popMatrix();

  /*
  for(int i = 0; i < 4; i++) {
   if(i == 0) {
   servo.servos[i * 3 + 0] = (int) (arm[i].locAngle[arm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 1] = -45 + 180 - (int) (forearm[i].locAngle[forearm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 2] = -65 + 315 + (int) (claw[i].locAngle[claw[i].dofAxis] * 360.0 / PI);
   }
   else if(i == 1) {
   servo.servos[i * 3 + 0] = -(int) (arm[i].locAngle[arm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 1] = -45 + 180 + (int) (forearm[i].locAngle[forearm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 2] = -65 + 315 - (int) (claw[i].locAngle[claw[i].dofAxis] * 360.0 / PI);
   }
   else if(i == 2) {
   servo.servos[i * 3 + 0] = (int) (arm[i].locAngle[arm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 1] = -45 + 180 - (int) (forearm[i].locAngle[forearm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 2] = -65 + 315 + (int) (claw[i].locAngle[claw[i].dofAxis] * 360.0 / PI);
   }
   else if(i == 3) {
   servo.servos[i * 3 + 0] = -(int) (arm[i].locAngle[arm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 1] = -45 + 180 + (int) (forearm[i].locAngle[forearm[i].dofAxis] * 360.0 / PI);
   servo.servos[i * 3 + 2] = -65 + 315 - (int) (claw[i].locAngle[claw[i].dofAxis] * 360.0 / PI);
   }
   }
   servo.updateServos();
   */
}

void keyPressed() {
  if (key == 'w') {
    clawPhysics[0] = new WalkingPhysics(claw[0].getTipVector(), 0);
    clawPhysics[1] = new WalkingPhysics(claw[1].getTipVector(), PI);
    clawPhysics[2] = new WalkingPhysics(claw[2].getTipVector(), PI);
    clawPhysics[3] = new WalkingPhysics(claw[3].getTipVector(), 0);
  } else if (key == 'r') {
    for (int i = 0; i < 4; i++) {
      arm[i].reset();
      forearm[i].reset();
      claw[i].reset();
      clawPhysics[i] = new FallingPhysics(claw[i].getTipVector());
    }
  } else if (key == 'q') {
    y+=5;
  } else if (key == 'a') {
    y-=5;
    if (y < 152) y = 152;
  } else if (key == 'c') {
    isRecording = !isRecording;
  }
}
