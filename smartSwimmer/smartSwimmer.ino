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
int const fN= 11; //number of frequencies
int currFreq=6;
//double samplingFrequency = 8300; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 7950; //smarticle: elapsed time ~ 8050us
int freqCenters[fN] = {600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600};
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
void straighten();
void performFunc(int type);
void leftDiamond(int MIN,int MID, int MAX);
void rightDiamond(int MIN,int MID, int MAX);
void uShape();

void rightSquareGaitCS();
void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  pinMode(led,OUTPUT);
  
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  randomSeed(analogRead(randPin));
  straighten();

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
      leftDiamond(0,90,180);
      break;
    case 1:
      leftDiamond(15,90,165);
      break;
    case 2:
      leftDiamond(30,90,150);
      break;
    case 3:
      leftDiamond(45,90,135);
      break;
    case 4:
      leftDiamond(60,90,120);
      break;
    case 5:
      rightDiamond(0,90,180);
      break;
    case 6:
      rightDiamond(15,90,165);
      break;
    case 7:
      rightDiamond(30,90,150);
      break;
    case 8:
      rightDiamond(45,90,135);
      break;     
    case 9:
      rightDiamond(60,90,120);
      break;          
    case 10:
      uShape();
      break;                       
    default:
      straighten();
      break;
  }
}

void leftDiamond(int MIN,int MID, int MAX) {
  int A1[] = {MAX,MID,MIN,MID};
  int A2[] = {MID,MIN,MID,MAX};

  S1.writeMicroseconds(p1 = A1[0] * 10 + 600);
  S2.writeMicroseconds(p2 = A2[0] * 10 + 600);  
  delay(5000);
  
  for(int j=0; j<5; j++)
  {
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
}

void rightDiamond(int MIN,int MID, int MAX) {
  int A1[] = {MAX,MID,MIN,MID};
  int A2[] = {MID,MAX,MID,MIN};
  S1.writeMicroseconds(p1 = A1[0] * 10 + 600);
  S2.writeMicroseconds(p2 = A2[0] * 10 + 600);  
  delay(5000);
  for(int j=0; j<5; j++)
  {
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
}
void uShape() {
  S1.writeMicroseconds(1500 - 900);
  S2.writeMicroseconds(1500 + 900);
}

void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}
