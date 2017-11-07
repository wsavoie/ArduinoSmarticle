#include <SoftwareSerial.h>
#include "Servo.h"
#include <string.h>
/* Pin Definitions */
#define servo1 5 //new: 10
#define servo2 6 //new: 11
#define led 13

bool diamond = true;
SoftwareSerial AS(8, 9);
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;
uint16_t const del = 500;
uint16_t const endDel = 500;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t gaitRadius = 20; //between 0 and 90 degrees
uint8_t radiusChange;
void deactivateSmarticle();
void activateForward();
void activateBackward();
void stopLoop();
int getValue(String data, char separator, int index);

void squareForward();
void squareBackward();
void diamondForward();
void diamondBackward();

void NegativeCW();
void NegativeCCW();

void PositiveCW();
void PositiveCCW();

void readFromUno();
//counter variables for automation//////////////

//maxV,gaitRadInitial,gaitIncrease,v,dir
int params[]={5,89,5,0,1};
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
  delay(4);
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
    dir = AS.read()-48; //to properly read it as a 1 digit num
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
//  squareForward();
//  diamondForward();
  NegativeCCW();
  //PositiveCW();
}
/* Moves the Smarticle backward (convention: switch on left side) */
void activateBackward() {
//  squareBackward();
//  diamondBackward();
  NegativeCW();
  //PositiveCCW();
}

void readFromUno()
{
   const char k = '_';
  char aMessage[50];
  int messageSize=0;
  
 while (AS.available() > 0)
  {
    aMessage[messageSize]= (char) AS.read();
    messageSize++;
    delay(2);
  }
    aMessage[messageSize]=0;
    
 if (messageSize>0) //if received commands from matlab
  {
    int paramNum=0;//which parameter we are saving
    int num = 0;//final value for parameter
    for(int i=0;i<messageSize;i++)
    {
      int value=aMessage[i]-48;
      if(value==47)//value for '_'-48
      {
        params[paramNum]=num;
        num = 0;
        paramNum=paramNum+1;
      }
      else
      {
        num=num*10;
        num=num+value;
      }  
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

void diamondForward()//left gait right movement
{
  S1.writeMicroseconds(maxx * 10 + 600);
  S2.writeMicroseconds((midd) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(midd * 10 + 600);
  S2.writeMicroseconds((maxx) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(minn * 10 + 600);
  S2.writeMicroseconds((midd) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(midd * 10 + 600);
  S2.writeMicroseconds((minn) * 10 + 600);
  delay(endDel);
}
void diamondBackward()//right
{
  S1.writeMicroseconds(maxx * 10 + 600);
  S2.writeMicroseconds((180-midd) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(midd * 10 + 600);
  S2.writeMicroseconds((180-maxx) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(minn * 10 + 600);
  S2.writeMicroseconds((180-midd) * 10 + 600);
  delay(del);
  S1.writeMicroseconds(midd * 10 + 600);
  S2.writeMicroseconds((180-minn) * 10 + 600);
  delay(endDel);
}
void squareForward()   //left square gait left movement
{
  int A1[] = {maxx,maxx,minn,minn};
  int A2[] = {minn,maxx,maxx,minn};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
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
void squareBackward() //right square gait right movement
{ 

  int A1[] = {maxx,maxx,minn,minn};
  int A2[] = {maxx,minn,minn,maxx};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}



void NegativeCW() //red area forward movement 
{
  
//  int A1[] = {110,100,136,170,180,180,145};
//  int A2[] = {80,70,36,0,0,10,45};
  int A1[] = {110,100,170,180,180};
  int A2[] = {80,70,0,0,10};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}

void NegativeCCW()//red area backwards movement 
{
//  int A1[] = {110,145,180,180,170,136,100};
//  int A2[] = {80,45,10,0,0,36,70};
  int A1[] = {110,180,180,170,100};
  int A2[] = {80,10,0,0,70};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}

void PositiveCW()//blue area backwards movement 
{
  int A1[] = {100,77,55,75,94,110,147,180,180,140};
  int A2[] = {80,39,0,0,38,70,89,105,125,102};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}
void PositiveCCW()//blue area forwards movement 
{
  int A1[] = {100,140,180,180,147,110,94,75,55,77};
  int A2[] = {80,102,125,105,89,70,38,0,0,39};

  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}

