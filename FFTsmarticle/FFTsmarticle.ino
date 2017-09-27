#include <arduinoFFT.h>
#include <types.h>
#include <defs.h>

//#include <MegaServo.h>

#include <Servo.h>
//#include <avr/io.h>
//#include <avr035.h>

//#define F_CPU 8000000UL
#define myabs(n) ((n) < 0 ? -(n) : (n))

/* Pin Definitions */
#define SERVOTYPE 0 //red=0, ross=1

#if SERVOTYPE==0 //RED
  #define servo1 5//5 red//10 ross
  #define servo2 6//6 red//11 ross
#else            //ROSS
  #define servo1 10//5 red//10 ross
  #define servo2 11//6 red//11 ross
#endif
// Photoresistor reading definitions
// Based on implementation seen at:
// https://learn.sparkfun.com/tutorials/sik-experiment-guide-for-arduino---v32/experiment-6-reading-a-photoresistor
#define pr1 A5 // front PR sensor
#define pr2 A1 // back PR sensor
#define mic     A6      // CHANGE BACK TO a6
#define stressPin A3    // CHANGE BACK TO a7
#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK
#define stressMoveThresh 2

/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 1;
uint8_t stress = 0;
uint16_t samps = 9;
uint16_t const del = 400;
uint8_t stressCount = 0;
uint16_t rangeType=0;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
static uint16_t currMoveType = 8;
static int curr  = 0;
bool ledVal = false;
void stressMove(uint8_t stress);
void currentRead(uint16_t meanCurrVal);
void light(bool a);
void activateSmarticle();
void deactivateSmarticle();

double findFrequency();
void analyzeFrequency();
void entangle();
void straighten();
void performFunc(int type);
void leftSquareGait();
void rightSquareGait();
void leftDiamond();
void positiveSquare();
void zShape();
void uShape();
void nShape();


/* FFT Stuff */
arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 64;
//double samplingFrequency = 8300; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 7950; //smarticle: elapsed time ~ 8050us
//SERVONUM:            1    2    3    4    5    6    7    8
int freqCenters[8] = {600, 700, 800, 900, 1000, 1100, 1200, 1300};
int freqAcceptThresh = 50;  //+-30Hz from freqCenter is accepted
//int freqCenters[8] = {600, 650, 700, 750, 800, 850, 900, 950};
//int freqAcceptThresh = 20;  //+-30Hz from freqCenter is accepted
int freqUpperBounds[8];
int freqLowerBounds[8];
double computedFreqs[5];
double vReal[samples];
double vImag[samples];
#define SCL_INDEX 0x00
#define SCL_TIME 0x01
#define SCL_FREQUENCY 0x02
int iMax = 5;
int inertia = iMax;

int currFreq=6;

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  pinMode(led,OUTPUT);
  
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  randomSeed(analogRead(0));
  deactivateSmarticle();

  //Compute Frequency Bounds
  for (int k = 0; k < 8; k++) {
    freqUpperBounds[k] = freqCenters[k] + freqAcceptThresh;
    freqLowerBounds[k] = freqCenters[k] - freqAcceptThresh;
  }
  currFreq=6;
  //Serial.begin(9600);
}

void loop() 
{
  ledVal=false;
  double freq = findFrequency();
  analyzeFrequency(freq);
  
  /*int freqSum = 0;
  for (int k = 0; k < 5; k++) {
    computedFreqs[k] = findFrequency();
    freqSum += computedFreqs[k];
  }
  double avgFreq = freqSum/5;
  analyzeFrequency(avgFreq);*/
  
  /*int meanCurr = 0;
  for (int i = 0; i < 1<<samps; i++)
  {
    curr    = analogRead(stressPin);
    meanCurr  = meanCurr+curr;
  }
  //bitshift divide by sample, meancurr=meancurr/(2^samps)
  meanCurr >>= samps;
  currentRead(meanCurr);*/
}


/* Uses FFT analysis to calculate the dominant frequency picked up by the microphone */
double findFrequency(){
  double startTime = micros();
  for(uint16_t i =0; i<samples; i++)
  {
    vReal[i] = double(analogRead(mic));
    vImag[i] = 0;
  }
  double endTime = micros();
  double elapsedTime = endTime - startTime; //~ 7700 microseconds
  //Serial.println(elapsedTime);
  samplingFrequency = 1 / (elapsedTime/64000000); /*approximates using previous sampling frequency*/
  
  FFT.Windowing(vReal, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);  /* Weigh data */
  FFT.Compute(vReal, vImag, samples, FFT_FORWARD); /* Compute FFT */
  FFT.ComplexToMagnitude(vReal, vImag, samples); /* Compute magnitudes */
  double x = FFT.MajorPeak(vReal, samples, samplingFrequency);
  //Serial.println(x, 6);
  return x;
}

/* Determines whether or not to activate the smarticle based on frequency */
void analyzeFrequency(double freq) {
  for (int k = 0; k < 8; k++) {
//    if (freqLowerBounds[k]<freq && freq<freqUpperBounds[k] && SERVONUM == k+1) {
    if (freqLowerBounds[k]<freq && freq<freqUpperBounds[k]) 
    {
      if(k==currFreq)
      {
        if(inertia<iMax)
          {inertia++;}
          performFunc(currFreq);
          return;
      }
      inertia--;
      if (inertia <= 0)
      {
        currFreq=k;
        performFunc(currFreq);
        inertia=iMax;
      }
      return;
    }
  }
}

void performFunc(int type){
  switch(type)
  {
    case 0:
      positiveSquare();
      break;
    case 1:
      uShape();
      break;
    case 2:
      zShape();
      break;
    case 3:
      nShape();
      break;
    case 4:
      leftDiamond();
      break;
    case 5:
      leftSquareGait();
      break;
    case 6:
      rightSquareGait();
      break;
    case 7:
      straighten();
      break;     
                
    default:
      straighten();
      break;
  }
}
void uShape() {
  S1.writeMicroseconds(1500 - 900);
  S2.writeMicroseconds(1500 + 900);
  delay(del);
}
void nShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 - 900);
}
void zShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 + 900);
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
void leftSquareGait() {
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
void leftDiamond() {
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
    delay(300);
    delay(random(100));
}

void positiveSquare() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(300);
  delay(random(100));
}
void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}


void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}


void light(bool a)
{ 
  if (a)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
}


/*void currentRead(uint16_t meanCurrVal)
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

void stressMove(uint8_t stress) //break method into chunks to allow "multithreading"
{
  activateSmarticle();
  return;
}*/
