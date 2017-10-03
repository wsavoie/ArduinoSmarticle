/**
Written by Will Savoie
Modified by Ross Warkentin on 05/01/2017
Modified by Shea Wells on 05/16/2017

Code for Smarticles running on an Arduino Pro Mini
**/

#include <Servo.h>
#include <avr/io.h>
#include <avr035.h>

//#define F_CPU 8000000UL
#define myabs(n) ((n) < 0 ? -(n) : (n))

//pin definitions 
#define servo1 10   //
#define servo2 11  //

// Photoresistor reading definitions
// Based on implementation seen at:
// https://learn.sparkfun.com/tutorials/sik-experiment-guide-for-arduino---v32/experiment-6-reading-a-photoresistor
#define pr1 A5 // front PR sensor
#define pr2 A1 // back PR sensor

#define mic     A2      // CHANGE BACK TO a6
#define stressPin A3    // CHANGE BACK TO a7

#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK

Servo S1;
Servo S2;
uint8_t minn = 0; // low end of servo actuating range
uint8_t maxx = 180; // high end of servo actuating range
uint8_t midd = 90; // middle of servo actuating range

uint8_t stress = 0;
uint8_t stressCount = 0;
uint8_t stressMoveThresh=2;
uint16_t samps = 9; 

uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;

double thresh = 12.5;

static uint16_t currMoveType = 0;
static int diff  = 0;
static int curr  = 0;
static bool lightVal=false;

static bool lightSmarticleActive=false;

// Parameters for the photoresistors
// Standards are:
// static int lightThresh1 = 520;
// static int lightThresh2 = 800;

static int lightLevel1 = 0;
static int lightLevel2 = 0;
static int lightThresh1 = 255;
static int lightThresh2 = 255;

//this gives inertia different values for gait vs straight
int iMax=5 ;
int iOn = 2; //inertia max
int iOff = -5; //inertia min
int lightInertia = iOn;
int inertia = iMax;

int MATCHLIM=5;
int matchCount=MATCHLIM;
int ARRAYLEN=9;
int moveMatches[] = {0,0,0,0,0,0,0,0,MATCHLIM};
int SERVONUM=0;
int nextMoveType=8;
bool ledVal = false;
void moveMotor(uint8_t pos);
void currentRead(uint16_t meanCurrVal);
void getRange(uint16_t ftVal);
int findMaxVal();
void light(bool a);
void straighten();
void rightSquareGait();



void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  pinMode(led,OUTPUT);
  
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  randomSeed(analogRead(0));
  
  int midPtCross;
  int meanCurr;
}

void loop() {          
  
  ledVal = false;
  int meanCurr = 0;
  

  analyzeLight();
  
//  // Poll the current sensor and mic
//  for (int i = 0; i < 1<<samps; i++){
//    curr = analogRead(stressPin);
//    meanCurr = meanCurr+curr;
//  }
//  //bitshift divide by sample, meancurr=meancurr/(2^samps)
//  meanCurr >>= samps;
//  currentRead(meanCurr);
  
//  if(stressCount<stressMoveThresh || rangeType==6 || rangeType==7) //if previous moves were 6 or 7, continue without stress
//  {
//    moveMotor(3); //3 is a rangetype which will perform gait motion
//  }
  
}
void analyzeLight()
{
  // Get the light levels from the voltage dividers
  lightLevel1 = analogRead(pr1);
  lightLevel2 = analogRead(pr2);
  
  // High readings are associated with light exposure
  if (lightLevel1>lightThresh1 || lightLevel2>lightThresh2)
  { // If the light exposure one either sensor is high
    lightInertia>=iOn ? lightInertia=iOn : lightInertia++; 
    if(lightInertia>=0)
    {
      currMoveType=1;
      if(lightInertia==0)
      {lightInertia=iOn;}
    }
  }
  else
  { // If the light exposure one either sensor is high
      lightInertia<=iOff ? lightInertia=iOff : lightInertia--;
      if(lightInertia<=0)
      {
        currMoveType=0;
        if(lightInertia==0)
        {lightInertia=iOff;}
      }
  }
//  performFunc(currMoveType);
    performFunc(currMoveType);
}
void currentRead(uint16_t meanCurrVal){
  static bool v = true;
  if(meanCurrVal<40){//make magic number into meaningful value!!
    stressCount = 0;
  }
  else {
    stressCount++;
    if(stressCount>=stressMoveThresh && currMoveType!=6 && currMoveType!=7){
      v=!v;
      light(v);
      (stress > 2 ? stress=0 : (stress++));
      moveMotor(stress);
                        //_delay_ms(del);
    } 
    //delay(del);
  }
}


//// "On standard servos a parameter value of 1000 is fully counter-clockwise, 2000 is fully clockwise, and 1500 is in the middle."
//void moveMotor(uint8_t pos){ //break method into chunks to allow "multithreading"
//  
//  static int oldP1 = 1500;
//  static int oldP2 = 1500;
//  static int p1 = 1500;
//  static int p2 = 1500;
//  static bool v = false;
//  
//  // If certain conditions are met such that we do not want the servos to perform the normal gait
//  
//  // If we want the lit smarticle to perform a gait that is specific to the PR1 sensor, put it in this if-statement
//  // remember to set lightSmarticleActive to true
//  if(lightSmarticleActive && (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel1>lightThresh1)){ // front sensor
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=minn * 10 + 600);
//    S2.writeMicroseconds(p2=maxx * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=1500);
//    S2.writeMicroseconds(p2=1500);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=minn * 10 + 600);
//    S2.writeMicroseconds(p2=maxx * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=1500);
//    S2.writeMicroseconds(p2=1500);
//    delay(300);
//    delay(random(100));
//    return;
//  }
//  
//  // If we want the lit smarticle to perform a gait that is specific to the PR2 sensor, put it in this if-statement
//  // remember to set lightSmarticleActive to true
//  else if(lightSmarticleActive && (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel2>lightThresh2)){ // back sensor
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=maxx * 10 + 600);
//    S2.writeMicroseconds(p2=minn * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=1500);
//    S2.writeMicroseconds(p2=1500);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=maxx * 10 + 600);
//    S2.writeMicroseconds(p2=minn * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=1500);
//    S2.writeMicroseconds(p2=1500);
//    delay(300);
//    delay(random(100));
//    return;
//  }
//  
//  // If we want the lit smarticle to simply become inactive,set lightSmarticleActive to false and this if-statement will execute when
//  // either of the PR sensors are above the lightThresh value
//  else if (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel1>lightThresh1 || lightLevel2>lightThresh2){
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=1500);
//    S2.writeMicroseconds(p2=1500);
//    return;
//  }
//  
//  // If nothing else, perform normal gait
//  else{
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=maxx * 10 + 600);
//    S2.writeMicroseconds(p2=minn * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=maxx * 10 + 600);
//    S2.writeMicroseconds(p2=maxx * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=minn * 10 + 600);
//    S2.writeMicroseconds(p2=maxx * 10 + 600);
//    delay(del);   
//    oldP1=p1;
//    oldP2=p2;
//    S1.writeMicroseconds(p1=minn * 10 + 600);
//    S2.writeMicroseconds(p2=minn * 10 + 600);
//    delay(300);
//    delay(random(100));
//    return;
//  }
//  return; 
//}


void light(bool a){ 
  if (a)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
}
void performFunc(int type){
  switch(type)
  {
    case 0:
      rightSquareGait();
      break;
    case 1:
      straighten();
      break;  
    default:
      straighten();
      break;
  }
}


void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}
void rightSquareGait() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(300);
  delay(random(100));
}
