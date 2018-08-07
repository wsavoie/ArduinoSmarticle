#include <arduinoFFT.h>
#include <Servo.h>

#define mic     A6      // CHANGE BACK TO a6
#define stressPin A7    // CHANGE BACK TO orig a7 or a3
#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK

#define servo1 5//5 red//10 ross
#define servo2 6//6 red//11 ross

double findFrequency();

Servo S1;
Servo S2;
const int SERVONUM = 1;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;



arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 32;
int const fN = 1; //number of frequencies
//int currFreq = 6;
//double samplingFrequency = ; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 3975; //smarticle: elapsed time ~ 8050us
//int freqCenters[fN] = {2000};
//int freqAcceptThresh = 50;  //+-30Hz from freqCenter is accepted
//int freqUpperBounds[fN];
//int freqLowerBounds[fN];
//double computedFreqs[5];
double vReal[samples];
double vImag[samples];

bool start = false;
int servo=2;

void setup() {
  S1.attach(servo1, 600, 2400);
  S2.attach(servo2, 600, 2400);

  pinMode(led, OUTPUT);

  pinMode(stressPin, INPUT);
  pinMode(mic, INPUT);
  randomSeed(analogRead(randPin));
//  straighten();
  
  if(servo==1)
  {
    S1.writeMicroseconds(2400);
    S2.writeMicroseconds(2400);
    }
  else{
    S1.writeMicroseconds(2400);
    S2.writeMicroseconds(600);
    }
    Serial.begin(9600);
}

void loop() {
  if (start == false) {
   // digitalWrite(led, LOW);


    double freq = findFrequency();
    if (freq > 2375 && freq < 2380)
    {
      start = true;
    }
  }
  else {
    leftSquareGait();
   // digitalWrite(led, HIGH);
   // delay(100);
   // digitalWrite(led, LOW);
  //  delay(100);
  }

}
/* Uses FFT analysis to calculate the dominant frequency picked up by the microphone */
double findFrequency() {
  double startTime = micros();
  for (uint16_t i = 0; i < samples; i++)
  {
    vReal[i] = double(analogRead(mic));
    vImag[i] = 0;
    // Serial.print(vReal[i]);
    // Serial.print("      ");
  }
  double endTime = micros();
  double elapsedTime = endTime - startTime; //~ 7700 microseconds
  //Serial.println(elapsedTime);
  samplingFrequency = 1 / (elapsedTime / 64000000*2); /*approximates using previous sampling frequency*/

  FFT.Windowing(vReal, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);  /* Weigh data */
  FFT.Compute(vReal, vImag, samples, FFT_FORWARD); /* Compute FFT */
  FFT.ComplexToMagnitude(vReal, vImag, samples); /* Compute magnitudes */
  double x = FFT.MajorPeak(vReal, samples, samplingFrequency);
  Serial.println(x, 6);
  return x;

}

void straighten() {
  S1.writeMicroseconds(p1 = 1500);
  S2.writeMicroseconds(p2 = 1500);
  delay(del);
}

void leftSquareGait() {
  int A1[] = {maxx, maxx, minn, minn};
  int A2[] = {maxx, minn, minn, maxx};
  if(servo!=1){
  A1[0] = maxx;
  A1[1] = minn;
  A1[2] = minn;
  A1[3] = maxx;

  A2[0] = minn;
  A2[1] = minn;
  A2[2] = maxx;
  A2[3] = maxx;
  
  }
  for (int i = 0; i < (sizeof(A1) / sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if (i == (sizeof(A1) / sizeof(int)) - 1)
    {
      delay(del - 100);
      delay(random(100));
    }
    else
      delay(del);
  }
}

/*
  void light(bool start)
  {
  if (start==false)
    digitalWrite(led, LOW);
  else
    digitalWrite(led, HIGH);
  }
*/
