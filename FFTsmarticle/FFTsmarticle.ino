//#include <MegaServo.h>

#include <Servo.h>
#include <avr/io.h>
#include <avr035.h>

//#define F_CPU 8000000UL
#define myabs(n) ((n) < 0 ? -(n) : (n))
//pin definitions 
#define servo1 5   //
#define servo2 6  //
#define mic     A6      // CHANGE BACK TO a6
#define stressPin A7    // CHANGE BACK TO a7

#define randPin A5    // CHANGE BACK TO a7
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
double thresh = 50; //was 12.5
uint8_t minn = 30; uint8_t maxx = 150; uint8_t midd = 90;
static uint16_t prevVal = 8;
static uint16_t currMoveType = 8;
static int oldVal  = 0;
static int newVal  = 0;
static int diff  = 0;
static int curr  = 0;
int MATCHLIM=5;
int matchCount=MATCHLIM;
int ARRAYLEN=9;
int moveMatches[] = {0,0,0,0,0,0,0,0,MATCHLIM};
int SERVONUM=3;
int nextMoveType=8;
bool ledVal = false;
void moveMotor(uint8_t pos);
void currentRead(uint16_t meanCurrVal);
void getRange(uint16_t ftVal);
int findMaxVal();
void light(bool a);

//FFT stuff
#include "arduinoFFT.h"
arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 64;
double samplingFrequency = 8300; //elapsed time ~ 7700us
double freqBounds[8] = {600, 650, 700, 750, 800, 850, 900, 950};
//SERVONUM:                 1    2    3    4    5    6    7
double vReal[samples];
double vImag[samples];
#define SCL_INDEX 0x00
#define SCL_TIME 0x01
#define SCL_FREQUENCY 0x02


void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  pinMode(led,OUTPUT);
  
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  randomSeed(analogRead(0));
}

void loop() 
{
  ledVal=false;
  /*int meanCurr = 0;
  
  for (int i = 0; i < 1<<samps; i++)
  {
    curr    = analogRead(stressPin);
    meanCurr  = meanCurr+curr;
  }

  //bitshift divide by sample, meancurr=meancurr/(2^samps)
  meanCurr >>= samps;
  currentRead(meanCurr);*/
  
  double freq = findFrequency();
  analyzeFrequency();
  
}

void currentRead(uint16_t meanCurrVal)
{
  static bool v = true;
  if(meanCurrVal<40)//make magic number into meaningful value!!
  {
    stressCount = 0;
  }
  else
  {
    stressCount++;
    if(stressCount>=stressMoveThresh && rangeType!=6 && rangeType!=7)
    {
                        v=!v;
                        light(v);
      (stress > 2 ? stress=0 : (stress++));
      moveMotor(stress);
                        //_delay_ms(del);
    } 
    //delay(del);
  }
  
}

void moveMotor(uint8_t pos) //break method into chunks to allow "multithreading"
{
  if(pos==0)
  {
    deactivateSmarticle;
  }
  else if(pos==SERVONUM) //deactivate
  {
    deactiveSmarticle();
    return;
  }
    else if(pos==8)
  {
    deactiveSmarticle();
    return;
  }
  else
  {
    activateSmarticle();
    return;
  }         

}




/* Uses FFT analysis to calculate the dominant frequency picked up by the microphone */
double findFrequency() {
  //unsigned long startTime = micros();
  for(uint16_t i =0; i<samples; i++)
  {
    vReal[i] = int(analogRead(mic));
    vImag[i] = 0;
  }
  //unsigned long endTime = micros();
  //unsigned long elapsedTime = endTime - startTime; //~ 7700 microseconds
  //samplingFrequency = 1 / (elapsedTime/64000000); /*approximates previous sampling frequency*/
  
  FFT.Windowing(vReal, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);  /* Weigh data */
  FFT.Compute(vReal, vImag, samples, FFT_FORWARD); /* Compute FFT */
  FFT.ComplexToMagnitude(vReal, vImag, samples); /* Compute magnitudes */
  double x = FFT.MajorPeak(vReal, samples, samplingFrequency);
  //Serial.println(x, 6);
  return x;
}


void analyzeFrequency(double freq) {
  if (freq > 1000) {
    deactivateSmarticle();
    return;
  }
  
  for (int k = 0; k < 7; k++) {
    if (bounds[k]<freq && freq>bounds[k+1] && SERVONUM == k+1) {
      deactiveSmarticle();
      return;
    }
  }
  activateSmarticle();
}



void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
}

void activateSmarticle() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(300);
  delay(random(100));
}

void light(bool a)
{ 
  if (a)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
}
