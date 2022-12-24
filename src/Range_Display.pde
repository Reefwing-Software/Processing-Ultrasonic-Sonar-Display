/**********************
 @file    Range_Display.pde
 @brief   Create visual representation of a HC_SR04 Ultrasonic sensor via an Arduino and using Processing.
 @author  David Such
 
 Code:        David Such
 Version:     1.0 
 Last edited: 10/12/18
 **********************/
 
 import processing.serial.*;
 
 //  CONSTANTS

final color BLACK = color(0);
final color GREY = color(65);
final color WHITE = color(255);
final color DARK_GREY = color(32, 32, 32);
final color RED = color(255, 0, 0);
final color GREEN = color(0, 255, 0);
final color YELLOW = color(255, 255, 0);
final color ORANGE = color(255, 165, 0);
final color TEXT_GREEN = color(0, 300, 0);
final color SWEEP_GREEN = color(0, 153, 0, 125);
final color SWEEP_BLACK = color(0, 0, 0, 125);
final color SWEEP_ORANGE = color(255, 165, 0, 125);

final int GRAPH_WIDTH = 630;
final int GRAPH_HEIGHT = 480;
final int RIGHT_COL_X = 740;

final int MAX_RANGE = 30;  //  Should be equal to max distance in Arduino sketch - used to scale to screen co-ords.
final int MAX_ANGLE = 180;
final int MAX_OBJECTS = 200;

final int Y_AXIS = 1;
final int X_AXIS = 2;

final Point GRAPH_ORIGIN = new Point(70, 10);

final String PORT_MAC = "/dev/cu.usbmodem1421";
final String PORT_RPi = "/dev/ttyACM0";

//  GLOBALS

float lastAngle = 0;
float lastFrameRate = 30.0;
int angle, range;
Serial port;
Point[] objects;

//  METHODS

int normaliseAngle(int theta) {
  //  Servo operates from -90 degrees to +90 degrees
  //  Straight ahead for the servo is 0 degress.
  //  The processing display represents this as 0 to 180 degrees.
  //  90 degrees on the graph is straight ahead for the servo.
  
  return theta + 90;
}

void shiftObjectsArray() {
 
  for (int i = MAX_OBJECTS; i > 1; i--) {
 
    Point oldPoint = objects[i-2];
    if (oldPoint != null) {
 
      Point point = new Point(oldPoint.x, oldPoint.y);
      objects[i-1] = point;
    }
  }
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}

void drawGraph() {
  stroke(ORANGE);
  noFill();
  
  //  Draw Border
  strokeWeight(3);
  rectMode(CENTER);
  rect(width/2, height/2, width-1, height);
  strokeWeight(1);
  
  //  Draw Graph Border
  rectMode(CORNER);
  rect(GRAPH_ORIGIN.x, GRAPH_ORIGIN.y, GRAPH_WIDTH, GRAPH_HEIGHT);
  
  //  Draw Info Box
  rect(GRAPH_ORIGIN.x + GRAPH_WIDTH + 10, GRAPH_ORIGIN.y, 250, GRAPH_HEIGHT);
  
  //  Draw Range Tick Marks
  for (int y = GRAPH_ORIGIN.y + GRAPH_HEIGHT; y > GRAPH_ORIGIN.y; y -= 50) {
    stroke(WHITE);
    line(GRAPH_ORIGIN.x - 5, y, GRAPH_ORIGIN.x + 5, y);
    
    stroke(ORANGE);
    for (int i = 0; i <= 50; i++) {
      float px = lerp(GRAPH_ORIGIN.x + 5, GRAPH_ORIGIN.x + GRAPH_WIDTH, i/50.0);
      float py = lerp(y, y, i/50.0);
 
      point(px, py);
    }
  }
  
  //  Draw Angle Tick Marks
  stroke(WHITE);
  int tickNum = GRAPH_WIDTH/18;
  for (int x = GRAPH_ORIGIN.x + tickNum; x <= GRAPH_ORIGIN.x + GRAPH_WIDTH; x += tickNum) {
    line(x, GRAPH_ORIGIN.y + GRAPH_HEIGHT - 5, x, GRAPH_ORIGIN.y + GRAPH_HEIGHT + 5);
  }
  
}

