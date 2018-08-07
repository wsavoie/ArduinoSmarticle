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

int lightLevel=0; //current light level
int lightLevel2=0;//older light level

/* Levy specific declarations */
const uint16_t n= 352; //number of segments for square gait, make sure this is divisible by 4 always!
const uint16_t s= n/4; //side length declared for clearer code
uint16_t a1[n];//angular position 1, units of microseconds
uint16_t a2[n];//angular position 2, units of microseconds
uint8_t dt=120/60*180/s; //ms for each step:  120[ms]/60[deg] * 180[degrees per side]/s [steps/side]=[ms/step]
uint8_t dtA=120/60;// ms/angle
uint16_t static posIdx=0;

float R=90;//units of degrees
int smallStepSize=s; //indices to move during small step



uint16_t calcStepSize();
void moveServo(int oldV, int newV);
void writeServos(int delTime, int idx1, int idx2);
void defineRightSquareGait();
void vibrate(int delTime);
void rotateSmart(int angle);

void setup() {
Serial.begin(9600);
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
  randomSeed(analogRead(0));
  
  defineRightSquareGait();

  //start of system in straight shape
  S1.writeMicroseconds(1500);
  S2.writeMicroseconds(1500);
  delay(500);

  
  writeServos(500,0,0);
}

void loop() {
  
  //detect light
  lightLevel = analogRead(pr3);//compute and store value of light
  
  //rotate some amount between -180 and 180
  //rotateSmart(random(-180,180));
  rotateSmart(random(-180,180));
  
  //exploratory step
  writeServos(dt*smallStepSize,posIdx+smallStepSize,posIdx+smallStepSize);

  //compare light levels
  lightLevel2 = lightLevel;
  lightLevel= analogRead(pr3);
  if (lightLevel<lightLevel2)
    {return;}
     
  int ss=calcStepSize(); //calc next step size
  moveServo(posIdx,ss); 
 

/////////////////TEST CODE//////////////////
//Serial.println("start");
//moveServo(posIdx=11,1);
//
//Serial.println("start");
//moveServo(posIdx=0,12);
//
//Serial.println("start");
//moveServo(posIdx=2,4);
//
//Serial.println("start");
//moveServo(posIdx=6,23);
//
//Serial.println("start");
//moveServo(posIdx=11,11); 
//////////////////////////////////////////////

}
void moveServo(int oldV,int dist)
{
  int delTime=0;
  int revs = (dist+oldV)/n; //number of times steps goes around gait
//  int counts=-1; //counts iterations of while loop, 
  int finalPos=(oldV+dist)%n;
  uint8_t cS=oldV/s; //currentSide stores oldV's position 0,1,2,3  
  if(finalPos/s != cS ||revs>0 )
  {
    do
    { 
      if(cS==3)
      {
        revs--;
        cS=-1;
      }
      cS++;
      writeServos(dt*(s-posIdx%s),(s*cS)%n,(s*cS)%n);
      
      //////////TESTCODE//////////
//      delay(1000);
//      Serial.println(s*cS); 
      ////////////////////////////

    } while((revs!=0) || (finalPos/s !=cS));//while we still need to perform a full revolution or we arent on current side  
  }
  writeServos(dt*(finalPos-posIdx),finalPos,finalPos);
    //////////TESTCODE//////////
//    Serial.println(posIdx);
//    Serial.println("finished");
    ////////////////////////////
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
void writeServos(int delTime,int idx1,int idx2)
{
//  S1.writeMicroseconds(A[finalPos]);
//  S2.writeMicroseconds(A[(finalPos+s)%n]);    
  
  S1.writeMicroseconds(a1[idx1]);
  S2.writeMicroseconds(a2[idx2]);
  delay(delTime);
  posIdx=idx1;    
}
void defineRightSquareGait()
{
  //for some reason right square is:
  //a1=(1,1,0,0)
  //a2=(0,1,1,0)
  for (uint16_t i = 0; i < s; i++) //first leg starting from top right
    {
      a1[i]=(R+R)*10+600;
      a2[i]=round((float(2*i*R)/float(s))-R+R)*10+600;
    }
    for (uint16_t i = 0; i < s; i++) //second leg starting from bottom right
    {
      a1[i+s]=round((float(-2*i*R)/float(s)+R+R)*10+600);
      a2[i+s]=(R+R)*10+600;
    }
    
    for (uint16_t i = 0; i < s; i++)//third leg starting from bottom left
    {
      a1[i+2*s]=(-R+R)*10+600;
      a2[i+2*s]=round((float(-2*i*R)/float(s)+R+R)*10+600);
    }
 
    for (uint16_t i = 0; i < s; i++)//fourth leg starting from top left
    {
      a1[i+3*s]=round((float(2*i*R)/float(s)-R+R)*10+600);
      a2[i+3*s]=(-R+R)*10+600;
    }

    //calculate delay time based on size of movement

    //.12 s/60 deg--> 2 ms/deg
    //2*R/s = deg/step unique for centered square gait
    
    //specific to square gait! 
    dt=round(float(2*R)/float(s)*2);// (ms/step)
}

void rotateSmart(int angle)
{
  //angle>0 rotates ccw
  //from video 9x9:
  //ccw = 60 deg/s = 16.667 ms/deg
  //cw  = 24 deg/s = 41.667 ms/deg;
  float vibDelay=0;
  int ang1Diff=0;
  int ang2Diff=0;
  int ang1=0;
  int ang2=0;
  if(angle>=0)
  {
    vibDelay=16.667;
    ang1=2400;
    ang2=600;
  }
  else
  {
    vibDelay=41.667;
    ang1=1500;
    ang2=2400;  
  }
  S1.writeMicroseconds(ang1);
  S2.writeMicroseconds(ang2);
  ang1Diff=abs(((a1[posIdx]-600)/10)-((ang1-600)/10));
  ang2Diff=abs(((a2[posIdx]-600)/10)-((ang2-600)/10));
  
  //delay while servos reach vibration position
  Serial.println("angle1: "+ String(a1[posIdx]));
  Serial.println("angle2: "+ String(a2[posIdx]));
  
  Serial.println("delay time: " + String(max(ang1Diff,ang2Diff)*dtA));
//  delay(max(ang1Diff,ang2Diff)*dtA); //delay for amount of time it takes to get to position
  delay(360); //delay for amount of time it takes to get to position
  vibrate(round(vibDelay*abs(angle)));

  //move back to old position
  writeServos(360,posIdx,posIdx);

}
void vibrate(int delTime)
{
  digitalWrite(vibrationMotor, HIGH);
  delay(delTime);
  digitalWrite(vibrationMotor, LOW);
}

