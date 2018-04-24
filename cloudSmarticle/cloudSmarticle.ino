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

int randAmp = 800;//units of milliseconds
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
void straighten();
void leftSquareGait();
void rightSquareGait();
void leftDiamond();
void rightDiamond();
void positiveSquare();
void negativeSquare();
void zShape();
void uShape();
void nShape();

void setup() {
  S1.attach(servo1, 600, 2400);
  S2.attach(servo2, 600, 2400);
  pinMode(led, OUTPUT);
  deactivateSmarticle();
  randomSeed(analogRead(0));
}

void loop()
{
  //leftSquare();
  activateSmarticle();
  //deactivateSmarticle();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1 = 1500);
  S2.writeMicroseconds(p2 = 1500);
  //  S1.writeMicroseconds(p1=maxx * 10 + 600);
  //  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);
}

void activateSmarticle() {
  //+1 for max argument for random because it goes from min to max-1
  int periodDel = (maxRand + random(-1 * randAmp, randAmp + 1)) / 4.0; //units of milliseconds
  //if I do full size random and divide it by 4 and use it 4 times
  //it has same std as a single large random
  //it is different though if I add up 4 smaller randoms

  S1.writeMicroseconds(p1 = maxx * 10 + 600);
  S2.writeMicroseconds(p2 = minn * 10 + 600);
  delay(del + periodDel);
//  delay(del);
  S1.writeMicroseconds(p1 = maxx * 10 + 600);
  S2.writeMicroseconds(p2 = maxx * 10 + 600);
  delay(del + periodDel);
  S1.writeMicroseconds(p1 = minn * 10 + 600);
  S2.writeMicroseconds(p2 = maxx * 10 + 600);
  delay(del + periodDel);
  S1.writeMicroseconds(p1 = minn * 10 + 600);
  S2.writeMicroseconds(p2 = minn * 10 + 600);
  delay(del + periodDel);
}

void uShape() {
  S1.writeMicroseconds(1500 - 900);
  S2.writeMicroseconds(1500 + 900);
  delay(del);
}
void nShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 - 900);
}
void zShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 + 900);
}
void leftSquareGait() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(300);
  delay(random(200));
}
void rightSquareGait() {
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
  delay(random(200));
}
void rightDiamond() {
    S1.writeMicroseconds(maxx * 10 + 600);
    S2.writeMicroseconds((midd) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(midd * 10 + 600);
    S2.writeMicroseconds((maxx) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(minn * 10 + 600);
    S2.writeMicroseconds((midd) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(midd * 10 + 600);
    S2.writeMicroseconds((minn) * 10 + 600);
    delay(300);
    delay(random(200));
}
void leftDiamond() {
    S1.writeMicroseconds(maxx * 10 + 600);
    S2.writeMicroseconds((180-midd) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(midd * 10 + 600);
    S2.writeMicroseconds((180-maxx) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(minn * 10 + 600);
    S2.writeMicroseconds((180-midd) * 10 + 600);
    delay(del);
    S1.writeMicroseconds(midd * 10 + 600);
    S2.writeMicroseconds((180-minn) * 10 + 600);
    delay(300);
    delay(random(200));
}
void positiveSquare() {
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(300);
  delay(random(200));
}
void negativeSquare() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=midd * 10 + 600);
  S2.writeMicroseconds(p2=midd * 10 + 600);
  delay(300);
  delay(random(200));
}



void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}

