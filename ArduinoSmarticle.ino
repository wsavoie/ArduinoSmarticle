#include <Servo.h>
#define myabs(n) ((n) < 0 ? -(n) : (n))
//pin definitions
#define servo1 5 	//D9
#define servo2 6 	//D10
#define mic     A0       //D3
#define stressPin A1	//A2
#define led 13   	//13 SCK

#define stressMoveThresh 2


// SoftwareServo S1;
// SoftwareServo S2;
Servo S1;
Servo S2;
uint8_t stress = 0;
uint16_t samps = 9; 
uint16_t micMean = 512;
uint16_t const del = 200;
uint8_t stressCount = 0;
uint16_t rangeType=0;
uint8_t thresh = 25;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t matchCount = 0;
uint16_t prevVal = 0;

int oldVal	= 0;
int newVal	= 0;
int diff 	= 0;
int curr 	= 0;


void moveMotor(uint8_t pos);
void currentRead(uint16_t meanCurrVal);
void getRange(uint16_t ftVal);
void light(bool a);
void setup() {
	// SoftwareServo
	// S1.attach(servo1);
	// S2.attach(servo2);
	// S1.setMinimumPulse(600);
	// S2.setMinimumPulse(600);
	// S1.setMaximumPulse(2400);
	// S2.setMaximumPulse(2400);
	
	S1.attach(servo1);
	S2.attach(servo2);

	pinMode(led,OUTPUT);
	
	pinMode(stress,INPUT);
	pinMode(mic,INPUT);
     //Serial.begin(9600);
    // Serial.println("Ready");
}

void loop() 
{          
	bool a = false;
	int midPtCross = 0;
	int meanCurr = 0;
        oldVal = 0;
	
	for (int i = 0; i < 1<<samps; i++)
	{
		oldVal		= newVal;
		curr 		= analogRead(stressPin);
		newVal		= analogRead(mic);

		meanCurr	= meanCurr+curr;
		int aa= newVal > micMean;
		int bb= oldVal > micMean;
		diff = (newVal > micMean) - (oldVal > micMean);
		diff = aa - bb;
		diff = myabs(diff);
                //diff= abs(diff);        
	
		midPtCross = midPtCross + diff;
                
	}
	
	//bitshift divide by sample, meancurr=meancurr/(2^samps)
	meanCurr >>= samps;
	//currentRead(meanCurr);
	
	//if(stressCount<stressMoveThresh || rangeType==6 || rangeType==7) //if previous moves were 6 or 7, continue without stress
	//{
		getRange(midPtCross);
	//}
	
        //light(a);
	delay(del);
}

void currentRead(uint16_t meanCurrVal)
{
	if(meanCurrVal<10)//make magic number into meaningful value!!
	{
		stressCount = 0;
	}
	else
	{
		stressCount++;
		if(stressCount>=stressMoveThresh && rangeType!=6 && rangeType!=7)
		{
			(stress > 1 ? stress=0 : (stress++));
			moveMotor(stress);
		}	
		delay(del);
	}
	
}

