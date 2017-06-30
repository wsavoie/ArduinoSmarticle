#include <AltSoftSerial.h> 
//on uno and promini
//TX=9 RX=8
int front = A0; //photoresistor top of plate
int back = A2; //photoresistor at bottom of plate

String inBuffer;
int valF = 0;
int valB = 0;
int dir =0;
int thresh = 512;
AltSoftSerial AS;
void setup() 
{
//read sensor data
pinMode(front, INPUT);
pinMode(back, INPUT);

//send direction to pro mini
pinMode(proDirPin,OUTPUT);

AS.begin(9600);
Serial.begin(9600); //serial to matlab
}

void loop()
{
  
  switch(dir)
  {
    case 0: //unknown starting direction
      valF=readSensor(analogRead(front));
      valB=readSensor(analogRead(back));
      if(valF){
        dir=-1;//set new dir to front
        AS.write(dir);
      }
      else if(valB){
        dir=1;//set new dir to front
        AS.write(dir);
      }
      break;
    case 1: //polling front side, read front
      valF=readSensor(analogRead(front));
      if(valF){
        dir=-1;
        AS.write(dir);
      }
      break;
    case -1: //towards back
      valF=readSensor(analogRead(back));
      if(valF){
          dir=1;
          AS.write(dir);
      }
      break; 
  }
}

int readSensor(int sensorResult)
{
  //if using analog read, this function takes read result and
  //does thresholding to determine binary signal output 
  if (sensorResult>thresh)
    return 1;
  else
    return 0;
}
void stopProgram()
{
  while(1)
  {}
}
void serialEvent() {
  inBuffer="";
  while(AS.available()> 0)
  {
    inBuffer =  inBuffer+AS.read();
  }
  if(inBuffer=="end")
  {
    Serial.println("end");
    stopProgram();
  }
  inBuffer=String(dir)+inBuffer;
  Serial.println(inBuffer);
}
