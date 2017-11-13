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
void activateSmarticle();
void deactivateSmarticle();
void zShape();

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  deactivateSmarticle();
}

void loop() 
{
  activateSmarticle();
  deactivateSmarticle();
   //zShape();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  //S1.writeMicroseconds(p1=minn * 10 + 600);
  //S2.writeMicroseconds(p2=maxx * 10 + 600);
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
