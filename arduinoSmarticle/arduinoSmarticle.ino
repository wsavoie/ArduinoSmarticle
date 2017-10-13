/**
Written by Will Savoie
Modified by Ross Warkentin on 05/01/2017
Modified by Shea Wells on 05/16/2017

Code for Smarticles running on an Arduino Pro Mini
**/

//#include <MegaServo.h>


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
#define stressMoveThresh 2

Servo S1;
Servo S2;
int silenceCount = 0;
uint8_t stress = 0;
uint16_t samps = 9; 
uint16_t micMean = 512;
uint16_t const del = 400;
uint8_t stressCount = 0;
uint16_t rangeType=0;
double thresh = 12.5;
uint8_t minn = 0; // low end of servo actuating range
uint8_t maxx = 180; // high end of servo actuating range
uint8_t midd = 90; // middle of servo actuating range
static uint16_t prevVal = 8;
static uint16_t currMoveType = 8;
static int oldVal  = 0;
static int newVal  = 0;
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
  int midPtCross = 0;
  int meanCurr = 0;
  oldVal = 0;
  
  // Get the light levels from the voltage dividers
  lightLevel1 = analogRead(pr1);
  lightLevel2 = analogRead(pr2);
  
  // High readings are associated with light exposure
  if (lightLevel1>lightThresh1 || lightLevel2>lightThresh2){ // If the light exposure one either sensor is high
    ledVal=true;
    light(ledVal);
  }
  else { // if neither sensor has a light level above the necessary threshold
    light(ledVal);
  }
  
  // Poll the current sensor and mic
  for (int i = 0; i < 1<<samps; i++){
    oldVal = newVal;
    curr = analogRead(stressPin);
    newVal = analogRead(mic);

    meanCurr = meanCurr+curr;
    int aa= newVal > micMean;
    int bb= oldVal > micMean;
    diff = (newVal > micMean) - (oldVal > micMean);
    diff = aa - bb;
    diff = myabs(diff);        
  
    midPtCross = midPtCross + diff;       
  }
  
  //Serial.print(midPtCross);    // prints a tab
  //bitshift divide by sample, meancurr=meancurr/(2^samps)
  meanCurr >>= samps;
  currentRead(meanCurr);
  
  if(stressCount<stressMoveThresh || rangeType==6 || rangeType==7) //if previous moves were 6 or 7, continue without stress
  {
    //if using microphone use below line
    //getRange(midPtCross);         
    //for non-mic system:
    moveMotor(3); //3 is a rangetype which will perform gait motion
  }
  //light(ledVal);
        
  //delay(del);
}

void currentRead(uint16_t meanCurrVal){
  static bool v = true;
  if(meanCurrVal<40){//make magic number into meaningful value!!
    stressCount = 0;
  }
  else {
    stressCount++;
    if(stressCount>=stressMoveThresh && rangeType!=6 && rangeType!=7){
      v=!v;
      light(v);
      (stress > 2 ? stress=0 : (stress++));
      moveMotor(stress);
                        //_delay_ms(del);
    } 
    //delay(del);
  }
}

void getRange(uint16_t ftVal){// at thresh = 50, thresh = 216-433-650

  bool a = false;
  static bool v = false;
  rangeType=0;
       //range freq = [50hz*rangeType, 50hz*(rangeType+1)] 
  if (ftVal < thresh*2)                            
    rangeType = 1;
  else if ((ftVal>=2*thresh) && (ftVal<3*thresh))//216-433
    rangeType = 2;
  else if ((ftVal>=3*thresh) && (ftVal<4*thresh))//433-650
    rangeType = 3;
  else if ((ftVal>=4*thresh) && (ftVal<5*thresh))//433-650
    rangeType = 4;
  else if ((ftVal>=5*thresh) && (ftVal<6*thresh))//433-650
    rangeType = 5;
  else if ((ftVal>=6*thresh) && (ftVal<7*thresh))//433-650
    rangeType = 6;
  else if ((ftVal>=7*thresh) && (ftVal<8*thresh))//433-650
    rangeType = 7;
  else
    rangeType = 8;


//currMoveType=findMaxVal();
//moveMotor(currMoveType);

  if (rangeType != currMoveType) { 
    prevVal = rangeType;
    matchCount--;
    if(matchCount<0) {
      matchCount=0;
      currMoveType=rangeType;
    }
    return;
    moveMotor(currMoveType);
//    return;
  }
  matchCount++;
  matchCount=matchCount%MATCHLIM;
  
//  if(matchCount < 5 )
//  {
//
//    moveMotor(currMoveType);
//    prevVal = rangeType;
//    return;
//  }l
//  
  prevVal = rangeType;
  //currMoveType=rangeType;
  moveMotor(currMoveType);
}

