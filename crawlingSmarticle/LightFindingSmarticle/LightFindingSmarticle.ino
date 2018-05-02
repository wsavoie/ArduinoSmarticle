#include <Servo.h>

#define servo1 5//5 red
#define servo2 6//6 red

#define vibrationMotor     13      // CHANGE BACK TO a6
#define mic     A6      // CHANGE BACK TO a6
#define stressPin A7    // CHANGE BACK TO orig a7 or a3
#define randPin A4    // CHANGE BACK TO a7
#define led 13    //13 SCK

#define pr1 A0 // front PR sensor
#define pr2 A1 // back PR sensor
#define pr3 A2 // side PR sensor

Servo S1;
Servo S2;
const int SERVONUM = 1;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;

int lightLevel;
int lightLevel2;
void rightDiamond();

void setup() {
  // put your setup code here, to run once:
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
 
  //pinMode(led,OUTPUT);
  pinMode(vibrationMotor,OUTPUT);
  pinMode(stressPin,INPUT);
  pinMode(mic,INPUT);
  
  randomSeed(analogRead(randPin));
}

void loop() {
  //place robot down
  
  lightLevel = analogRead(pr3);//compute and store value of light

  nShape();
  vibrate();//pick direction at random- will add exponential later
  
  for(int i = 0; i < 4 ; i++){//go step and try to follow positive gradient
    rightDiamond();
    lightLevel2 = lightLevel;//lightLevel is current
    lightLevel = analogRead(pr3);
    if(lightLevel < lightLevel2){//if new light is darker
      break;
    }
  }
  
  
}
//uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
void rightDiamond() {
  int A1[] = {maxx,midd,minn,midd};
  int A2[] = {midd,maxx,midd,minn};
  for (int i = 0; i < (sizeof(A1)/sizeof(int)); i++)
  {
    S1.writeMicroseconds(p1 = A1[i] * 10 + 600);
    S2.writeMicroseconds(p2 = A2[i] * 10 + 600);
    if(i==(sizeof(A1)/sizeof(int))-1)
    {
      delay(del-100);
      delay(random(100));
    }
    else
      delay(del);
  }
}

void vibrate() {
  digitalWrite(vibrationMotor, HIGH);
  delay(random(500, 2000));
  digitalWrite(vibrationMotor, LOW);
}
void nShape() {
  S1.writeMicroseconds(1500 + 900);
  S2.writeMicroseconds(1500 - 900);
  delay(del);
}
