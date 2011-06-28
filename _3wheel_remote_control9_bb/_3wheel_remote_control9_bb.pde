#include "Psx_analog.h"                                          // Includes the Psx Library 

//pins on PSX wireless receiver
#define dataPin 3
#define cmndPin 4
#define attPin 5
#define clockPin 12
//motor control pins
unsigned char M1=6;     
unsigned char E1=7;
unsigned char E2=10;
unsigned char M2=11;

//expansion board - m3 & m4
unsigned char E3=9;
unsigned char M3=8;
//unsigned char E4=10;
//unsigned char M4=11;

#define center  0x7F

Psx Psx;                                                  // Initializes the library

void setup()
{
  Psx.setupPins(dataPin, cmndPin, attPin, clockPin);  // Defines what each pin is used
  // (Data Pin #, Cmnd Pin #, Att Pin #, Clk Pin #)

  Psx.initcontroller(psxAnalog);    

  Serial.begin(9600); 
  Serial.println("Raw controller values");

  // wait for the long string to be sent 
  delay(100); 


}


void advance()
{
  analogWrite(E1,0);
  digitalWrite(M1,LOW);
  analogWrite(E2,100);
  digitalWrite(M2,LOW);
  analogWrite(E3,100);
  digitalWrite(M3,HIGH);
  return;
}

void goback()
{
  analogWrite(E1,0);
  digitalWrite(M1,LOW);
  analogWrite(E2,100);
  digitalWrite(M2,HIGH);
  analogWrite(E3,100);
  digitalWrite(M3,LOW);
  return;
}

void rotate_anticlk()
{
  analogWrite(E2,100);
  digitalWrite(M2,HIGH);
  analogWrite(E1,100);
  digitalWrite(M1,HIGH);
  analogWrite(E3,100);
  digitalWrite(M3,HIGH);  
}

void rotate_clk()
{
  analogWrite(E2,100);
  digitalWrite(M2,LOW);
  analogWrite(E1,100);
  digitalWrite(M1,LOW);
  analogWrite(E3,100);
  digitalWrite(M3,LOW);
  return;
}

void softright() {
  analogWrite(E2,100);
  digitalWrite(M2,LOW);
  analogWrite(E1,50);
  digitalWrite(M1,LOW);
  analogWrite(E3,50);
  digitalWrite(M3,HIGH);  
  return;
}

void softleft() {
  analogWrite(E2,50);
  digitalWrite(M2,LOW);
  analogWrite(E1,50);
  digitalWrite(M1,HIGH);
  analogWrite(E3,100);
  digitalWrite(M3,HIGH);  
  return;
}

void backright() {
  analogWrite(E2,50);
  digitalWrite(M2,HIGH);
  analogWrite(E1,100);
  digitalWrite(M1,LOW);
  analogWrite(E3,100);
  digitalWrite(M3,LOW);  
  return;
}

void backleft() {
  analogWrite(E2,100);
  digitalWrite(M2,HIGH);
  analogWrite(E1,100);
  digitalWrite(M1,HIGH);
  analogWrite(E3,50);
  digitalWrite(M3,LOW);  
  return;
}

void stop()
{
  analogWrite(E1,0);
  digitalWrite(M1,HIGH);
  analogWrite(E2,0);
  digitalWrite(M2,HIGH);
  analogWrite(E3,0);
  digitalWrite(M3,HIGH);
  return;
}  

void loop()
{
  Psx.poll();                                      // Psx.read() initiates the PSX controller and returns

  if (Psx.digital_buttons & psxTri){
    Serial.println("Triangle Pressed");
    advance();
  }
  if (Psx.digital_buttons & psxX)                                      
    goback();
  if (Psx.digital_buttons & psxLeft)                                       
    rotate_anticlk();                                         
  if (Psx.digital_buttons & psxRight)                                       
    rotate_clk();
  if ((Psx.digital_buttons & psxRight) && (Psx.digital_buttons & psxTri))
    softright();
  if ((Psx.digital_buttons & psxLeft) && (Psx.digital_buttons & psxTri))
    softleft();
  if ((Psx.digital_buttons & psxLeft) && (Psx.digital_buttons & psxX))
    backleft();
  if ((Psx.digital_buttons & psxRight) && (Psx.digital_buttons & psxX))
    backright();

  delay(50); 
  stop(); 

}


