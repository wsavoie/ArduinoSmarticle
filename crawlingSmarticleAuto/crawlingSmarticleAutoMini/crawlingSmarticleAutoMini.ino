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
int getValue(String data, char separator, int index);
void readFromUno();
//counter variables for automation
char d = '_';//delimiter
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

  deactivate();
  delay(2000);
//  inBuffer="";
// //read in maxV_gaitRadInitial_gaitIncrease_v_dir
//  while(AS.available())
//  {
//    char c = AS.read();
//    inBuffer = inBuffer+c;
//    delay(1);
//  }
//  //maxV_gaitRadInitial_gaitIncrease_v_dir
//  if(inBuffer !="")
//  {
//    char k='_';
//    maxV = getValue(inBuffer, k, 1);
//    gaitRadInitial = getValue(inBuffer, k, 2);
//    gaitIncrease = getValue(inBuffer, k, 3);
//    v = getValue(inBuffer, k, 4);
//    dir = getValue(inBuffer, k, 5);
//  }
  readFromUno();
  gaitRadius = gaitRadInitial;
  minn = midd - gaitRadius;
  maxx = midd + gaitRadius;
  

}

void loop()
{
  if(AS.available()>5)
  {
    readFromUno();
     
     
  }
 
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
int getValue(String data, char separator, int index)
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
    String a = found > index ? data.substring(strIndex[0], strIndex[1]) : "";
    return a.toInt();
}
void readFromUno()
{
   String inBuff="";
    while(AS.available())
    {
      char c = (char)AS.read();
      inBuff = inBuff+c;
      delay(200);
    }
    if(inBuffer !="")
    {
    char k='_';
    maxV = getValue(inBuffer, k, 0);
    gaitRadInitial = getValue(inBuffer, k, 1);
    gaitIncrease = getValue(inBuffer, k, 2);
    v = getValue(inBuffer, k, 3);
    dir = getValue(inBuffer, k, 4);
    
    gaitRadius = gaitRadInitial;
    minn = midd - gaitRadius;
    maxx = midd + gaitRadius;
    }

}


