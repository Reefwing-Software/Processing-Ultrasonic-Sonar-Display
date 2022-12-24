// Copyright (c) 2022 David Such
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

/**********************  
@file Sonar_Visualisation.ino  
@brief Create visual representation of a sonar sweep using Processing.  
@author David Such 
Code: David Such 
Version: 1.0  
Last edited: 04/11/18 
**********************/ 

#include < Servo.h >
#include < NewPing.h > 

// DEFINITIONS 
#define MAX_DISTANCE 30
#define MAX_ANGLE 80
#define ANGLE_STEP 1 

// PIN CONNECTIONS 
const byte TRIG_PIN = 2; 
const byte ECHO_PIN = 3; 
const byte H_SERVO = 9, V_SERVO = 10; 
const byte LED_PIN = 13; 

// GLOBALS 
int angle = 0; 
int dir = 1; 

// CREATE CLASS INSTANCES 
Servo hServo, vServo; 
NewPing sonar(TRIG_PIN, ECHO_PIN, MAX_DISTANCE); 

// METHODS 
void centre(Servo servo, int offset) { 
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); 
    servo.write(90 + offset); 
    delay(15); 
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); 
} 
void sweep(Servo servo, int min, int max) { 
    int pos = 0; 
    min = constrain(min, 0, 180); 
    max = constrain(max, min, 180); 
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); 
    for (pos = min; pos <= max; pos += 1) { 
        servo.write(pos); 
        delay(15); 
    } 
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); 
    for (pos = max; pos >= min; pos -= 1) { 
        servo.write(pos); 
        delay(15); 
    } 
} 
void sendSerialPacket(int angle, int distance) {   
    Serial.print(angle); 
    Serial.print(","); 
    Serial.println(distance); 
} 

// MAIN 
void setup() { 
    Serial.begin(115200); 
    pinMode(H_SERVO, OUTPUT); 
    pinMode(V_SERVO, OUTPUT); 
    pinMode(LED_PIN, OUTPUT); 
    digitalWrite(LED_PIN, HIGH); 
    hServo.attach(H_SERVO); 
    vServo.attach(V_SERVO); 
    centre(hServo, 0); 
    sweep(vServo, 45, 90); 
    centre(vServo, 5); 
} 

void loop() { 
    delay(40); 
    unsigned int ping_distance_cm = sonar.ping_cm();
 
    ping_distance_cm = constrain(ping_distance_cm, 0, MAX_DISTANCE);   
    sendSerialPacket(angle, ping_distance_cm); hServo.write(angle + MAX_ANGLE); 
    if (angle >= MAX_ANGLE || angle <= -MAX_ANGLE) { 
        dir = -dir; 
    } 
    angle += (dir * ANGLE_STEP); 
}