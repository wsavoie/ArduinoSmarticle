#ifndef Gaits_h
#define Gaits_h
int rightSquare [4] [2] = {
 	{val,val},
 	{val,val},
	{val,val},
	{val,val}
};
int rightSquare[];


//if I want to edit an array passed 
void loop()
{
 byte data[2];

 getdat(&data,2);
}

void getdat(byte *pdata,int sizeofArray)
{
 pdata[0] = 'a';
 pdata[1] = 'b';
}


#endif
