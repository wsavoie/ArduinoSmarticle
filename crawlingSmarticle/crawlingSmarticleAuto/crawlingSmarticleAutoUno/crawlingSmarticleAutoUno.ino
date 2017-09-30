//#include <NeoSWSerial.h>
#include <SoftwareSerial.h>

//on uno and promini
//TX=9 RX=8
int front = A1; //photoresistor top of plate
int back = A5; //photoresistor at bottom of plate

String inBuffer;
int valF = 0;
int valB = 0;
//beam break threshold
int thresh = 900;
SoftwareSerial AS(8, 9);
//NeoSWSerial AS(8, 9);
int getValue(String data, char separator, int index);
void readParamsFromMatlab();
void sendParamsToMini();
int dir = 0;
bool writeYes = true;
//maxV,gaitRadInitial,gaitIncrease,v,dir
int params[] = {10, 89, 2, 0, 1};
///////////initialize vars//////////
//int maxV = 2;           //number of trials for each radius
//int gaitRadInitial = 30;//initial gait radius
//int gaitIncrease = 1;   //amount to increase gait radius
int v = 1;              //current trial number
////////////////////////////////////////////////////////////



//start system with power to smarticle unplugged
//sending program to uno with proper params plugged in above
//plug in smarticle press reset button and should start moving to right
//move hand over left side sensor it shouldn't start recording until it
//the smarticle makes it to the end of right side. Once it passes right sensor
//system should start a recording on optitrack on optitrack
//throw away first (2?) recordings


void setup()
{
  //read sensor data
  pinMode(front, INPUT);
  pinMode(back, INPUT);

  dir = 0;
  dir = v % 2 + 1; //odd if v is odd dir=2, if even dir=1
  //pinMode(proDirPin,OUTPUT);

  AS.begin(9600);
  Serial.begin(9600); //serial to matlab
  Serial.flush();
  delay(1000);


  //
  //  int test = getValue(inBuffer,k, 0);
  //  Serial.println("value: "+String(test));
}
void loop()
{
  char buff[6];
  //readParamsFromMatlab();
  switch (dir)
  {
    case 0: //unknown starting direction
      valF = readSensor(analogRead(front));
      valB = readSensor(analogRead(back));
      //      Serial.println();
      if (valF) {

        dir = 2; //set new dir to front
        sprintf(buff, "%d", dir);
        AS.write('2');
//          Serial.println("Go Back");

      }
      else if (valB) {
        dir = 1; //set new dir to front
        sprintf(buff, "%d", dir);
        AS.write('1');
        //AS.write(dir))
//          Serial.println("Go Front");
      }

      break;
    case 1: //polling front side, read front

      valF = readSensor(analogRead(front));
      //       Serial.println("front:"+String(analogRead(front)));
      if (valF) {
        dir = 2;
        sprintf(buff, "%d", dir);
        AS.write('2');
//         Serial.println("Go Back");
      }
      break;
    case 2: //towards back
      valF = readSensor(analogRead(back));
      //      Serial.println("back:"+String(analogRead(back)));
      if (valF) {
        dir = 1;
        sprintf(buff, "%d", dir);
        AS.write('1');
//          Serial.println("Go Front");
      }
      break;
  }
  readFromMini();
}

int readSensor(int sensorResult)
{
  //if using analog read, this function takes read result and
  //does thresholding to determine binary signal output
  //needs to be ">"because it is high when covered
//    Serial.println(sensorResult);
  if (sensorResult > thresh) {
    //    Serial.println(valB);
    return 1;
  }
  else
  {
    return 0;
  }
  //return(valB);
}
void stopProgram()
{
  while (1)
  {
    Serial.print("restart uno and mini\r\n");
    delay(1000);
  }
}

void readParamsFromMatlab() //when data comes from matlab
{
  const char k[] = ",";
  String bufferMat;

  int mSize = 0;
  char *token;
  String buffStr;
  
  while (Serial.available()>0)
  {
    char c= Serial.read();
    buffStr=buffStr+c;
    mSize++;
    delay(4);
  }


  if (mSize > 0) //if received commands from matlab
  {
    buffStr=buffStr;
    auto msg =buffStr.c_str();
  Serial.println(buffStr);
     sscanf(msg, "%d,%d,%d,%d,%d", &params[0],
  &params[1], &params[2],&params[3],&params[4]);
   
      Serial.println("m: " + String(params[0]) + " gr: " + String(params[1])
                   + " gi: " + String(params[2]) + " v: " + String(params[3])
                   + " dir: " + String(params[4]));
    sendParamsToMini();

    
//    token = strtok(aMessage, k);
//    int idx = 0;
//    while (token != NULL)
//    {
//      params[idx] = atoi(token);
//      idx++;
//      token = strtok (NULL, k);
//    }
//    
    //    maxV = getValue(bufferMat, k, 0);
    //    gaitRadInitial = getValue(bufferMat, k, 1);
    //    gaitIncrease = getValue(bufferMat, k, 2);
    //    v = getValue(bufferMat, k, 3);
    //    dir = getValue(bufferMat, k, 4);
    //        Serial.println("m: "+String(maxV)+" gr: "+String(gaitRadInitial)
    //        +" gi: "+String(gaitIncrease)+" v: "+String(v)
    //        +" dir: "+String(dir));
   
  }

}
void sendParamsToMini()
{
  //  delay(5);
  inBuffer = String(params[0]) + "_" + String(params[1]) + "_" +
             String(params[2]) + "_" + String(params[3]) + "_" + String(params[4])+"_";
  //start from version you want -1
  AS.println(inBuffer);
  //  Serial.println(inBuffer);
}
void readFromMini()
{
  inBuffer = "";
  while (AS.available() > 0)
  {
    char c = (char)AS.read();
    inBuffer = inBuffer + c;
  }
  //println appends CR=13=\r,LF=10=\n or \r\n
  if (inBuffer == "end")
  {
    Serial.println("end");
    stopProgram();
  }
  if (inBuffer != "")
  {
    if(inBuffer.startsWith("111",0))
    {
      sendParamsToMini();
    }
    else
    {
      Serial.print(inBuffer);
    }
  }
//  else
//  {
//    Serial.print("blah");
//  }
}


