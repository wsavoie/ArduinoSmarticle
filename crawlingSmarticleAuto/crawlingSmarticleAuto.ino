#include <Servo.h>
#include <EEPROM.h>

/* Pin Definitions */
#define servo1 5 //new: 10
#define servo2 6 //new: 11
#define led 13

/* Instance Data & Declarations */
Servo S1;
Servo S2;
const uint8_t SERVONUM = 3;
const uint8_t RUNCOUNTADDR = 0;
const uint8_t numTrials = 2; //for each angle
uint8_t runCount;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t gaitRadius = 20; //between 0 and 90 degrees
uint8_t radiusChange;
uint8_t gaitRadii[] = {90,80,70,60,50,40,30,20}; //assume always length 8
uint8_t mins[8]; uint8_t maxs[8];
uint8_t curInd;
void deactivateSmarticle();
void activateForward();
void activateBackward();
void entangle();

void setup() {
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  
  runCount = EEPROM.read(RUNCOUNTADDR);
  runCount = runCount + 1;
  EEPROM.write(RUNCOUNTADDR, runCount);

  if (runCount % numTrials == 0) {
    while (true)
      entangle();  //signal a change in angle
  }
  
  deactivate();
  delay(1000);
  curInd = getCurInd(runCount);
  flashLED(curInd);
  
  for (int k = 0; k < 8; k++) {
    radiusChange = 90 - gaitRadii[k];
    mins[k] = minn + radiusChange;
    maxs[k] = maxx - radiusChange;
  }
  delay(5000);
}

void loop()
{
  activateForward(maxs[curInd], mins[curInd]);
}

/* Moves the arms parallel to the Smarticle's body */
void deactivate() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}

/* Moves the Smarticle forward (convention: switch on left side) */
void activateForward(uint8_t maxx, uint8_t minn) {
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
}

/* Moves the Smarticle backward (convention: switch on left side) */
void activateBackward(uint8_t maxx, uint8_t minn) {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=(180-minn) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=(180-maxx) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=(180-maxx) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=(180-minn) * 10 + 600);
  delay(300);
}

uint8_t getCurInd(uint8_t runCount) {
  if (runCount <= numTrials * 1) {
    return 0;
  } else if (runCount <= numTrials * 2) {
    return 1;
  } else if (runCount <= numTrials * 3) {
    return 2;
  } else if (runCount <= numTrials * 4) {
    return 3;
  } else if (runCount <= numTrials * 5) {
    return 4;
  } else if (runCount <= numTrials * 6) {
    return 5;
  } else if (runCount <= numTrials * 7) {
    return 6;
  } else if (runCount <= numTrials * 8) {
    return 7;
  } else {  //trials are over
    return 0;
  }
}

/* Moves arms to "U" shape, used to signal changing angle */
void entangle() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);
}

void flashLED(int numFlashes) {
  for (int k = 0; k < numFlashes; k++) {
    digitalWrite(led, HIGH);
    delay(250);
    digitalWrite(led, LOW);
    delay(250);
  }
}

