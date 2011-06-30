/**********************************D I A G R A M ***********************************
Please set up your robot according to this diagram.  Sonar 0x14 is optional.
                                     Sonar:0x12
                           ------------------------------
                          |                             |
                        M3|                             |M2                          |                             |
                          |                             |
                          |                             |
                Sonar:0x13|                             |Sonar:0x11
                          |                             |
                          |                             |Power Switch
                          |                             |
                          |                             |
                          -------------------------------
                          |                             |
                        M4                              |M1
                          |                             |
                          -------------------------------
                                    Sonar:0x14                          
***********************************************************************************/


void setup() {
    Serial.begin(115200); // A baud rate of 115200 is required to communicate with the DUS ultrasonic sensors.
}

void loop() {
  char x = 0, y = 0, r = 0;
  
  x = readInteger();
  y = readInteger();
  r = readInteger();
  
  mvt(x, y, r);
  
  delay(50);
}
