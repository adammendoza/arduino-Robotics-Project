/*
Known Bugs:
1- Threshold for Ping Ultrasonic Sensor Needs to be adjusted.
2- Array Function needs to be implemented so that we can store descions
3- Line Following needs to be implemeted with the Replay function
*/


#include <BiColorLED.h>
#include <Servo.h> 
#define leapTime 85
#define LED 13

	
BiColorLED led = BiColorLED(A0, A1); // (pin 1, pin 2)

int frontUltraSonicSensor = 8, backUltraSonicSensor = 9, leftUltraSonicSensor = 10, rightUltraSonicSensor = 11; //Intializing Sensors with standard numbers 
int frontQti = 4, backQti = 5, leftQti = 6, rightQti = 7; 

int pins = 0;
int vL, vR, vB;

int LWspeedF = 1550, LWspeedB = 1350, RWspeedF = 1350, RWspeedB = 1550, BWspeedF = 1550, BWspeedB = 1350; //Intializing speeds
int WheelInactive = 1500;

//Declaring wheels
Servo leftWheel;
Servo rightWheel;
Servo backWheel;

//Parallax Ultrasonic sensors and QTI Light Sensors Threshold 
const int ultrasonic_Thershold = 5; 
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
	backWheel.attach(12);

	Serial.begin(9600);
}


void loop()
{
	

	if (frontUltrasonicTest() == 1 && //If we do not see a left or right turn and still on path
		(backQtiTest() == 'b' && frontQtiTest() == 'b') &&
		(leftQtiTest() == 'w' && rightQtiTest() == 'w'))
	{
		moveFront();
	}
	else if ((backQtiTest() == 'b' && frontQtiTest() == 'b') &&
		(leftQtiTest() == 'b' && rightQtiTest() == 'b')) {
		//moveStandby();
		leftHandWall();
	}
	else if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& frontUltrasonicTest() == 0)
	{
		moveBack();
	}
	else
	{
		lineFollowing();
	} 
	 

	

}
//////////////////////////Line following function//////////////////////////
void lineFollowing()
{
	DDRD |= B11110000;                         // Set direction of Arduino pins D4-D7 as OUTPUT
	PORTD |= B11110000;                        // Set level of Arduino pins D4-D7 to HIGH
	delayMicroseconds(230);                    // Short delay to allow capacitor charge in QTI module
	DDRD &= B00001111;                         // Set direction of pins D4-D7 as INPUT
	PORTD &= B00001111;                        // Set level of pins D4-D7 to LOW
	delayMicroseconds(230);                    // Short delay
	pins = PIND;                           // Get values of pins D0-D7
	pins >>= 4;                                // Drop off first four bits of the port; keep only pins D4-D7

	Serial.println(pins, BIN);                 // Display result of D4-D7 pins in Serial Monitor

	// Determine how to steer based on state of the four QTI sensor
	switch (pins)                               // Compare pins to known line following states
	{
	case B0011:
		vL = 100;                             // -100 to 100 indicate course correction values
		vR = 100;
		vB = 0;
		Serial.println("Foward Case");        //Debug                            // -100: full reverse; 0=stopped; 100=full forward
		break;
	case B0111:                               //Sliding Right Case
		vL = 100;
		vR = 130;
		vB = 0;
		Serial.println("Sliding Right Case");
		break;
	case B1011:                        //Sliding left Case 
		vL = 130;
		vR = 100;
		vB = 0;
		Serial.println("Sliding Left Case");
		break;
	case B1111:                        // Intersection Case 
		vL = 0;
		vR = 0;
		vB = 0;
		break;
	case B0000:                        // White space case 
		vL = 0;
		vR = 0;
		vB = 0;
		Serial.println("White Case");
		break;
	case B1010:                        // Diagonal Left case
		vL = 90;
		vR = 0;
		vB = 0;
		Serial.println("Diagonal Left Case");
		break;
	case B0110:                       //Diagonmal Right
		vL = 0;
		vR = 90;
		vB = 0;
		Serial.println("Diagonal Right Case");
		break;
	case B0100:                        // Way off right case
		vL = -80;
		vR = 110;
		vB = -90;
		Serial.println("Way off Right Case");
		break;
	case B1000:                        //Way off left case
		vL = 110;
		vR = -80;
		vB = 90;
		Serial.println("Way off Left Case");
		break;
	}
	leftWheel.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
	rightWheel.writeMicroseconds(1500 - vR);
	backWheel.writeMicroseconds(1500 - vB);
	//delay(45);                                // Delay for 50 milliseconds (1/20 second)


	if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'w')
	{
		readSensors();
		delay(leapTime);                     //leap
		if (leftQtiTest() == 'w'&& rightQtiTest() == 'w' && frontQtiTest() == 'w')
			done();
	}
	
}

