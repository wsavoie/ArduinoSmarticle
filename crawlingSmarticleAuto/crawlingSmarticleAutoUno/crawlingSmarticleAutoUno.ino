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
SoftwareSerial AS(8,9);

int dir =0;
bool writeYes=true;

///////////start up variables to write to pro mini//////////
int maxV = 2;           //number of trials for each radius
int gaitRadInitial = 30;//initial gait radius
int gaitIncrease = 1;   //amount to increase gait radius
int v = 1;              //current trial number
////////////////////////////////////////////////////////////

void setup() 
{
  //read sensor data
  pinMode(front, INPUT);
  pinMode(back, INPUT);
  
  dir=0;
//dir=v%2+1; //odd if v is odd dir=2, if even dir=1
  //pinMode(proDirPin,OUTPUT);
  
  AS.begin(9600);
  Serial.begin(9600); //serial to matlab
  delay(500);
  
//  if(writeYes)
//  {
//    inBuffer= String(maxV)+"_"+String(gaitRadInitial)+"_"+
//    String(gaitIncrease)+"_"+String(v)+"_"+String(dir);
//  //start from version you want -1
//    AS.print(inBuffer);
//  }
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
        dir=2;//set new dir to front
        AS.write(dir);
//        Serial.println("Go Back"); 
    
      }
      else if(valB){
        dir=1;//set new dir to front
        AS.write(dir);
//        Serial.println("Go Front");     
      }

      break;
    case 1: //polling front side, read front
      
      valF=readSensor(analogRead(front));
//       Serial.println("front:"+String(analogRead(front)));
      if(valF){
        dir=2;
        AS.write(dir);
//         Serial.println("Go Back"); 
      }
      break;
    case 2: //towards back
      valF=readSensor(analogRead(back));
//      Serial.println("back:"+String(analogRead(back)));
      if(valF){
          dir=1;
          AS.write(dir);
//          Serial.println("Go Front");
      }
      break; 
  }
///////since serialEvent I dont think will work////////
  inBuffer="";
  while(AS.available())
  {
    char c = AS.read();
    inBuffer = inBuffer+c;
    
//    Serial.print(AS.read());
    delay(1);
  }
  //println appends CR=13=\r,LF=10=\n or \r\n 
  if(inBuffer=="end")
  {
    Serial.println("end");
    stopProgram();
  }
  if(inBuffer!="")
  {
  Serial.print(inBuffer);
  }

  /////////////////////////////////////////////////////
}

int readSensor(int sensorResult)
{
  //if using analog read, this function takes read result and
  //does thresholding to determine binary signal output 
  //needs to be ">"because it is high when covered
//  Serial.println(sensorResult);
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
  {
    Serial.print("restart uno and mini\r\n");
    delay(1000);
  }
}
//void serialEvent() {
//
//}
