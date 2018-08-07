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
const float pi= 3.14;

static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
void activateSmarticle();
void deactivateSmarticle();
void zShape();
void circleGait();
void zGait();

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  //deactivateSmarticle();
  //Serial.begin(9600);
}

void loop() 
{
  //activateSmarticle();
  //deactivateSmarticle();
   //zShape();
//  circleGait();
  zGait();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
//  S1.writeMicroseconds(p1=minn * 10 + 600);
//  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);
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
void zShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 + 900);
  
}
void circleGait() {
  int pts = 20; //pts in gait
  int dly = 60; //delay between pts in circle
  int cent1= 0;
  int cent2= 0;
  int rad = 90;
  float ang1=600;
  float ang2=600;
  //make sure rad +- center is > 0 and < 180
  
  for(float i=0;i < pts; i++)
  {
    ang1 = cent1 + rad*cos(float(i/pts)*2*pi);
    ang2 = cent2 + rad*sin(float(i/pts)*2*pi);
    
    S1.writeMicroseconds(int(ang1*10+1500));
    S2.writeMicroseconds(int(ang2*10+1500));
    delay(dly);
    //Serial.println(ang1);
  }
}

void zGait() {
  int A1[] = {maxx,minn};
  int A2[] = {maxx,minn};
  int dly=500;
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(dly);
    }
    else
      delay(dly);
  }
}


