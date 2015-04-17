#include "Functions.h"
#include <BiColorLED.h>
#include <Servo.h> 
#define leapTime 85
#define LED 13
/*servo left QTI== 7 edaalo fe a7a raa7 w fata7a RW speedB 5od w 2edeh o5d */
	
BiColorLED led = BiColorLED(A1, A2); // (pin 1, pin 2)

int frontUltraSonicSensor = 5, backUltraSonicSensor = 6, leftUltraSonicSensor = 7, rightUltraSonicSensor = 8; //Intializing Sensors with standard numbers 
int frontQti = 9, backQti = 10, leftQti = 11, rightQti = 12; 

int LWspeedF = 1550, LWspeedB = 1350, RWspeedF = 1350, RWspeedB = 1550, BWspeedF = 1550, BWspeedB = 1350; //Intializing speeds
int WheelInactive = 1500;

//Declaring wheels
Servo leftWheel;
Servo rightWheel;
Servo backWheel;

//Parallax Ultrasonic sensors and QTI Light Sensors Threshold 
const int ultrasonic_Thershold = 20; 
const int qtiThreshold = 40;


char mapp[150];
int replayStep = 0;
int directioncount = 0;
int shortDone;
bool replaystage = 0;


void setup()
{
	led.setColor(1);
	//delay(5000);//Light the LED
	led.setColor(0);

	leftWheel.attach(2);
	rightWheel.attach(3);
	backWheel.attach(4);

	Serial.begin(9600);
}


void loop()
{
	int x = directioncount;
	

		readSensors();
	if (frontUltrasonicTest() == 1 && //If we do not see a left or right turn and still on path
		(backQtiTest() == 'b' && frontQtiTest() == 'b') &&
		(leftQtiTest() == 'w' && rightQtiTest() == 'w'))
	{
		moveFront();
	}
	else {
		moveStandby();
		leftHandWall();
	}
	//For Debuging purposes 
	 
	if (x!= directioncount)
	{
		Serial.print("Last Direction Was "); Serial.print(mapp[directioncount - 1]); Serial.print("\n");

		Serial.print("Front UltraSonic: "); Serial.print(frontUltraSonicSensor);
		Serial.print("Back UltraSonic: "); Serial.print(backUltraSonicSensor);
		Serial.print("Left UltraSonic: "); Serial.print(leftUltraSonicSensor);
		Serial.print("Right UltraSonic: "); Serial.print(rightUltraSonicSensor);

	}
	

}

//////////////////////////ULTRASONIC SENSOR TEST///////////////////////////
int leftUltrasonicTest()
{
	unsigned int duration, centimeters;

	pinMode(leftUltraSonicSensor, OUTPUT);          // Set pin to OUTPUT
	digitalWrite(leftUltraSonicSensor, LOW);        // Ensure pin is low
	delayMicroseconds(2);
	digitalWrite(leftUltraSonicSensor, HIGH);       // Start ranging
	delayMicroseconds(5);              //   with 5 microsecond burst
	digitalWrite(leftUltraSonicSensor, LOW);        // End ranging
	pinMode(leftUltraSonicSensor, INPUT);           // Set pin to INPUT
	duration = pulseIn(leftUltraSonicSensor, HIGH); // Read echo pulse
	centimeters = duration / 29 / 2;        // Convert to centimeters

	if (centimeters>ultrasonic_Thershold)
	{
		return 1; //There Is no walll
	}
	else
	{
		return 0;
	}
}
int rightUltrasonicTest()
{
	unsigned int duration, centimeters;

	pinMode(rightUltraSonicSensor, OUTPUT);          // Set pin to OUTPUT
	digitalWrite(rightUltraSonicSensor, LOW);        // Ensure pin is low
	delayMicroseconds(2);
	digitalWrite(rightUltraSonicSensor, HIGH);       // Start ranging
	delayMicroseconds(5);              //   with 5 microsecond burst
	digitalWrite(rightUltraSonicSensor, LOW);        // End ranging
	pinMode(rightUltraSonicSensor, INPUT);           // Set pin to INPUT
	duration = pulseIn(rightUltraSonicSensor, HIGH); // Read echo pulse
	centimeters = duration / 29 / 2;        // Convert to centimeters

	if (centimeters>ultrasonic_Thershold)
	{
		return 1;
	}
	else{ return 0; }
}
int frontUltrasonicTest()
{
	unsigned int duration, centimeters;

	pinMode(frontUltraSonicSensor, OUTPUT);          // Set pin to OUTPUT
	digitalWrite(frontUltraSonicSensor, LOW);        // Ensure pin is low
	delayMicroseconds(2);
	digitalWrite(frontUltraSonicSensor, HIGH);       // Start ranging
	delayMicroseconds(5);              //   with 5 microsecond burst
	digitalWrite(frontUltraSonicSensor, LOW);        // End ranging
	pinMode(frontUltraSonicSensor, INPUT);           // Set pin to INPUT
	duration = pulseIn(frontUltraSonicSensor, HIGH); // Read echo pulse
	centimeters = duration / 29 / 2;        // Convert to centimeters

	if (centimeters>ultrasonic_Thershold)
	{
		return 1;
	}
	else{ return 0; }
}
int backUltrasonicTest()
{
	unsigned int duration, centimeters;

	pinMode(backUltraSonicSensor, OUTPUT);          // Set pin to OUTPUT
	digitalWrite(backUltraSonicSensor, LOW);        // Ensure pin is low
	delayMicroseconds(2);
	digitalWrite(backUltraSonicSensor, HIGH);       // Start ranging
	delayMicroseconds(5);              //   with 5 microsecond burst
	digitalWrite(backUltraSonicSensor, LOW);        // End ranging
	pinMode(backUltraSonicSensor, INPUT);           // Set pin to INPUT
	duration = pulseIn(backUltraSonicSensor, HIGH); // Read echo pulse
	centimeters = duration / 29 / 2;        // Convert to centimeters

	if (/*centimeters>ultrasonic_Thershold*/1)
	{
		return 1;
	}
	else{ return 0; }
}