// "On standard servos a parameter value of 1000 is fully counter-clockwise, 2000 is fully clockwise, and 1500 is in the middle."
void moveMotor(uint8_t pos){ //break method into chunks to allow "multithreading"
  
  static int oldP1 = 1500;
  static int oldP2 = 1500;
  static int p1 = 1500;
  static int p2 = 1500;
  static bool v = false;
  
  // If certain conditions are met such that we do not want the servos to perform the normal gait
  
  // If we want the lit smarticle to perform a gait that is specific to the PR1 sensor, put it in this if-statement
  // remember to set lightSmarticleActive to true
  if(lightSmarticleActive && (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel1>lightThresh1)){ // front sensor
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=minn * 10 + 600);
    S2.writeMicroseconds(p2=maxx * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=1500);
    S2.writeMicroseconds(p2=1500);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=minn * 10 + 600);
    S2.writeMicroseconds(p2=maxx * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=1500);
    S2.writeMicroseconds(p2=1500);
    delay(300);
    delay(random(100));
    return;
  }
  
  // If we want the lit smarticle to perform a gait that is specific to the PR2 sensor, put it in this if-statement
  // remember to set lightSmarticleActive to true
  else if(lightSmarticleActive && (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel2>lightThresh2)){ // back sensor
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=maxx * 10 + 600);
    S2.writeMicroseconds(p2=minn * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=1500);
    S2.writeMicroseconds(p2=1500);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=maxx * 10 + 600);
    S2.writeMicroseconds(p2=minn * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=1500);
    S2.writeMicroseconds(p2=1500);
    delay(300);
    delay(random(100));
    return;
  }
  
  // If we want the lit smarticle to simply become inactive,set lightSmarticleActive to false and this if-statement will execute when
  // either of the PR sensors are above the lightThresh value
  else if (pos==0 || pos==SERVONUM ||  pos==8 || lightLevel1>lightThresh1 || lightLevel2>lightThresh2){
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=1500);
    S2.writeMicroseconds(p2=1500);
    return;
  }
  
  // If nothing else, perform normal gait
  else{
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=maxx * 10 + 600);
    S2.writeMicroseconds(p2=minn * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=maxx * 10 + 600);
    S2.writeMicroseconds(p2=maxx * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=minn * 10 + 600);
    S2.writeMicroseconds(p2=maxx * 10 + 600);
    delay(del);   
    oldP1=p1;
    oldP2=p2;
    S1.writeMicroseconds(p1=minn * 10 + 600);
    S2.writeMicroseconds(p2=minn * 10 + 600);
    delay(300);
    delay(random(100));
    return;
  }
  return; 
}

int findMaxVal() {
  int maxVal=0;
  int maxInd=0;
  int rv = rangeType;
  if(rv != 0 || rv != SERVONUM|| rv!= 8)
  {rv=1;}
  
   moveMatches[rv]=moveMatches[rv]+2;
  for(int i = 0; i < ARRAYLEN ; i++)
  {   
      moveMatches[i]=moveMatches[i]-1;
      if(moveMatches[i] < 0)
      {
        moveMatches[i]=0;
      }
      maxVal=max(moveMatches[i],maxVal);
      if(maxVal==moveMatches[i])
      {maxInd=i;}
  }
  return maxInd;
}

void light(bool a){ 
  if (a)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
}

//switch (pos)
//{ ///1500 = straight out, my 0 degrees servo's 90 degrees
//    case 0:
//          S1.writeMicroseconds(1500);
//          S2.writeMicroseconds(1500);
//          break;
//    case 1:
//          S1.writeMicroseconds(1500 - 300);
//          S2.writeMicroseconds(1500 + 300);
//          break;
//    case 2:
//          S1.writeMicroseconds(1500 + 300);
//          S2.writeMicroseconds(1500 - 300);
//          break;
//    case 3:
//          S1.writeMicroseconds(1500 - 900);
//          S2.writeMicroseconds(1500 + 900);
//          break;
//    case 4:
//          S1.writeMicroseconds(1500 + 900);
//          S2.writeMicroseconds(1500 - 900);
//          break;
//    case 5:
//          S1.writeMicroseconds(1500 + 900);
//          S2.writeMicroseconds(1500 + 900);
//          break;
//    case 6:
//          S1.writeMicroseconds(maxx * 10 + 600);
//          S2.writeMicroseconds((minn) * 10 + 600);
//          _delay_ms(del*2);
//    
//          S1.writeMicroseconds(maxx * 10 + 600);
//          S2.writeMicroseconds((maxx) * 10 + 600);
//          _delay_ms(del*2);
//    
//          S1.writeMicroseconds(minn * 10 + 600);
//          S2.writeMicroseconds((maxx) * 10 + 600);
//          _delay_ms(del*2);
//    
//          S1.writeMicroseconds(minn * 10 + 600);
//          S2.writeMicroseconds((minn) * 10 + 600);
//           _delay_ms(del);
//          break;
//    case 7:
//          //S1.writeMicroseconds(maxx * 10 + 600);
//          //S2.writeMicroseconds((midd) * 10 + 600);
//          //_delay_ms(del);
//          //S1.writeMicroseconds(midd * 10 + 600);
//          //S2.writeMicroseconds((maxx) * 10 + 600);
//          //_delay_ms(del);
//          //S1.writeMicroseconds(minn * 10 + 600);
//          //S2.writeMicroseconds((midd) * 10 + 600);
//          //_delay_ms(del);
//          //S1.writeMicroseconds(midd * 10 + 600);
//          //S2.writeMicroseconds((minn) * 10 + 600);
//          //_delay_ms(del);
//          //S1.writeMicroseconds(maxx * 10 + 600);
//          //S2.writeMicroseconds((midd) * 10 + 600);
//          
//          
//          S1.writeMicroseconds(maxx * 10 + 600);
//          S2.writeMicroseconds((midd) * 10 + 600);
//          _delay_ms(del);
//          S1.writeMicroseconds(midd * 10 + 600);
//          S2.writeMicroseconds((midd) * 10 + 600);
//          _delay_ms(del);
//          S1.writeMicroseconds(midd * 10 + 600);
//          S2.writeMicroseconds((minn) * 10 + 600);
//          _delay_ms(del);
//          S1.writeMicroseconds(maxx * 10 + 600);
//          S2.writeMicroseconds((minn) * 10 + 600);
//          _delay_ms(del/2);
//          S1.writeMicroseconds(maxx * 10 + 600);
//          S2.writeMicroseconds((midd) * 10 + 600);
//          
//          //_delay_ms(del/2);
//          break;
//    case 8:
//          S1.writeMicroseconds(1500);
//          S2.writeMicroseconds(1500);
//          break;