/////////////////////End Line following function//////////////////////////
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
	DDRD |= B11110000;                         // Set direction of Arduino pins D4-D7 as OUTPUT
	PORTD |= B11110000;                        // Set level of Arduino pins D4-D7 to HIGH
	delayMicroseconds(230);                    // Short delay to allow capacitor charge in QTI module
	DDRD &= B00001111;                         // Set direction of pins D4-D7 as INPUT
	PORTD &= B00001111;                        // Set level of pins D4-D7 to LOW
	delayMicroseconds(230);                    // Short delay
	pins = PIND;                           // Get values of pins D0-D7
	pins >>= 4;                                // Drop off first four bits of the port; keep only pins D4-D7

	Serial.println(pins, BIN);                 // Display result of D4-D7 pins in Serial Monitor

	// Determine how to steer based on state of the four QTI sensor
	switch (pins)                               // Compare pins to known line following states
	{
	case B0011:
		vL = 100;                             // -100 to 100 indicate course correction values
		vR = 100;
		vB = 0;
		Serial.println("Foward Case");        //Debug                            // -100: full reverse; 0=stopped; 100=full forward
		break;
	case B0111:                               //Sliding Right Case
		vL = 100;
		vR = 130;
		vB = 0;
		Serial.println("Sliding Right Case");
		break;
	case B1011:                        //Sliding left Case 
		vL = 130;
		vR = 100;
		vB = 0;
		Serial.println("Sliding Left Case");
		break;
	case B1111:                        // Intersection Case 
		vL = 0;
		vR = 0;
		vB = 0;
		break;
	case B0000:                        // White space case 
		vL = 0;
		vR = 0;
		vB = 0;
		Serial.println("White Case");
		break;
	case B1010:                        // Diagonal Left case
		vL = 90;
		vR = 0;
		vB = 0;
		Serial.println("Diagonal Left Case");
		break;
	case B0110:                       //Diagonmal Right
		vL = 0;
		vR = 90;
		vB = 0;
		Serial.println("Diagonal Right Case");
		break;
	case B0100:                        // Way off right case
		vL = -80;
		vR = 110;
		vB = -90;
		Serial.println("Way off Right Case");
		break;
	case B1000:                        //Way off left case
		vL = 110;
		vR = -80;
		vB = 90;
		Serial.println("Way off Left Case");
		break;
	}

	leftWheel.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
	rightWheel.writeMicroseconds(1500 - vR);
	backWheel.writeMicroseconds(1500 - vB);
	delay(45);


}
void moveBack()
{
	moveRight();
	moveRight();

}
void moveLeft()
{
	Serial.println(pins, BIN);                 // Display result of D4-D7 pins in Serial Monitor

	vL = -120;
	vR = 120;
	vB = 100;
	leftWheel.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
	rightWheel.writeMicroseconds(1500 - vR);
	backWheel.writeMicroseconds(1500 - vB);
	Serial.println("Left");
	delay(435);
	pushFront();
}

void moveRight()
{ 

	vL = 120;
	vR = -120;
	vB = -100;
	leftWheel.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
	rightWheel.writeMicroseconds(1500 - vR);
	backWheel.writeMicroseconds(1500 - vB);
	Serial.println("Right");
	delay(435);
	pushFront();
}
///////////////////////End Wheel Movement//////////////////////////////
void readSensors()//For debugging purposes
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
	if (leftQtiTest() == 'b'&& rightQtiTest() == 'b' && frontQtiTest() == 'b'&&backQtiTest() == 'b'&& leftUltrasonicTest() == 1)
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
//	delay(leapTime);                     //leap

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
	else if (mapp[directioncount - 3] == 'L' && mapp[directioncount - 1] == 'F' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'R';
		shortDone = 1;
	}
	else if (mapp[directioncount - 3] == 'R' && mapp[directioncount - 1] == 'L' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'B';
		shortDone = 1;
	}
	else if (mapp[directioncount - 3] == 'F' && mapp[directioncount - 1] == 'L' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'R';
		shortDone = 1;
	}
	else if (mapp[directioncount - 3] == 'F' && mapp[directioncount - 1] == 'F' && shortDone == 0){
		directioncount -= 3;
		mapp[directioncount] = 'B';
		shortDone = 1;
	}
	else if (mapp[directioncount - 3] == 'L' && mapp[directioncount - 1] == 'L' && shortDone == 0){
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
	delay(10000);
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
	else if ((leftQtiTest() == 'b') && (rightQtiTest() == 'b') && (frontQtiTest() == 'b') && (backQtiTest() == 'b'))
		{
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

void pushFront()
{
	vL = 100;                             // -100 to 100 indicate course correction values
	vR = 100;
	vB = 0;
	leftWheel.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
	rightWheel.writeMicroseconds(1500 - vR);
	backWheel.writeMicroseconds(1500 - vB);
}