void getRange(uint16_t ftVal)// at thresh = 50, thresh = 216-433-650
{  
	bool a = false;
	rangeType=0;
       
	if (ftVal < thresh*2)                            
		rangeType = 1;
	else if ((ftVal>=2*thresh) && (ftVal<3*thresh))//216-433
		rangeType = 2;
	else if ((ftVal>=3*thresh) && (ftVal<4*thresh))//433-650
		rangeType = 3;
	else if ((ftVal>=4*thresh) && (ftVal<5*thresh))//433-650
		rangeType = 4;
	else if ((ftVal>=5*thresh) && (ftVal<6*thresh))//433-650
		rangeType = 5;
	else if ((ftVal>=6*thresh) && (ftVal<7*thresh))//433-650
		rangeType = 6;
	else if ((ftVal>=7*thresh) && (ftVal<8*thresh))//433-650
		rangeType = 7;
	else
		rangeType = 8;
     if (rangeType==3)
        {a = true;}
        else
        {a=false;}
	light(a);
  if (rangeType != prevVal)
  { 
    prevVal = rangeType;
    matchCount=0;
    delay(del);
    return;
  }
  matchCount++;
  prevVal = rangeType;
  
  if(matchCount < 2 )
  {
    delay(del);
    return;
  }
  moveMotor(rangeType);
}
void moveMotor(uint8_t pos) //break method into chunks to allow "multithreading"
{
	// switch (pos)
	// { ///1500 = straight out, my 0 degrees servo's 90 degrees
	// case 0:
		// S1.write(1500); 
		// S2.write(1500);
		// S1.write(1500); 
		// S2.write(1500);
	  // break;
	// case 1:
		// S1.write(1500 - 300);
		// S2.write(1500 + 300);
		// break;
	// case 2:
		// S1.write(1500 + 300);
		// S2.write(1500 - 300);
	  // break;
	// case 3:
		// S1.write(1500 + 900);
		// S2.write(1500 - 900);
	  // break;
	// case 4:
		// S1.write(1500 - 900);
		// S2.write(1500 + 900);
	  // break;
	// case 5:
		// S1.write(1500 + 900);
		// S2.write(1500 + 900);
	  // break;
	// case 6:
		// S1.write(maxx * 10 + 600);
		// S2.write((minn) * 10 + 600);
		// delay(del);

		// S1.write(maxx * 10 + 600);
		// S2.write((maxx) * 10 + 600);
		// delay(del);

		// S1.write(minn * 10 + 600);
		// S2.write((maxx) * 10 + 600);
		// delay(del);

		// S1.write(minn * 10 + 600);
		// S2.write((minn) * 10 + 600);
		// delay(del);
		// break;
	// case 7:
		// //S1.write(maxx * 10 + 600);
		// //S2.write((midd) * 10 + 600);
		// //delay(del);
		// //S1.write(midd * 10 + 600);
		// //S2.write((maxx) * 10 + 600);
		// //delay(del);
		// //S1.write(minn * 10 + 600);
		// //S2.write((midd) * 10 + 600);
		// //delay(del);
		// //S1.write(midd * 10 + 600);
		// //S2.write((minn) * 10 + 600);
		// //delay(del);
		// //S1.write(maxx * 10 + 600);
		// //S2.write((midd) * 10 + 600);


		// S1.write(maxx * 10 + 600);
		// S2.write((midd) * 10 + 600);
		// delay(del*2);
		// S1.write(midd * 10 + 600);
		// S2.write((midd) * 10 + 600);
		// delay(del*2);
		// S1.write(midd * 10 + 600);
		// S2.write((minn) * 10 + 600);
		// delay(del*2);
		// S1.write(maxx * 10 + 600);
		// S2.write((minn) * 10 + 600);
		// //S1.write(maxx * 10 + 600);
		// //S2.write((midd) * 10 + 600);

		// //delay(del/2);
		// break;
	// case 8:
		// S1.write(1500 + 900);
		// S2.write(1500 - 900);
		// break;
	// }
	
	
	
switch (pos)
{ ///1500 = straight out, my 0 degrees servo's 90 degrees
    case 0:
          S1.writeMicroseconds(1500);
          S2.writeMicroseconds(1500);
          break;
    case 1:
          S1.writeMicroseconds(1500 - 300);
          S2.writeMicroseconds(1500 + 300);
          break;
    case 2:
          S1.writeMicroseconds(1500 + 300);
          S2.writeMicroseconds(1500 - 300);
          break;
    case 3:
          S1.writeMicroseconds(1500 + 900);
          S2.writeMicroseconds(1500 - 900);
          break;
    case 4:
          S1.writeMicroseconds(1500 - 900);
          S2.writeMicroseconds(1500 + 900);
          break;
    case 5:
          S1.writeMicroseconds(1500 + 900);
          S2.writeMicroseconds(1500 + 900);
          break;
    case 6:
          S1.writeMicroseconds(maxx * 10 + 600);
          S2.writeMicroseconds((minn) * 10 + 600);
          _delay_ms(del);
    
          S1.writeMicroseconds(maxx * 10 + 600);
          S2.writeMicroseconds((maxx) * 10 + 600);
          _delay_ms(del);
    
          S1.writeMicroseconds(minn * 10 + 600);
          S2.writeMicroseconds((maxx) * 10 + 600);
          _delay_ms(del);
    
          S1.writeMicroseconds(minn * 10 + 600);
          S2.writeMicroseconds((minn) * 10 + 600);
          
          break;
    case 7:
          //S1.writeMicroseconds(maxx * 10 + 600);
          //S2.writeMicroseconds((midd) * 10 + 600);
          //_delay_ms(del);
          //S1.writeMicroseconds(midd * 10 + 600);
          //S2.writeMicroseconds((maxx) * 10 + 600);
          //_delay_ms(del);
          //S1.writeMicroseconds(minn * 10 + 600);
          //S2.writeMicroseconds((midd) * 10 + 600);
          //_delay_ms(del);
          //S1.writeMicroseconds(midd * 10 + 600);
          //S2.writeMicroseconds((minn) * 10 + 600);
          //_delay_ms(del);
          //S1.writeMicroseconds(maxx * 10 + 600);
          //S2.writeMicroseconds((midd) * 10 + 600);
    	  
    	  
          S1.writeMicroseconds(maxx * 10 + 600);
          S2.writeMicroseconds((midd) * 10 + 600);
          _delay_ms(del*2);
          S1.writeMicroseconds(midd * 10 + 600);
          S2.writeMicroseconds((midd) * 10 + 600);
          _delay_ms(del*2);
          S1.writeMicroseconds(midd * 10 + 600);
          S2.writeMicroseconds((minn) * 10 + 600);
          _delay_ms(del*2);
          S1.writeMicroseconds(maxx * 10 + 600);
          S2.writeMicroseconds((minn) * 10 + 600);
          //S1.writeMicroseconds(maxx * 10 + 600);
          //S2.writeMicroseconds((midd) * 10 + 600);
    	  
          //_delay_ms(del/2);
          break;
    case 8:
          S1.writeMicroseconds(1500 + 900);
          S2.writeMicroseconds(1500 - 900);
          break;
  }
}
void light(bool a)
{ 
	if (a)
		digitalWrite(led, HIGH);
	else
		digitalWrite(led, LOW);
}



