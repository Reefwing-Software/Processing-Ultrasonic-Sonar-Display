/**********************
 @file    Sonar_Display.pde
 @brief   Create visual representation of a HC_SR04 Ultrasonic sensor via an Arduino and using Processing.
 @author  David Such
 
 Code:        David Such
 Version:     1.1 
 Last edited: 15/12/18
 **********************/

import processing.serial.*;

//  CONSTANTS

final color GREY = color(65);
final color DARK_GREY = color(32, 32, 32);
final color GREEN = color(0, 255, 0);
final color WHITE = color(255, 255, 255);
final color YELLOW = color(255, 255, 0);
final color TEXT_GREEN = color(0, 300, 0);
final color SWEEP_GREEN = color(0, 153, 0, 125);

final int MAX_ANGLE = 80;
final int MAX_OBJECTS = 200;
final int MAX_RANGE = 30;  //  Should be equal to max distance in Arduino sketch - used to scale to screen co-ords.

final float START_ANGLE = radians(-MAX_ANGLE) - HALF_PI;
final float STOP_ANGLE = radians(MAX_ANGLE) - HALF_PI;

final String PORT_MAC = "/dev/cu.usbmodem1421";
final String PORT_RPi = "/dev/ttyACM0";

//  GLOBALS

int angle, range;
Serial port;
Point radarOrigin;
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

void drawRadarScreen() {
  stroke(GREEN);
  noFill();
  
  //  Draw Border
  strokeWeight(3);
  rect(width/2, height/2, width-1, height);
  strokeWeight(1);
  
  //  Draw 5 semi-circular arcs
  for (int i = 0; i <= 5; i++) {
    arc(radarOrigin.x, radarOrigin.y, 200 * i, 200 * i, START_ANGLE, STOP_ANGLE);
  }
  
  //  Draw grid lines and angles
  for (int i = 0; i <= 6; i++) {
    stroke(GREEN);
    line(radarOrigin.x, radarOrigin.y, radarOrigin.x + cos(radians(180+(30*i)))*radarOrigin.x, radarOrigin.y + sin(radians(180+(30*i)))*radarOrigin.y);
    
    noStroke();
    fill(WHITE);
    text(Integer.toString(0+(30*i)), radarOrigin.x + cos(radians(180+(30*i)))*radarOrigin.x, radarOrigin.y + sin(radians(180+(30*i)))*radarOrigin.y, 25, 50);
  }
} 

void drawText(int angleDegrees) {
  noStroke();
  noFill();
  
  String rangeText = Integer.toString(range);
  
  if (range < 0) rangeText = Integer.toString(MAX_RANGE * 10);  // Max range in mm
  
  text(" Angle: " + Integer.toString(angleDegrees), 100, 460, 100, 50);   
  text("degree", 200, 460, 100, 50);      
  text("Range: " + rangeText, 100, 480, 100, 30);  
  text("mm", 200, 490, 100, 50);       
  
  fill(TEXT_GREEN);
  text("Reefwing Robotics reefwingrobotics.blogspot.com", 900, 480, 250, 50);
  text("50 mm", 600, 420, 250, 50);
  text("100 mm", 600, 320, 250, 50);
  text("150 mm", 600, 220, 250, 50);
  text("200 mm", 600, 120, 250, 50);
  text("250 mm", 600, 040, 250, 50);
   
  text("Range Key:", 100, 50, 150, 50);
  text("Far", 115, 70, 150, 50);
  text("Near", 115, 90, 150, 50);
  text("Close", 115, 110, 150, 50);
  
  fill(0,50,0);
  rect(30,53,10,10);
  
  fill(0,110,0);
  rect(30,73,10,10);
  
  fill(0,170,0);
  rect(30,93,10,10);
}

void drawSweep(int theta) {  
  fill(SWEEP_GREEN); 
  arc(radarOrigin.x, radarOrigin.y, width, width, radians(theta-100), radians(theta-90));
}

void drawObjects(int theta, int dist) {
 
  if (dist > 0) {
    float thetaRadians = radians(theta);
    float px = radarOrigin.x + (dist * sin(thetaRadians));
    float py = radarOrigin.y - (dist * cos(thetaRadians));
 
    objects[0] = new Point((int)px, (int)py);
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
 
      fill(0, 255, 0, alpha);
      noStroke();
      ellipse(x, y, size, size);
    }
  }
  
 shiftObjectsArray();
}

//  MAIN

void setup() {
  size(1000, 500, P2D);    // Set size of window and assign Processing 2D graphics renderer.
  rectMode(CENTER);
  objects = new Point[MAX_OBJECTS];
  radarOrigin = new Point(width / 2, height);
  port = new Serial(this, PORT_MAC, 115200);  // Open Serial Port
  port.bufferUntil('\n'); // End of packet is indicated by a newline char
}

void draw() {
  background(DARK_GREY);
  drawRadarScreen();
  drawText(normaliseAngle(angle));
  drawSweep(angle);
  drawObjects(angle, range);
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