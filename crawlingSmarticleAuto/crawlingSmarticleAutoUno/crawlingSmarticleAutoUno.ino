#include <AltSoftSerial.h> 
//on uno and promini
//TX=9 RX=8
int front = A1; //photoresistor top of plate
int back = A5; //photoresistor at bottom of plate

String inBuffer;
int valF = 0;
int valB = 0;
int dir =0;
int thresh = 700;
AltSoftSerial AS;
void setup() 
{
//read sensor data
pinMode(front, INPUT);
pinMode(back, INPUT);

//send direction to pro mini
//pinMode(proDirPin,OUTPUT);

AS.begin(9600);
Serial.begin(9600); //serial to matlab
Serial.write("yoyoyo");
}

void loop()
{
  
  switch(dir)
  {
    case 0: //unknown starting direction
      valF=readSensor(analogRead(front));
      valB=readSensor(analogRead(back));
//      Serial.println();        
      if(valF){
        dir=-1;//set new dir to front
        AS.write(dir);
        Serial.println("Go Back"); 
    
      }
      else if(valB){
        dir=1;//set new dir to front
        AS.write(dir);
        Serial.println("Go Front");     
      }

      break;
    case 1: //polling front side, read front
      valF=readSensor(analogRead(front));
      if(valF){
        dir=-1;
        AS.write(dir);
         Serial.println("Go Back"); 
      }
      break;
    case -1: //towards back
      valF=readSensor(analogRead(back));
      if(valF){
          dir=1;
          AS.write(dir);
          Serial.println("Go Front");
      }
      break; 
  }
///////since serialEvent I dont think will work////////
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
  if(inBuffer!="")
  {
  inBuffer=String(dir)+inBuffer;
  Serial.println(inBuffer);
  delay(5000);
  }

  /////////////////////////////////////////////////////
}

int readSensor(int sensorResult)
{
  //if using analog read, this function takes read result and
  //does thresholding to determine binary signal output 
  //needs to be ">"because it is high when covered
  //Serial.println(valB);
  if (sensorResult>thresh){  
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
  while(1)
  {}
}
//void serialEvent() {
//
//}
