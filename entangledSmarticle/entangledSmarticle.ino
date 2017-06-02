#include <Servo.h>
#include <arduinoFFT.h>

/* Pin Definitions */
#define servo1 5 //10, 9
#define servo2 6 //11, 10
#define led 13
#define mic A6

/* Instance Data & Declarations */
Servo S1;
Servo S2;
uint8_t const SERVONUM = 5;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint16_t const del = 400;

/* Methods */
double findFrequency();
void analyzeFrequency();
void entangle();
void straighten();

/* FFT Stuff */
arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 64;
//double samplingFrequency = 8300; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 7950; //smarticle: elapsed time ~ 8050us
//SERVONUM:            1    2    3    4    5    6    7    8
int freqCenters[8] = {600, 700, 800, 900, 1000, 1100, 1200, 1300};
int freqAcceptThresh = 40;  //+-Hz from freqCenter is accepted
int freqUpperBounds[8];
int freqLowerBounds[8];
double computedFreqs[5];
double vReal[samples];
double vImag[samples];
#define SCL_INDEX 0x00
#define SCL_TIME 0x01
#define SCL_FREQUENCY 0x02
int inertia = 5;

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  pinMode(mic,INPUT);

  straighten();
  entangle();

  //Compute Frequency Bounds
  for (int k = 0; k < 8; k++) {
    freqUpperBounds[k] = freqCenters[k] + freqAcceptThresh;
    freqLowerBounds[k] = freqCenters[k] - freqAcceptThresh;
  }
  //Serial.begin(9600);
}

void loop() {
  double freq = findFrequency();
  analyzeFrequency(freq);
}

/* Uses FFT analysis to calculate the dominant frequency picked up by the microphone */
double findFrequency() {
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
  //Serial.println(samplingFrequency);
  FFT.Windowing(vReal, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);  /* Weigh data */
  FFT.Compute(vReal, vImag, samples, FFT_FORWARD); /* Compute FFT */
  FFT.ComplexToMagnitude(vReal, vImag, samples); /* Compute magnitudes */
  double x = FFT.MajorPeak(vReal, samples, samplingFrequency);
  //Serial.println(x, 6);
  return x;
}

/* Determines whether or not to activate the smarticle based on frequency */
void analyzeFrequency(double freq) {
  /*if (freq > 1000) {
    deactivateSmarticle();
    return;
  }*/
  
  for (int k = 0; k < 8; k++) {
    if (freqLowerBounds[k]<freq && freq<freqUpperBounds[k] && SERVONUM == k+1) {
      inertia--;
      if (inertia <= 0)
        straighten();
      return;
    }
  }
  inertia = 5;
  entangle();
}

void entangle() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);
}

void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}

