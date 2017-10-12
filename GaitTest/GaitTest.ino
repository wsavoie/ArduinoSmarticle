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

/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;
uint16_t const del = 500;
uint16_t const endDel = 500;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
void activateSmarticle();
void deactivateSmarticle();
void zShape();
void entangle();
void straighten();
void performFunc(int type);
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
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  deactivateSmarticle();
}

void loop() 
{
  leftSquareGait();
  leftSquareGait();
  leftSquareGait();

  delay(3000);

  rightSquareGait();
  rightSquareGait();
  rightSquareGait();

  delay(3000);

  leftDiamond();
  leftDiamond();
  leftDiamond();

  delay(3000);
  rightDiamond();
  rightDiamond();
  rightDiamond();
  
  //activateSmarticle();
//  deactivateSmarticle();
  delay(3000);
  straighten();
}


void deactivateSmarticle() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  //S1.writeMicroseconds(p1=minn * 10 + 600);
  //S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);
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

void leftSquareGait() { //coord space right
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
  delay(endDel);
}
void rightSquareGait() { //coord space left
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
    delay(endDel);
}
void rightDiamond() { //coord space left
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
    delay(endDel);
}
void leftDiamond() {//coord space right
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
    delay(endDel);
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
  delay(random(100));
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
  delay(random(100));
}
void straighten() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}
