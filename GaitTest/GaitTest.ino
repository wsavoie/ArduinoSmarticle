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

void NegativeCW();
void NegativeCCW();

void PositiveCW();
void PositiveCCW();

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  deactivateSmarticle();
}

void loop() 
{
  NegativeCW();
  NegativeCW();
  NegativeCW();

  delay(3000);

  NegativeCCW();
  NegativeCCW();
  NegativeCCW();

  delay(3000);

  PositiveCW();
  PositiveCW();
  PositiveCW();

  delay(3000);
  PositiveCCW();
  PositiveCCW();
  PositiveCCW();
  
  //activateSmarticle();
//  deactivateSmarticle();
  delay(3000);
  straighten();
  delay(3000);
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
void NegativeCW() //red area forward movement 
{
  
//  int A1[] = {110,100,136,170,180,180,145};
//  int A2[] = {80,70,36,0,0,10,45};
  int A1[] = {110,100,170,180,180};
  int A2[] = {80,70,0,0,10};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}

void NegativeCCW()//red area backwards movement 
{
//  int A1[] = {110,145,180,180,170,136,100};
//  int A2[] = {80,45,10,0,0,36,70};
  int A1[] = {110,180,180,170,100};
  int A2[] = {80,10,0,0,70};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}

void PositiveCW()//blue area backwards movement 
{
  int A1[] = {100,77,55,75,94,110,147,180,180,140};
  int A2[] = {80,39,0,0,38,70,89,105,125,102};
  
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}
void PositiveCCW()//blue area forwards movement 
{
  int A1[] = {100,140,180,180,147,110,94,75,55,77};
  int A2[] = {80,102,125,105,89,70,38,0,0,39};

  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p1 = A2[i] * 10 + 600);
    delay(del);
  }
}
