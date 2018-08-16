#include <arduinoFFT.h>
#include <Servo.h>

#define mic     A6      // CHANGE BACK TO a6
#define stressPin A7    // CHANGE BACK TO orig a7 or a3
#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK

#define servo1 5//5 red//10 ross
#define servo2 6//6 red//11 ross

double findFrequency();
void setDly(int p1o,int p2o);
Servo S1;
Servo S2;
const int SERVONUM = 1;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
static int p1o= p1; static int p2o=p2;
const float spddel=2.8;//ms/degree


uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;


arduinoFFT FFT = arduinoFFT(); //creates new FFT object
const uint16_t samples = 128;
int const fN = 1; //number of frequencies
//int currFreq = 6;
//double samplingFrequency = ; //breadboard: elapsed time ~ 7700us
double samplingFrequency = 7950; //smarticle: elapsed time ~ 8050us
//int freqCenters[fN] = {2000};
//int freqAcceptThresh = 50;  //+-30Hz from freqCenter is accepted
//int freqUpperBounds[fN];
//int freqLowerBounds[fN];
//double computedFreqs[5];
double vReal[samples];
double vImag[samples];

bool start = false;
int servo=2;
static bool ledVal= true;
void circleGait();
void starGait();
void starCrossGait();
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
    S1.writeMicroseconds(p1=2400);
    S2.writeMicroseconds(p2=2400);
    }
  else{
    S1.writeMicroseconds(p1=2400);
    S2.writeMicroseconds(p2=600);   
    }
    Serial.begin(9600);
    p1o=p1;
    p2o=p2;
}
const uint8_t avgN=10;
float freqVal=0;
float indDel=0;
float globalDelay=60;
float dly=0;
const int testFreq=1000;
void loop() {

  if (start == false) {
   // digitalWrite(led, LOW);
      
    
    double freq = findFrequency();
    if (freq > testFreq+10-10 && freq < testFreq+10+10)
    {
      freqVal=0;
      for(int k=0; k<avgN;k++)
      {
        freqVal=freqVal+findFrequency();
        
      }
      freqVal=freqVal/avgN/testFreq;
      //freqVal=1;
      //indDel=globalDelay/freqVal;
      
      indDel=globalDelay;
      start = true;
    }
  }
  else {
//    light(ledVal= !ledVal);
    light(ledVal= !ledVal);
    
    //float temp= 150.0-150.0/freqVal;
    starCrossGait();
    //delay(globalDelay-10);
    //delayMicroseconds((indDel-globalDelay+10)*1000);
    
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
  samplingFrequency = 1 / (elapsedTime / 64000000/2); /*approximates using previous sampling frequency*/

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
    p1o=p1;
    p2o=p2;
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    setDly(p1o,p2o);
//    float dist=sqrt(float((p1-p1o)*(p1-p1o)+(p2-p2o)*(p2-p2o)));
//    delay(int(spddel*dist));
    delay(dly);

  }
}

void light(bool a)
{
  if (a)
    digitalWrite(led, HIGH);
  else
    digitalWrite(led, LOW);
}
void circleGait() {
  int pts = 20; //pts in gait
  //int dly = 60; //delay between pts in circle
  int cent1= 0;
  int cent2= 0;
  int rad = 90;
  float ang1=600;
  float ang2=600;
  //make sure rad +- center is > 0 and < 180

  for(float i=0;i < pts; i++)
  {
    ang1 = cent1 + rad*cos(float(i/pts)*2*PI);
    ang2 = cent2 + rad*sin(float(i/pts)*2*PI);
    p1o=p1;  p2o=p2;
    S1.writeMicroseconds(p1=int(ang1*10+1500));
    S2.writeMicroseconds(p2=int(ang2*10+1500));
    setDly(p1o,p2o);
//    delay(globalDelay-10);
//    delayMicroseconds((indDel-globalDelay+10)*1000);

    delay(dly/freqVal);
  }
}

void zGait() {
  static int A1[] = {maxx,minn};
  static int A2[] = {maxx,minn};
  if(servo!=1){
  A1[0] = minn;
  A1[1] = maxx;

  A2[0] = minn;
  A2[1] = maxx;
  }

  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    p1o=p1;  p2o=p2;
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    setDly(p1o,p2o);
//    delay(globalDelay-10);
//    delayMicroseconds((indDel-globalDelay+10)*1000);
    
    delay(dly/freqVal);
    //delay(dly-10);
    //delayMicroseconds((dly/freqVal-dly+10)*1000);
  }
}
  
void starGait() {
  static int A1[] = {0,64,84,116,180,135,154,84,26,45};
  static int A2[] = {71,64,0,64,71,116,180,148,180,116};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    p1o=p1;  p2o=p2;
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    setDly(p1o,p2o);
//    delay(globalDelay-10);
//    delayMicroseconds((indDel-globalDelay+10)*1000);
    
    delay(dly/freqVal);
    //delay(dly-10);
    //delayMicroseconds((dly/freqVal-dly+10)*1000);
  }
}

void starCrossGait() {
  static int A1[] = {0,180,26,84,154};
  static int A2[] = {71,71,180,0,180};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    p1o=p1;  p2o=p2;
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    setDly(p1o,p2o);
//    delay(globalDelay-10);
//    delayMicroseconds((indDel-globalDelay+10)*1000);
    
    delay(dly/freqVal);
    //delay(dly-10);
    //delayMicroseconds((dly/freqVal-dly+10)*1000);
  }
}
void setDly(int p1o,int p2o)
{
  dly=spddel*max(abs(p1o-p1),abs(p2o-p2))/10.0;
  Serial.print(dly);
}
