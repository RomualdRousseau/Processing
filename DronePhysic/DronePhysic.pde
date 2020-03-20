final float g = 9.81;
final float dt = 0.1;

float[] w = new float[4];
float T = 10;
float m = 0.2;
float r = 50;

float roll = 0;
float pitch = 0;
float yaw = 0;

float droll = 0;
float dpitch = 0;
float dyaw = 0;

PVector pos = new PVector();
PVector vel = new PVector();

float cmd_roll = 0;
float cmd_pitch = 0;
float cmd_yaw = 0;
boolean cmd_alt = false;

float kp = 0.005;
float ki = 0.0005;
float kd = 0.02;
float sum_error_roll = 0;
float last_error_roll = 0;
float sum_error_pitch = 0;
float last_error_pitch = 0;
float sum_error_yaw = 0;
float last_error_yaw = 0;
float sum_error_alt = 0;
float last_error_alt = 0;

PImage sprite = new PImage();

PVector rotate(PVector v, float pitch, float yaw, float roll) {
  float[][] R = {
    { cos(roll) * cos(yaw), cos(roll) * sin(yaw) * sin(pitch) - sin(roll) * cos(pitch), cos(roll) * sin(yaw) * cos(pitch) + sin(roll) * sin(pitch) },
    { sin(roll) * cos(yaw), sin(roll) * sin(yaw) * sin(pitch) + cos(roll) * cos(pitch), sin(roll) * sin(yaw) * cos(pitch) - cos(roll) * sin(pitch) },
    { -sin(yaw), cos(yaw) * sin(pitch), cos(yaw) * cos(pitch) }
  };
  
  PVector vv = new PVector();
  vv.x = R[0][0] * v.x + R[0][1] * v.y + R[0][2] * v.z;
  vv.y = R[1][0] * v.x + R[1][1] * v.y + R[1][2] * v.z;
  vv.z = R[2][0] * v.x + R[2][1] * v.y + R[2][2] * v.z;
  return vv;
}

float[] PID(float error, float sum_error_dt, float error_last) {
  if(abs(error) < 1e-3f) {
    return new float[] { 0, 0, error_last };
  } else {
    float derror_dt = (error - error_last) / dt;
    float corr = kp * error + ki * sum_error_dt + kd * derror_dt;
    sum_error_dt = constrain(sum_error_dt + error * dt, -1, 1);
    error_last = error;
    return new float[] { corr, sum_error_dt, error_last };
  }
}

void setup() {
  size(400, 400, P3D);

  sprite = loadImage("drone.png");
  sprite.filter(INVERT);
}

void draw() {
  
  // Drone Physic Calculation
  
  droll = w[0] - w[1] - w[2] + w[3];
  roll += droll * dt;
  
  dpitch = w[0] + w[1] - w[2] - w[3];
  pitch += dpitch * dt;
  
  dyaw = w[0] - w[1] + w[2] - w[3];
  yaw += dyaw * dt;
  
  PVector P = new PVector(0, -m * g, 0);
  PVector F = rotate(new PVector(0, w[0] + w[1] + w[2] + w[3], 0).mult(T), pitch, yaw, roll);
  PVector acc = new PVector().add(F).add(P).div(m);
  vel = vel.add(PVector.mult(acc, dt)).limit(20);
  pos = pos.add(PVector.mult(vel, dt));
  pos.x = constrain(pos.x, -300, 300);
  pos.y = constrain(pos.y, 0, 300 + r / 2);
  pos.z = constrain(pos.z, -300, 0);
  
  if(pos.y == 0) {
    roll = 0;
    pitch = 0;
    yaw = 0;
  }
  
  // Stabilize Drone Flight
  
  float[] tmp = PID(cmd_roll - roll, sum_error_roll, last_error_roll);
  w[0] += tmp[0];
  w[1] -= tmp[0];
  w[2] -= tmp[0];
  w[3] += tmp[0];
  sum_error_roll = tmp[1];
  last_error_roll = tmp[2];
  
  tmp = PID(cmd_pitch - pitch, sum_error_pitch, last_error_pitch);
  w[0] += tmp[0];
  w[1] += tmp[0];
  w[2] -= tmp[0];
  w[3] -= tmp[0];
  sum_error_pitch = tmp[1];
  last_error_pitch = tmp[2];
  
  //tmp = PID(cmd_yaw - yaw, sum_error_yaw, last_error_yaw);
  //w[0] += tmp[0];
  //w[1] -= tmp[0];
  //w[2] += tmp[0];
  //w[3] -= tmp[0];
  //sum_error_yaw = tmp[1];
  //last_error_yaw = tmp[2];
  
  // Keep Altitude
  
  if(cmd_alt) {
    tmp = PID(200 - pos.y, sum_error_alt, last_error_alt);
    w[0] += tmp[0];
    w[1] += tmp[0];
    w[2] += tmp[0];
    w[3] += tmp[0];
    sum_error_alt = tmp[1];
    last_error_alt = tmp[2];
  }
  
  // Draw the world and the copter
  
  background(51);
  noFill();
  stroke(255);
  translate(width * 0.5, height * 0.9, -100);
  
  pushMatrix();
  translate(0, -(300 + r / 2) /2, 0);
  box(600, 300 + r, 600);
  popMatrix();
  
  pushMatrix();
  translate(pos.x, -pos.y - r / 2, pos.z);
  rotateX(-pitch);
  rotateY(yaw);
  rotateZ(-roll);
  box(r * 2, r, r*2);
  popMatrix();
}

void keyPressed() {
  if(key == 'a') {
    cmd_roll += 0.1;
  } else if(key == 'd') {
    cmd_roll -= 0.1;
  } else if(key == 'w') {
    cmd_pitch -= 0.1;
  } else if(key == 's') {
    cmd_pitch += 0.1;
  } else if(key == 'x') {
    // cmd_yaw += 0.1;
    w[0] += 0.01;
    w[1] -= 0.01;
    w[2] += 0.01;
    w[3] -= 0.01;
  } else if(key == 'c') {
    // cmd_yaw -= 0.1;
    w[0] -= 0.01;
    w[1] += 0.01;
    w[2] -= 0.01;
    w[3] += 0.01;
  } else if(key == 'q') {
    w[0] += 0.5;
    w[1] += 0.5;
    w[2] += 0.5;
    w[3] += 0.5;
  } else if(key == 'z') {
    w[0] -= 0.5;
    w[1] -= 0.5;
    w[2] -= 0.5;
    w[3] -= 0.5;
  } else if(key == 'e') {
    cmd_alt = !cmd_alt;
  }
}
