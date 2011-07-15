/**********************************D I A G R A M ***********************************
Please set up your robot according to this diagram.  Sonar 0x14 is optional.
                                                          
                                                           IR_Center : 1 
                                                 ------------------------------
            Positif way of rotation :           |                             |
                   ___                        M3|                             |M2                   
                 /                              |                             |
                |                               |                             |                             |                             |
                 \--->                          |                             |
                                     IR_left : 2|                             |IR_Right : 0
                        X                       |                             |
                        ^                       |                             |
                        |                       |                             |
                        |                       |                             |Power Switch
                        |                       |                             |
                        |                       -------------------------------
          Y <-----------0                       |                             |
                                              M4|                             |M1
                                                |                             |
                                                -------------------------------
                                            
***********************************************************************************/

///////////////////////////////////////////////////////////////////////////////////
//                                   MOTORS                                      //
///////////////////////////////////////////////////////////////////////////////////
#define M1 4 // Base arduino board pins
#define E1 5
#define E2 6
#define M2 7
#define M3 8 // Extension pins
#define E3 9
#define E4 10
#define M4 11

////////////////////////////////////////////////////////////////////////////////////
//                                   SENSORS                                      //
////////////////////////////////////////////////////////////////////////////////////

char IR_Right = 0;
char IR_Center = 1;
char IR_Left = 2;

////////////////////////////////////////////////////////////////////////////////////
//                              FOR THE PROGRAM                                   //
////////////////////////////////////////////////////////////////////////////////////

#include <math.h>
#define epsilon 10

unsigned long time = 0;
char x = 0, y = 0, r = 0;                // Set point values
char x2 = 0, y2 = 0, r2 = 0;             // Former values. We want to know them.
char x1 = 0, y1 = 0, r1 = 0;             // Former values too.
float stepx = 0, stepy = 0, stepr = 0;   // Used to calculate the different steps for x, y and r for the ramp()
int sup = 0;                             // Used in clacStep()
char newcmd = 0;                         // 1 if there are new set point values. Otherwise it is 0
int i = 0;                               // It is for the function ramp()
int j = 0;                               // Used in the function mvt() to reach the maximum speed slowly.
char error = 0;                          // error = 0 if in calcstep() max = 0
char cmd = 0;                            // 'K' to control with the keyboard and 'R' with the remote
char cmdTemp = 0;                        // 
char actObst = 1;                        // 1 to enable the function obstacle()
char s = 1;                              // Used to stop quickly the robot in the ramp() function

////////////////////////////////////////////////////////////////////////////////////
//                                  SETUP                                         //
//                                  SETUP                                         //
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  
  Serial.begin(19200); // A baud rate of 19200 is required to communicate with the DUS ultrasonic sensors.
    
  pinMode(M1,OUTPUT);
  pinMode(M2,OUTPUT);
  pinMode(E1,OUTPUT);
  pinMode(E2,OUTPUT);
}

////////////////////////////////////////////////////////////////////////////////////
//                                  LOOP                                          //
//                                  LOOP                                          //
////////////////////////////////////////////////////////////////////////////////////

void loop() {
     
  if(Serial.available() != 0) {
    cmdTemp = Serial.read();
    
    if (cmdTemp == 'K' || cmdTemp == 'R') {
      x = readInteger();
      y = readInteger();
      r = readInteger();
      newcmd = 1;
      cmd = cmdTemp;
    }
    else if (cmdTemp == 'C') {
      actObst = Serial.read();
      Serial.print('C');
      Serial.println(actObst);
    }
      
   if(actObst)    
     obstacle(affineDist(IR_Right), affineDist(IR_Center), affineDist(IR_Left));
     
  }
  if(cmd == 'K') {
     ramp(x, y, r);
  }
     
  else if (cmd == 'R') {
     mvt (x, y, r);
     x1 = x;
     y1 = y;
     r1 = r;
  }
  
  if (millis() - time > 200) {
  Serial.print('S');
  Serial.print(affineDist(IR_Right), 0);
  Serial.print(" ");
  Serial.print(affineDist(IR_Center), 0);
  Serial.print(" ");
  Serial.print(affineDist(IR_Left), 0);
  Serial.println();
  time = millis();
  }    
}