void ultraS_Orient() //ULTRASONIC ORIENTATION FUNCTION FOR SWAPPING AFTER DIRECTION CHANGE
{
	char flag = mapp[directioncount-1];
	if (flag == 'L')
	{
		int temp;//Left sensor
		int temp2;
		temp = leftUltraSonicSensor;
		leftUltraSonicSensor = backUltraSonicSensor; //Left sensor done 
		backUltraSonicSensor = rightUltraSonicSensor;//back sensor done
		temp2 = frontUltraSonicSensor;
		frontUltraSonicSensor = temp;
		rightUltraSonicSensor = temp2;
	}
	if (flag == 'R')
	{
		int temp;//Left sensor
		int temp2;
		temp = frontUltraSonicSensor;
		frontUltraSonicSensor = rightUltraSonicSensor;
		temp2 = backUltraSonicSensor;
		backUltraSonicSensor = leftUltraSonicSensor;
		rightUltraSonicSensor = temp2;
		leftUltraSonicSensor = temp;
	}
	if (flag == 'B')
	{
		int temp;
		temp = frontUltraSonicSensor;
		frontUltraSonicSensor = backUltraSonicSensor;
		backUltraSonicSensor = temp;
		temp = rightUltraSonicSensor;
		rightUltraSonicSensor = leftUltraSonicSensor;
		leftUltraSonicSensor = temp;
	}

}
//////////////////////////END ULTRASONIC SENSOR TEST///////////////////////


/////////////////////////QTI LIGHT SENSORS////////////////////////////////

char frontQtiTest()
{
	long duration = 0;
	pinMode(frontQti, OUTPUT);     // Make pin OUTPUT
	digitalWrite(frontQti, HIGH);  // Pin HIGH (discharge capacitor)
	delay(1);                      // Wait 1ms
	pinMode(frontQti, INPUT);      // Make pin INPUT
	digitalWrite(frontQti, LOW);   // Turn off internal pullups
	while (digitalRead(frontQti)){  // Wait for pin to go LOW
		duration++;
	}

		if (duration>qtiThreshold)
		{
			return 'b';
		}
		else
		{
			return 'w';
		}
}
char backQtiTest()
{
	long duration = 0;
	pinMode(backQti, OUTPUT);     // Make pin OUTPUT
	digitalWrite(backQti, HIGH);  // Pin HIGH (discharge capacitor)
	delay(1);                      // Wait 1ms
	pinMode(backQti, INPUT);      // Make pin INPUT
	digitalWrite(backQti, LOW);   // Turn off internal pullups
	while (digitalRead(backQti)){  // Wait for pin to go LOW
		duration++;
	}
	if (duration>qtiThreshold)
	{
		return 'b';
	}
	else
	{
		return 'w';
	}
}
char leftQtiTest()
{
	long duration = 0;
	pinMode(leftQti, OUTPUT);     // Make pin OUTPUT
	digitalWrite(leftQti, HIGH);  // Pin HIGH (discharge capacitor)
	delay(1);                      // Wait 1ms
	pinMode(leftQti, INPUT);      // Make pin INPUT
	digitalWrite(leftQti, LOW);   // Turn off internal pullups
	while (digitalRead(leftQti)){  // Wait for pin to go LOW
		duration++;
	}
	if (duration>qtiThreshold)
	{
		return 'b';
	}
	else
	{
		return 'w';
	}
}
char rightQtiTest()
{
	long duration = 0;
	pinMode(rightQti, OUTPUT);     // Make pin OUTPUT
	digitalWrite(rightQti, HIGH);  // Pin HIGH (discharge capacitor)
	delay(1);                      // Wait 1ms
	pinMode(rightQti, INPUT);      // Make pin INPUT
	digitalWrite(rightQti, LOW);   // Turn off internal pullups
	while (digitalRead(rightQti)){  // Wait for pin to go LOW
		duration++;
	}
	if (duration>qtiThreshold)
	{
		return 'b';
	}
	else
	{
		return 'w';
	}
}


