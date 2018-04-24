#include <math.h>
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
uint16_t const randAmp = 100;//units of milliseconds
uint16_t const del = 400;
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;

static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;


const uint16_t n= 352; //number of segments for square gait, make sure this is divisible by 4 always!
const uint16_t s= n/4; //side length declared for clearer code
uint16_t A[n];//angular position 1, units of microseconds
uint8_t dt=8; //ms for each step
uint16_t posIdx=0;

float R=90;//units of degrees

uint16_t calcStepSize();
void moveServo(int oldV, int newV);

void setup() {
Serial.begin(9600);
S1.attach(servo1,600,2400);
S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
    randomSeed(analogRead(0));
    
    
    for (uint16_t i = 0; i < s; i++) //first leg starting from top right
    {
      A[i]=(R)*10+600;
    }
    for (uint16_t i = 0; i < s; i++) //second leg starting from bottom right
    {
      A[i+s]=round((float(-2*i*R)/float(s)+R)*10+600);
    }
    
    for (uint16_t i = 0; i < s; i++)//third leg starting from bottom left
    {
      A[i+2*s]=(-R)*10+600;
    }
 
    for (uint16_t i = 0; i < s; i++)//fourth leg starting from top left
    {
      A[i+3*s]=round((float(i*2*R)/float(s)-R)*10+600);
    }

    //for a centered square gait, the other position is defined by
    //A2=A[(i+s)%n]

    //*********TODO*************
    //calculate delay time based on size of movement
S1.writeMicroseconds(p1=1500);
S2.writeMicroseconds(p2=1500);
delay(500);

S1.writeMicroseconds(A[0]);
S2.writeMicroseconds(A[(0+s)%n]);
delay(500);    
}

void loop() {
  int old =posIdx;
  //detect light
  //calc next step size
  int ss=calcStepSize();
  //next position to move to
//  posIdx= (old+ss)%n;
  moveServo(posIdx,ss);
//  Serial.println(calcStepSize()); 
//  delay(5);
  
}
void moveServo(int oldV,int dist)
{
  int delTime=0;
  int revs = dist/n; //number of times steps goes around gait
  int counts=-1; //counts iterations of while loop, 
  int finalPos=(oldV+dist)%n;
  static uint8_t cS=0; //currentSide stores oldV's position 0,1,2,3  
  if(finalPos/s != cS ||revs>0 )
  {
    do
    { 
      counts++;  
      if(counts>=3)
      {
        revs--;
        counts=-1;
      } 
      
      delTime=dt*(s-posIdx%s);
      cS++;
      posIdx=(s*cS)%n;
      S1.writeMicroseconds(A[s*cS]);
      S2.writeMicroseconds(A[(posIdx+s)%n]);    
      delay(delTime);
      
    } while((revs!=0) || (finalPos/s !=cS));//while we still need to perform a full revolution or we arent on current side  
  }

  S1.writeMicroseconds(A[finalPos]);
  S2.writeMicroseconds(A[(finalPos+s)%n]);    
  delTime=dt*(finalPos-posIdx);
  posIdx=finalPos;
  delay(delTime);
}
uint16_t calcStepSize()
{
  double v=random(-15707,15707)/10000.0;
  double w=-log(random(0,65000)/65000.0);

  //alpha beta gamma delta
  double A=0.5;
  double B=1;
  double G=1;
  double D=0;

  //const c
  double c=B*tan(PI*A/2.0);
  double b=atan(c);
  double S=pow(1.0+c*c,1.0/(2.0*A));
  double res1=S*sin(A*v+b)/(pow(cos(v),1.0/A))+pow(cos(v*(1.0-A)-b)/w,(1.0-A)/A);
  res1=round(n*res1/pow(2,12)+1);
  if(res1>6*n)
  {
  res1=6*n;
  }
  return uint16_t(res1);
}
