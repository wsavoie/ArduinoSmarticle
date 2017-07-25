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
//counter variables for automation//////////////

//maxV,gaitRadInitial,gaitIncrease,v,dir
int params[]={3,37,5,0,1};
int maxV = params[0];
int gaitRadInitial = params[1];
int gaitIncrease = params[2];
int v = params[3]; //run nums
int dir = params[4];
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
  AS.println("1111");
  readFromUno();
  gaitRadius = gaitRadInitial;
  minn = midd - gaitRadius;
  maxx = midd + gaitRadius;
  

}

void loop()
{ 
  if(dir==1)
    activateForward();
  else
    activateBackward();
    
  if (AS.available() > 0)
  {
    dir = atoi(AS.read());
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

void readFromUno()
{
   const char k = '_';
  char aMessage[50];
  int messageSize=0;
  
 while (Serial.available() > 0)
  {
    aMessage[messageSize]= (char) Serial.read();
    messageSize++;
  }
    aMessage[messageSize]=0;
 if (messageSize>0) //if received commands from matlab
  {
    char* command = strtok(aMessage, &k); 
    int idx=0;
    while(command!=NULL)
    {
     params[idx]=atoi(command);
     command = strtok (NULL, &k);
     idx++;
    }
    maxV=params[0];
    gaitRadInitial=params[1];
    gaitIncrease=params[2];
    v=params[3];
    dir=params[4];
        
    gaitRadius = gaitRadInitial;
    minn = midd - gaitRadius;
    maxx = midd + gaitRadius;
    }

}