void qtiS_Orient()
{
	char flag = mapp[directioncount-1];
	if (flag == 'L')
	{
		int temp;//Left sensor
		int temp2;
		temp = leftQti;
		leftQti = backQti; //Left sensor done 
		backQti = rightQti;//back sensor done
		temp2 = frontQti;
		frontQti = temp;
		rightQti = temp2;
	}
	if (flag == 'R')
	{
		int temp;//Left sensor
		int temp2;
		temp = frontQti;
		frontQti = rightQti;
		temp2 = backQti;
		backQti = leftQti;
		rightQti = temp2;
		leftQti = temp;
	}
	if (flag == 'B')
	{
		int temp;
		temp = frontQti;
		frontQti = backQti;
		backQti = temp;
		temp = rightQti;
		rightQti = leftQti;
		leftQti = temp;
	}

}
///////////////////////QTI LIGHT SENSORS END/////////////////////////////


///////////////////////Wheels Movement//////////////////////////////////
void moveStandby() //putting wheels on standby 
{
	leftWheel.writeMicroseconds(WheelInactive);
	rightWheel.writeMicroseconds(WheelInactive);
	backWheel.writeMicroseconds(WheelInactive);
}

void moveFront()
{
	if (frontUltraSonicSensor == 5)
	{
		leftWheel.writeMicroseconds(LWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 6)
	{
		leftWheel.writeMicroseconds(LWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 7)
	{
		backWheel.writeMicroseconds(BWspeedF);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 8)
	{
		backWheel.writeMicroseconds(BWspeedB);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);

	}
	//recording the movement
	qtiS_Orient();//Reorinting
	ultraS_Orient();//Reorinting

	if (replaystage == 0)
	{
		mapp[directioncount] = 'F';
		directioncount++;

		if (mapp[directioncount - 2] == 'B')
		{
			shortPath();

		}

	}

}
void moveBack()
{
	if (frontUltraSonicSensor == 5)
	{
		leftWheel.writeMicroseconds(LWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		leftWheel.writeMicroseconds(LWspeedB);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 6)
	{
		leftWheel.writeMicroseconds(LWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		leftWheel.writeMicroseconds(LWspeedF);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 7)
	{
		backWheel.writeMicroseconds(BWspeedB);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 8)
	{
		backWheel.writeMicroseconds(BWspeedF);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);

	}
	//recording the movement
	qtiS_Orient();//Reorinting
	ultraS_Orient();//Reorinting
	if (replaystage == 0)
	{
		mapp[directioncount] = 'B';
		directioncount++;


		if (mapp[directioncount - 2] == 'B')
		{
			shortPath();

		}

	}

}
void moveLeft()
{
	if (frontUltraSonicSensor == 5)
	{
		backWheel.writeMicroseconds(BWspeedF);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 6)
	{
		backWheel.writeMicroseconds(BWspeedB);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 8)
	{
		leftWheel.writeMicroseconds(LWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		leftWheel.writeMicroseconds(LWspeedF);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 7)
	{
		leftWheel.writeMicroseconds(LWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		leftWheel.writeMicroseconds(LWspeedB);
		backWheel.writeMicroseconds(WheelInactive);

	}
	qtiS_Orient();//Reorinting
	ultraS_Orient();//Reorinting
	if (replaystage == 0)
	{
		mapp[directioncount] = 'L';
		directioncount++;


		if (mapp[directioncount - 2] == 'B')
		{
			shortPath();
		}
	}
}

void moveRight()
{
	if (frontUltraSonicSensor == 5)
	{
		backWheel.writeMicroseconds(BWspeedB);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 6)
	{
		backWheel.writeMicroseconds(BWspeedF);
		leftWheel.writeMicroseconds(WheelInactive);
		rightWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 8)
	{
		leftWheel.writeMicroseconds(LWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		rightWheel.writeMicroseconds(RWspeedB);
		leftWheel.writeMicroseconds(LWspeedB);
		backWheel.writeMicroseconds(WheelInactive);
	}
	else if (frontUltraSonicSensor == 7)
	{
		leftWheel.writeMicroseconds(LWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		rightWheel.writeMicroseconds(RWspeedF);
		leftWheel.writeMicroseconds(LWspeedF);
		backWheel.writeMicroseconds(WheelInactive);

	}
	qtiS_Orient();//Reorinting
	ultraS_Orient();//Reorinting
	if (replaystage == 0)
	{
		mapp[directioncount] = 'R';
		directioncount++;


		if (mapp[directioncount - 2] == 'B')
		{
			shortPath();
		}
	}
}
///////////////////////End Wheel Movement//////////////////////////////
void readSensors()
{ //reading the sensors 
	rightQtiTest();
	leftQtiTest();
	backQtiTest();
	frontQtiTest();
	frontUltrasonicTest();
	backUltrasonicTest();
	leftUltrasonicTest();
	rightUltrasonicTest();
}
//////////////////////START LEFT HANDWALL/////////////////////////////
void leftHandWall()
{
	readSensors();
	if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'w')
	{
		delay(leapTime);                     //leap
		readSensors();
		if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'w')
			done();
	}
	else if (leftQtiTest() == 'b'&& rightQtiTest() == 'b' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& leftUltrasonicTest() == 1)
	{
		moveLeft();
	}
	else if (leftQtiTest() == 'b'&& rightQtiTest() == 'b' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& leftUltrasonicTest() == 0 && frontUltrasonicTest() == 1)
	{
		moveFront();
	}
	else if (leftQtiTest() == 'b'&& rightQtiTest() == 'b' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& leftUltrasonicTest() == 0 && rightUltrasonicTest() == 1 && frontUltrasonicTest() == 0)
	{
		moveRight();
	}
	else if (leftQtiTest() == 'b'&& rightQtiTest() == 'b' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& leftUltrasonicTest() == 0 && rightUltrasonicTest() == 0 && frontUltrasonicTest() == 0)
	{
		moveBack();
	}
	else if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& frontUltrasonicTest() == 0)
	{
		moveBack();
	}
}
//////////////////////ENDLEFTHANDWALL////////////////////////////////


////////////////////START SHORTPATh//////////////////////////////////
void shortPath(){ 
	int shortDone = 0;
	if (mapp[directioncount - 3] == 'L' && mapp[directioncount - 1] == 'R'){
		directioncount -= 3;
		mapp[directioncount] = 'B';
		shortDone = 1;
	}
	if (mapp[directioncount - 3] == 'L' && mapp[directioncount - 1] == 'F' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'R';
		shortDone = 1;
	}
	if (mapp[directioncount - 3] == 'R' && mapp[directioncount - 1] == 'L' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'B';
		shortDone = 1;
	}
	if (mapp[directioncount - 3] == 'F' && mapp[directioncount - 1] == 'L' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'R';
		shortDone = 1;
	}
	if (mapp[directioncount - 3] == 'F' && mapp[directioncount - 1] == 'F' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'B';
		shortDone = 1;
	}
	if (mapp[directioncount - 3] == 'L' && mapp[directioncount - 1] == 'L' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'F';
		shortDone = 1;
	}
	mapp[directioncount + 1] = 'D';
	mapp[directioncount + 2] = 'D';
	directioncount++;
}
//////////////////////ENDSHORTPATH////////////////////////////////////////////

//////////////////////DONE////////////////////////////////////////////////////
void done()
{
	//Putting all wheels on standby
	leftWheel.writeMicroseconds(1500); 
	rightWheel.writeMicroseconds(1500);
	backWheel.writeMicroseconds(1500);

	replaystage = 1; // Setting The replaystage condition to True
	
	mapp[directioncount] = 'D';
	directioncount++;
	while ((leftQtiTest() == 'w') && (rightQtiTest() == 'w'))
	{
		led.setColor(2);
						 //Lighting the LED when finished 
	}
		led.setColor(0);
		
		//Lighting the LED Again before Starting 
	led.setColor(1);
	delay(4000);
	led.setColor(0);

	//Replying with the newely found values 
	replay();

}
///////////////////////ENDDONE///////////////////////////////////////////////

void replay(){

	readSensors();
	if ((leftQtiTest() == 'w') && (rightQtiTest() == 'w') && (frontQtiTest() == 'b') && (backQtiTest() == 'b'))
	{
		moveFront();
	}
	else{
		if (mapp[replayStep] == 'D')
		{
			endMotion();
		}
		if (mapp[replayStep] == 'L'){

			//delay(leapTime);
			moveLeft();
		}
		if (mapp[replayStep] == 'R'){

			//delay(leapTime);
			moveRight();
		}
		if (mapp[replayStep] == 'F'){

			//delay(leapTime);
			moveFront();
		}
		replayStep++;
	}
	replay();
}
void endMotion(){
	leftWheel.writeMicroseconds(1500);
	rightWheel.writeMicroseconds(1500);
	backWheel.writeMicroseconds(1500);
	while ((leftQtiTest() == 'w') && (rightQtiTest() == 'w'))
	{
		led.setColor(1);
	}
		led.setColor(0);
}

