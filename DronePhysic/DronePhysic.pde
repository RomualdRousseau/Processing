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

PShape sprite3D;
PImage sprite;

PVector rotate(PVector v, float pitch, float yaw, float roll) {
  final float pitch_c = cos(pitch), pitch_s = sin(pitch);
  final float yaw_c = cos(yaw), yaw_s = sin(yaw);
  final float roll_c = cos(roll), roll_s = sin(roll);
  final float[][] R = {
    { roll_c * yaw_c, roll_c * yaw_s * pitch_s - roll_s * pitch_c, roll_c * yaw_s * pitch_c + roll_s * pitch_s }, 
    { roll_s * yaw_c, roll_s * yaw_s * pitch_s + roll_c * pitch_c, roll_s * yaw_s * pitch_c - roll_c * pitch_s }, 
    { -yaw_s, yaw_c * pitch_s, yaw_c * pitch_c                             }
  };
  PVector vv = new PVector();
  vv.x = R[0][0] * v.x + R[0][1] * v.y + R[0][2] * v.z;
  vv.y = R[1][0] * v.x + R[1][1] * v.y + R[1][2] * v.z;
  vv.z = R[2][0] * v.x + R[2][1] * v.y + R[2][2] * v.z;
  return vv;
}

float[] PID(float error, float sum_error_dt, float error_last) {
  if (abs(error) < 1e-3f) {
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
  size(800, 800, P3D);

  sprite = loadImage("drone.png");
  sprite.filter(INVERT);

  sprite3D = loadShape("Drone_obj.obj");
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
  pos.x = constrain(pos.x, -500, 500);
  pos.y = constrain(pos.y, 0, 500 - r * 0.5);
  pos.z = constrain(pos.z, -500, 0);

  if (pos.y == 0) {
    pitch = 0;
    roll = 0;
    yaw = 0;
  }
  
  w[0] += random(-0.005, 0.005);
  w[1] += random(-0.005, 0.005);
  w[2] += random(-0.005, 0.005);
  w[3] += random(-0.005, 0.005);

  // Stabilize Drone Flight

  float[] tmp = PID(cmd_roll - roll, sum_error_roll, last_error_roll);
  w[0] += tmp[0] + random(-0.001, 0.001);
  w[1] -= tmp[0] + random(-0.001, 0.001);
  w[2] -= tmp[0] + random(-0.001, 0.001);
  w[3] += tmp[0] + random(-0.001, 0.001);
  sum_error_roll = tmp[1];
  last_error_roll = tmp[2];

  tmp = PID(cmd_pitch - pitch, sum_error_pitch, last_error_pitch);
  w[0] += tmp[0];
  w[1] += tmp[0];
  w[2] -= tmp[0];
  w[3] -= tmp[0];
  sum_error_pitch = tmp[1];
  last_error_pitch = tmp[2];

  tmp = PID(cmd_yaw - yaw, sum_error_yaw, last_error_yaw);
  w[0] += tmp[0];
  w[1] -= tmp[0];
  w[2] += tmp[0];
  w[3] -= tmp[0];
  sum_error_yaw = tmp[1];
  last_error_yaw = tmp[2];

  // Keep Altitude

  if (cmd_alt) {
    tmp = PID(500 * 0.7 - pos.y, sum_error_alt, last_error_alt);
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
  stroke(128);
  translate(width * 0.5, height * 0.9, -100);

  pushMatrix();
  translate(0, -height * 0.5, -width * 0.5 + 100);
  box(width, height, width + 200);
  popMatrix();

  pushMatrix();
  translate(
    map(pos.x, -500, 500, -width * 0.5, width * 0.5), 
    map(pos.y + r * 0.5, 0, 500, 0, -height * 0.9), 
    map(pos.z, -500, 0, -width, 0));
  rotateX(-pitch);
  rotateY(yaw);
  rotateZ(-roll);
  box(r * 4, r, r * 2);
  scale(-5 * r);
  shape(sprite3D, 0, 0);
  popMatrix();
}

void keyPressed() {
  if (key == 'a') {
    cmd_roll += 0.1;
  } else if (key == 'd') {
    cmd_roll -= 0.1;
  } else if (key == 'w') {
    cmd_pitch -= 0.1;
  } else if (key == 's') {
    cmd_pitch += 0.1;
  } else if (key == 'x') {
    cmd_yaw += 0.1;
  } else if (key == 'c') {
    cmd_yaw -= 0.1;
  } else if (key == 'q') {
    w[0] += 0.01;
    w[1] += 0.01;
    w[2] += 0.01;
    w[3] += 0.01;
  } else if (key == 'z') {
    w[0] -= 0.01;
    w[1] -= 0.01;
    w[2] -= 0.01;
    w[3] -= 0.01;
  } else if (key == 'e') {
    cmd_alt = !cmd_alt;
  } else if (key == 'p') {
    pitch = 0;
    roll = 0;
    yaw = 0;
    w[0] = 0;
    w[1] = 0;
    w[2] = 0;
    w[3] = 0;
  }
}
