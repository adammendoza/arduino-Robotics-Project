#include <Servo.h>                           // Use the Servo library (included with Arduino IDE)  

Servo servoL;                                // Define the left and right servos
Servo servoR;
Servo servoB;                                // Define back motor

// Perform these steps with the Arduino is first powered on
void setup()
{
  Serial.begin(9600);                       // Set up Arduino Serial Monitor at 9600 baud
  servoL.attach(2);                         // Attach Left motor to pin 2
  servoR.attach(3);                         // Attatch Right motor to pin 3
  servoB.attach(12);                        //Attach Back motor to pin 12
}

// This code repeats indefinitely
void loop()
{
  DDRD |= B11110000;                         // Set direction of Arduino pins D4-D7 as OUTPUT
  PORTD |= B11110000;                        // Set level of Arduino pins D4-D7 to HIGH
  delayMicroseconds(230);                    // Short delay to allow capacitor charge in QTI module
  DDRD &= B00001111;                         // Set direction of pins D4-D7 as INPUT
  PORTD &= B00001111;                        // Set level of pins D4-D7 to LOW
  delayMicroseconds(230);                    // Short delay
  int pins = PIND;                           // Get values of pins D0-D7
  pins >>= 4;                                // Drop off first four bits of the port; keep only pins D4-D7
  
  Serial.println(pins, BIN);                 // Display result of D4-D7 pins in Serial Monitor
  
  // Determine how to steer based on state of the four QTI sensors
  int vL, vR, vB;
  switch(pins)                               // Compare pins to known line following states
  {
    case B0011:                        
      vL = 100;                             // -100 to 100 indicate course correction values
      vR = 100;  
      vB = 0;
      Serial.println("Foward Case");        //Debug                            // -100: full reverse; 0=stopped; 100=full forward
      break;
    case B0111:                               //Sliding Right Case
      vL = 80;
      vR = 120;
      vB = 0;
      Serial.println("Sliding Right Case");
      break;
    case B1011:                        //Sliding left Case 
      vL = 120;
      vR = 80;
      vB = 0;
      Serial.println("Sliding Left Case");
      break;
    case B1111:                        // Intersection Case 
      vL = 0;
      vR = 0;
      vB = 0;
      Serial.println("Intersection Case");
      break;  
    case B0000:                        // White space case 
      vL = 0;
      vR = 0;
      vB = 0;
      Serial.println("White Case");
      break;
    case B1010:                        // Diagonal Left case
      vL = 100;
      vR = 0;
      vB = 0;
      Serial.println("Diagonal Left Case");
      break;
    case B0110:                       //Diagonal Right
      vL = 0;
      vR = 100;
      vB = 0;
      Serial.println("Diagonal Right Case");
      break;
    case B0100:                        // Way off left case
      vL = -90;
      vR = 0;
      vB = -90;
      Serial.println("Way off left Case");
      break;
    case B1000:                        //Way off right case
      vL = 0;
      vR = -90;
      vB = 90;
      Serial.println("Way off right Case");
      break;
  }
  
  servoL.writeMicroseconds(1500 + vL);      // Steer robot to recenter it over the line
  servoR.writeMicroseconds(1500 - vR);
  servoB.writeMicroseconds(1500 - vB);
  delay(50);                                // Delay for 50 milliseconds (1/20 second)
}
