#include <arduinoFFT.h>
#include <types.h>
#include <defs.h>
#include <Servo.h>

//#define F_CPU 8000000UL
#define SCL_INDEX 0x00
#define SCL_TIME 0x01
#define SCL_FREQUENCY 0x02


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


#define mic     A6      // CHANGE BACK TO a6
#define stressPin A7    // CHANGE BACK TO orig a7 or a3
#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK

/*Stress related vars*/
int stressMoveThresh = 9;
uint8_t stressCount = 0;
static int curr  = 0;
bool stress = false;
uint16_t samps = 10; 

/*current inertia*/
int ciMax = 2; //current inertia max
int cInertia = ciMax;

/*Servo pins*/
Servo S1;
Servo S2;
const int SERVONUM = 1;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;

bool ledVal = false;


/* FFT Stuff */
arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 64;
int const fN= 10; //number of frequencies
int currFreq=6;
//double samplingFrequency = 8300; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 7950; //smarticle: elapsed time ~ 8050us
int freqCenters[fN] = {600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500};
int freqAcceptThresh = 50;  //+-30Hz from freqCenter is accepted
int freqUpperBounds[fN];
int freqLowerBounds[fN];
double computedFreqs[5];
double vReal[samples];
double vImag[samples];


/*frequency inertia*/
int iMax = 5; //inertia max
int inertia = iMax;





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
void rightDiamond();
void positiveSquare();
void negativeSquare();
void zShape();
void uShape();
void nShape();
void rightSquareGaitCS();
void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  pinMode(led,OUTPUT);
  
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  randomSeed(analogRead(randPin));
  deactivateSmarticle();

  //Compute Frequency Bounds
  for (int k = 0; k < fN; k++) {
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

int pollCurrent()
{
  int meanCurr = 0;
  for (int i = 0; i < 1<<samps; i++)
  {
    curr    = analogRead(stressPin);
    meanCurr  = meanCurr+curr;
  }
  meanCurr >>= samps;
  return meanCurr;
}
bool stressReact(int meanCurr)
{
  if(meanCurr>stressMoveThresh)
  {
    cInertia++;
    (cInertia>=ciMax) ? stress=true : stress=false;
  }
  else
  {
    cInertia--;
    stress=false;
    return false;
  }
  
  if(stress)
  {
    straighten();
  }
  return stress;
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
  for (int k = 0; k < fN; k++) {
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
      uShape();
      break;
    case 1:
      zShape();
      break;
    case 2:
      nShape();
      break;
    case 3:
      straighten();
      break;
    case 4:
      leftDiamond();
      break;
    case 5:
      rightDiamond();
      break;
    case 6:
      leftSquareGait();
      break;
    case 7:
      rightSquareGaitCS();
      break;
    case 8:
      positiveSquare();
      break;     
    case 9:
      negativeSquare();
      break;                              
    default:
      straighten();
      break;
  }
}
void uShape() {
  S1.writeMicroseconds(1500 - 900);
  S2.writeMicroseconds(1500 + 900);
}
void nShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 - 900);
}
void zShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 + 900);
}
void rightSquareGaitCS() {
  int A1[] = {maxx,minn,minn,maxx};
  int A2[] = {minn,minn,maxx,maxx};

  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(stressReact(pollCurrent()))
      return;
    
    
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void leftSquareGait() {
  int A1[] = {maxx,minn,minn,maxx};
  int A2[] = {minn,minn,maxx,maxx};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void rightSquareGait() {
  int A1[] = {maxx,maxx,minn,minn};
  int A2[] = {minn,maxx,maxx,minn};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void rightDiamond() {
  int A1[] = {maxx,midd,minn,midd};
  int A2[] = {midd,maxx,midd,minn};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void leftDiamond() {
  int A1[] = {maxx,midd,minn,midd};
  int A2[] = {midd,minn,midd,maxx};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void positiveSquare() {
  int A1[] = {midd,minn,minn,midd};
  int A2[] = {midd,midd,maxx,maxx};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}
void negativeSquare() {
  int A1[] = {maxx,maxx,midd,midd};
  int A2[] = {midd,minn,minn,midd};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
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
    if(stressCount>=stressMoveThresh && currFreq!=6 && currFreq!=7)
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
