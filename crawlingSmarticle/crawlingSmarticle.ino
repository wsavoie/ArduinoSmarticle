#include <Servo.h>

/* Pin Definitions */
#define servo1 5 //new: 10
#define servo2 6 //new: 11
#define led 13

/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t radiusChange = 0;
void activateSmarticle();
void deactivateSmarticle();

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  minn = minn + radiusChange;
  maxx = maxx - radiusChange;
  deactivateSmarticle();
  delay(5000);
}

void loop() 
{
  activateSmarticle();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
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
  //delay(random(100));
}
