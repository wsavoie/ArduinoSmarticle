#include <Servo.h>

/* Pin Definitions */
#define servo1 5 //5 red//10 ross
#define servo2 6 //6 red//11 ross
#define led 13
int randAmp = 100;//units of milliseconds
int maxRand = 1000;
int del = 400;
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;

static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
void activateSmarticle();
void deactivateSmarticle();


void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  deactivateSmarticle();
  randomSeed(analogRead(0));
}

void loop() 
{
  activateSmarticle();
  //deactivateSmarticle();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
//  S1.writeMicroseconds(p1=maxx * 10 + 600);
//  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);
}

void activateSmarticle() {
  //+1 for max argument for random because it goes from min to max-1
  int periodDel=(maxRand+random(-1*randAmp,randAmp+1))/4.0;//units of milliseconds
    
  
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del+periodDel);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del+periodDel);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del+periodDel);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del+periodDel);
}
