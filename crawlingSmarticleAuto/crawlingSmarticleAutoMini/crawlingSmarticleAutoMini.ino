#include <SoftwareSerial.h>
#include "Servo.h"
#include <string.h>
/* Pin Definitions */
#define servo1 5 //new: 10
#define servo2 6 //new: 11
#define led 13
SoftwareSerial AS(8, 9);
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;
uint16_t const del = 400;
uint16_t const endDel = 300;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t gaitRadius = 20; //between 0 and 90 degrees
uint8_t radiusChange;
void deactivateSmarticle();
void activateForward();
void activateBackward();
void stopLoop();
String getValue(String data, char separator, int index);
//counter variables for automation

int maxV = 10;
int gaitRadInitial = 30;
int gaitIncrease = 2;
int v = 0; //run nums
int dir = 1;
String inBuffer;
void setup() {

  AS.begin(9600);
  S1.attach(servo1, 600, 2400);
  S2.attach(servo2, 600, 2400);
  pinMode(led, OUTPUT);

  //read in maxV_gaitRadInitial_gaitIncrease_v_dir
  while(AS.available())
  {
    int inChar = Serial.read();    
  }

  deactivate();
  inBuffer="";
//  while(AS.available())
//  {
//    char c = AS.read();
//    inBuffer = inBuffer+c;
//    delay(1);
//  }
//  //maxV_gaitRadInitial_gaitIncrease_v_dir
//  if(inBuffer !="")
//  {
//    maxV = getValue(inBuffer, "_", 0).toInt();
//    gaitRadInitial = getValue(inBuffer, "_", 1).toInt();
//    gaitIncrease = getValue(inBuffer, "_", 2).toInt();
//    v = getValue(inBuffer, "_", 3).toInt();
//    dir = getValue(inBuffer, "_", 4).toInt();
//  }
  gaitRadius = gaitRadInitial;
  minn = midd - gaitRadius;
  maxx = midd + gaitRadius;
  
  delay(5000);
}

void loop()
{
  if(dir==1)
    activateForward();
  else
    activateBackward();
    
  if (AS.available() > 0)
  {
    dir = AS.read();
    v = v + 1;
    if (v > maxV)
    {
      v = 1;
      gaitRadius = gaitRadius + gaitIncrease;
      minn = midd - gaitRadius;
      maxx = midd + gaitRadius;
      
      if (gaitRadius > 90)
      {
        AS.println("end");
        stopLoop();
      }
    }
    String message = String(dir) + "_" + String(gaitRadius) + "_" + String(v);
    AS.println(message);
  }
}

/* Moves the arms parallel to the Smarticle's body */
void stopLoop()
{
  deactivate();
  while (1);
}
void deactivate() {
  S1.writeMicroseconds(p1 = 1500);
  S2.writeMicroseconds(p2 = 1500);
  delay(del);
}

/* Moves the Smarticle forward (convention: switch on left side) */
void activateForward() {
    S1.writeMicroseconds(p1 = maxx * 10 + 600);
    S2.writeMicroseconds(p2 = minn * 10 + 600);
    delay(del);
    S1.writeMicroseconds(p1 = maxx * 10 + 600);
    S2.writeMicroseconds(p2 = maxx * 10 + 600);
    delay(del);
    S1.writeMicroseconds(p1 = minn * 10 + 600);
    S2.writeMicroseconds(p2 = maxx * 10 + 600);
    delay(del);
    S1.writeMicroseconds(p1 = minn * 10 + 600);
    S2.writeMicroseconds(p2 = minn * 10 + 600);
    delay(endDel);
}

/* Moves the Smarticle backward (convention: switch on left side) */
void activateBackward() {
  S1.writeMicroseconds(p1 = maxx * 10 + 600);
  S2.writeMicroseconds(p2 = (180 - minn) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(p1 = maxx * 10 + 600);
  S2.writeMicroseconds(p2 = (180 - maxx) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(p1 = minn * 10 + 600);
  S2.writeMicroseconds(p2 = (180 - maxx) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(p1 = minn * 10 + 600);
  S2.writeMicroseconds(p2 = (180 - minn) * 10 + 600);
  delay(endDel);
}
String getValue(String data, char separator, int index)
{
    int found = 0;
    int strIndex[] = { 0, -1 };
    int maxIndex = data.length() - 1;

    for (int i = 0; i <= maxIndex && found <= index; i++) {
        if (data.charAt(i) == separator || i == maxIndex) {
            found++;
            strIndex[0] = strIndex[1] + 1;
            strIndex[1] = (i == maxIndex) ? i+1 : i;
        }
    }
    return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}
