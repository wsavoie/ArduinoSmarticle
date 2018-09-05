#include <Servo.h>

/* Pin Definitions */
#define SERVOTYPE 0 //red=0, ross=1

#if SERVOTYPE==0 //RED
  #define servo1 5//5 red//10 ross
  #define servo2 6//6 red//11 ross
#else            //ROSS
  #define servo1 10//5 red//10 ross
  #define servo2 11//6 red//11 ross
#endif

#define led 13
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const float pi= 3.14;

uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
const float spddel=2.8;//ms/degree

void activateSmarticle();

volatile int p1 = 1500; volatile int p2 = 1500;
volatile int p1o= p1; volatile int p2o=p2;
#define SIZE 60
//volatile int An1[SIZE];
//volatile int An2[SIZE];
//volatile int * AA1;//pointer to volatile variable
//volatile int * AA2; 

const byte servo=0; //0 for regular, 1 for non-reg
int dly=0;
const byte micPin = 2;  
volatile bool interrupt=false;
int An1[] = {maxx, maxx, minn, minn};
int An2[] = {maxx, minn, minn, maxx};
auto aSize=sizeof(An1) / sizeof(int);

void leftSquareGait();


  
void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  //deactivateSmarticle();
  Serial.begin(9600);
  attachInterrupt(digitalPinToInterrupt(micPin), ISRFunc, LOW);
}

void loop()
{

  if(interrupt)
  { 
    detachInterrupt (digitalPinToInterrupt (micPin));
    EIFR =1;  // clear flag for interrupt 1
    EIFR =2;  // clear flag for interrupt 2
    leftSquareGait();
    delay(300);
    
    attachInterrupt(digitalPinToInterrupt(micPin), ISRFunc, LOW);
    interrupt=false;
  }
}
void setDly(int p1o,int p2o)
{
  dly=spddel*max(abs(p1o-p1),abs(p2o-p2))/10.0;
}
void ISRFunc()
{
    interrupt=true;  
}
void leftSquareGait()
{
  for (int i = 0; i < aSize; i++)
  {
    p1o=p1;
    p2o=p2;
    S1.writeMicroseconds(p1 = *(An1+(i+servo)%aSize) * 10 + 600);
    S2.writeMicroseconds(p2 = *(An2+(i+servo)%aSize) * 10 + 600);
    dly=spddel*max(abs(p1o-p1),abs(p2o-p2))/10.0;
    delay(dly);
  }
}  