void drawText(int angleDegrees) {
  noStroke();
  fill(WHITE);
  text("ANGLE", GRAPH_ORIGIN.x + GRAPH_WIDTH/2 - 50, GRAPH_ORIGIN.y + GRAPH_HEIGHT + 50);
  
  //  Print out angle labels on x-axis
  int tickNum = GRAPH_WIDTH/18;
  int px = GRAPH_ORIGIN.x - 10;
  int py = GRAPH_ORIGIN.y + GRAPH_HEIGHT + 25;
  
  for (int ax = 10; ax <= MAX_ANGLE; ax += 10) {
    px += tickNum;
    text(Integer.toString(ax), px, py);
  }
  
  //  Print out rangle labels on y-axis
  int range_label = 0;
  
  for (int ry = GRAPH_ORIGIN.y + GRAPH_HEIGHT; ry > GRAPH_ORIGIN.y; ry -= 50) {
    text(range_label, GRAPH_ORIGIN.x - 30, ry);
    range_label += 5;
  }
  
  float rangeScaled = (180 * range) / 300;
  String rangeText = Integer.toString(range);
  
  if (range < 0) {
    rangeText = Integer.toString(MAX_RANGE * 10);  // Max range in mm
    rangeScaled = 180;
  }
  
  if (frameCount % 10 == 0) lastFrameRate = frameRate;
  text("Frame Rate: " + nf(lastFrameRate, 2, 1), RIGHT_COL_X, 280);
  
  text("Angle: " + Integer.toString(angleDegrees), RIGHT_COL_X, 350, 100, 50);   
  text("degree", RIGHT_COL_X + 80, 350, 100, 50);   
  
  text("Range: " + rangeText, RIGHT_COL_X, 420, 100, 30);  
  text("mm", RIGHT_COL_X + 80, 420, 100, 50);
  
  fill(ORANGE);
  text("Reefwing Robotics reefwingrobotics.blogspot.com", RIGHT_COL_X, 30, 250, 50);
  
  //  Draw angle and range bar graphs
  rect(RIGHT_COL_X, 370, angleDegrees, 10);                    //  Angle Bar Graph
  
  setGradient(RIGHT_COL_X, 440, 180, 10, RED, GREEN, X_AXIS);  //  Range Bar Graph Background
  fill(BLACK);
  stroke(BLACK);
  rect(RIGHT_COL_X + rangeScaled, 440, 180 - rangeScaled, 10);
  
  int x = 10;
  int y = GRAPH_ORIGIN.y + GRAPH_HEIGHT/2 - 10;
  
  fill(WHITE);
  pushMatrix();
  translate(x, y);
  rotate(HALF_PI);
  translate(-x, -y);
  text("RANGE (cm)", x, y);
  popMatrix();
}

void drawSweep(int angleDegrees) {
  
  float hysteresis = 0.5;
  int oneDegree = GRAPH_WIDTH/180;
  int inc = oneDegree * angleDegrees;
  
  if (angleDegrees > lastAngle) {
    setGradient(GRAPH_ORIGIN.x + inc, GRAPH_ORIGIN.y, oneDegree * 10, GRAPH_HEIGHT, SWEEP_BLACK, SWEEP_ORANGE, X_AXIS);
    lastAngle = angleDegrees - hysteresis;
  }
  else {
    setGradient(GRAPH_ORIGIN.x + inc, GRAPH_ORIGIN.y, oneDegree * 10, GRAPH_HEIGHT, SWEEP_ORANGE, SWEEP_BLACK, X_AXIS);
    lastAngle = angleDegrees + hysteresis;
  }
}

void drawObjects(int angleDegrees, int dist) {
  if (dist > 0 && dist < 300) {
    int oneDegree = GRAPH_WIDTH/180;
    int px = GRAPH_ORIGIN.x + (oneDegree * angleDegrees);
    int py = GRAPH_ORIGIN.y + GRAPH_HEIGHT - dist;            // 1 mm = 1 pixel      
    
    objects[0] = new Point(px, py);
  }
  else {
    objects[0] = new Point(0, 0);
  }
  
  for (int i = 0; i < MAX_OBJECTS; i++) {
 
    Point point = objects[i];
  
    if (point != null) {
 
      int x = point.x;
      int y = point.y;
 
      if (x == 0 && y == 0) continue;
 
      int alpha = (int)map(i, 0, MAX_OBJECTS, 20, 0);
      int size = (int)map(i, 0, MAX_OBJECTS, 30, 5);
 
      fill(255, 165, 0, alpha);
      noStroke();
      ellipse(x, y, size, size);
    }
  }
  
  shiftObjectsArray();
}
  
//  MAIN

void setup() {
  size(1000, 550, P2D);    // Set size of window and assign Processing 2D graphics renderer.
  objects = new Point[MAX_OBJECTS];
  port = new Serial(this, PORT_MAC, 115200);  // Open Serial Port
  port.bufferUntil('\n'); // End of packet is indicated by a newline char
}

void draw() {
  background(DARK_GREY);
  drawSweep(normaliseAngle(angle));
  drawGraph();
  drawText(normaliseAngle(angle));
  drawObjects(normaliseAngle(angle), range);
}

void serialEvent(Serial eventPort) {
 
  String packet = eventPort.readStringUntil('\n');
  if (packet != null) {
    packet = trim(packet);
    String[] values = split(packet, ',');
    
    try {
      angle = Integer.parseInt(values[0]);
      range = int(map(Integer.parseInt(values[1]), 1, MAX_RANGE, 1, height));   
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}