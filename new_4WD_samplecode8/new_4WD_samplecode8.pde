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

/********************************S E T T I N G S **********************************/
//Ultrasonic Sensors
#define urm_duration 80
#define urm_delay 1
#define urm_TX HIGH
#define urm_RX LOW
#define urm_bufSize 8
unsigned char urm_rcvbuf[8];
unsigned char urm_control=13;

//Motor control pins - Motors 1&2
#define M1 4       
#define E1 5       
#define E2 6       
#define M2 7       

//Motor control pins - Motors 3&4
#define E3 9
#define M3 8
#define E4 10
#define M4 11       

//Commands for the ultrasonic sensors.  Please refer to the ultrasonic sensor 
//data sheet for more detailed information on these commands.
unsigned char urm11Act[]={0x55,0xaa,0x11,0x00,0x01,0x11};
unsigned char urm11Get[]={0x55,0xaa,0x11,0x00,0x02,0x12};
unsigned char urm12Act[]={0x55,0xaa,0x12,0x00,0x01,0x12};
unsigned char urm12Get[]={0x55,0xaa,0x12,0x00,0x02,0x13};
unsigned char urm13Act[]={0x55,0xaa,0x13,0x00,0x01,0x13};
unsigned char urm13Get[]={0x55,0xaa,0x13,0x00,0x02,0x14};

//'robot_state' lets the program know which state the robot is in
//'speed' is the overall speed of the robot
//'dislimit' defines the minimum distance for obstacle detection and avoidance.
unsigned char robot_state; //0 =stopped, 1=moving
unsigned char speed = 100;
unsigned char dislimit = 20;

/*******************  U  R  M   F U N C T I O N S  *****************************/ 
/*
These functions send information to the ultrasonic sensors and retrieve
distance information.

Function descriptions:
urm_checksum() checks the integrity of packets received from the ultrasonic sensors
urm_setMode() sets the arduino to either transmit or receive data.
urm_sendCmd() transmits a data packet.
urm_recvDat() receives a data packet.
urm_showDat() displays a data packet which was just received.  Used mainly for debugging puposes.
urm_action() combines all of the above functions to send a 'trigger' command, then a 'read' command
and then return the distance to object in centimeters.
*/


int urm_checksum(unsigned char size) {
    unsigned char sum = 0;
    if(urm_rcvbuf[0] == 0) return -1;
    for(int i = 0; i < size-1; ++i) {
        sum += urm_rcvbuf[i];
    }
    if(sum != urm_rcvbuf[size-1]) return -1;
    else return 0;
}

int urm_setMode (int mode) {		// HIGH:urm_TX, LOW:urm_RX
	digitalWrite(urm_control,mode);
	return mode;
}

unsigned char urm_sendCmd(unsigned char urm[],unsigned char size) {
	urm_setMode(urm_TX);
  for(int i=0;i<size;++i) {
      Serial.print(urm[i]);
  }
  return size;
}

unsigned char urm_recvDat(unsigned char size) {
  for(int i=0;i<sizeof(urm_rcvbuf);++i) {
      urm_rcvbuf[i]=0;
  }
	urm_setMode(urm_RX);
   for(int i=0,j=0;i<size&&j<5000;++j) {
    unsigned char ibyte=Serial.read();
    if(0<=ibyte && ibyte<0xff) {
        urm_rcvbuf[i++]=ibyte;
    }
  }
}

void urm_showDat(unsigned char size) {
	urm_setMode(urm_TX);
    for(int i=0;i<size;++i) {
		Serial.print(urm_rcvbuf[i],HEX);
                Serial.print(" ");
    }
    Serial.println("");
}

int urm_action(unsigned char* act0,unsigned char act0_size,unsigned char* act1,unsigned char act1_size) {
  
  urm_sendCmd(act0,act0_size);
  delay(urm_duration);
  urm_sendCmd(act1,act1_size);
  delay(urm_delay);
  
  urm_recvDat(8);
  urm_showDat(8);
  
  if(urm_checksum(urm_bufSize)==0)
      return (urm_rcvbuf[5]<<8)+urm_rcvbuf[6];
  return 0;
                             
}

/***************************** E N D    U  R  M  ******************************************/ 
/************************* R O B O T  M O V E M E N T S ***********************************/

/*
These functions control the robots movements forward, backward, side to side 
and also clockwise and anti-clockwise rotation.
*/

void forward()
{
  mvt (128, 0, 0);
  robot_state = 1;
}

void backback()
{
  mvt (-127, 0, 0);
  robot_state = 1;
}

void strafeleft()
{
  mvt(0, -127, 0);
  robot_state = 1;
}

void straferight()
{
  mvt(0, 128, 0);
  robot_state = 1;
}

void turnclkwse()
{
  mvt(0, 0, -127);
  robot_state = 1;
}

void turnanticlkwse()
{
  mvt(0, 0, 128);
  robot_state = 1;
}

void stop()
{
  mvt(0, 0, 0);
  robot_state = 0;
}

void slow2stop() {
  if (robot_state == 1) {
    for (int i = speed; i > 0; i--) {
      analogWrite(E1,i);
      digitalWrite(M1,HIGH);
      analogWrite(E2,i);
      digitalWrite(M2,HIGH);
      analogWrite(E3,i);
      digitalWrite(M3,HIGH);
      analogWrite(E4,i);
      digitalWrite(M4,HIGH);
      delay(2);
    }
  robot_state = 0;
  return;
  }
}

void mvt(char x, char y, char r) {    // this fonction allows to do all possible movements.
  
  int xNorm = x * 255 / (128 * 3);        // We create xNorm to not go past the maximum valu which is 255/3.
  int yNorm = y * 255 / (128 * 3);
  int rNorm = r * 255 / (128 * 3);
 
  int m1 = xNorm - yNorm + rNorm;            // m1 is the motor 1's speed rotation.
  int m2 = xNorm + yNorm + rNorm;
  int m3 = xNorm - yNorm - rNorm;
  int m4 = xNorm + yNorm - rNorm;
 
   analogWrite(E1, abs(m1));
   if(m >= 0)
     digitalWrite(M1, HIGH);
   else 
     digitalWrite(M1, LOW);
     
   analogWrite(E2, abs(m2);
   if(m2 >= 0)
     digitalWrite(M2, HIGH);
   else 
     digitalWrite(M2, LOW);

   analogWrite(E3, abs(m3));
   if(m3 >= 0)
     digitalWrite(M3, HIGH);
   else 
     digitalWrite(M3, LOW);

  analogWrite(E4 abs(m4));
   if(m4 >= 0)
     digitalWrite(M4, HIGH);
   else
     digitalWrite(M4, LOW);
}
/******************** E N D  R O B O T  M O V E M E N T ***********************************/
/********************** O T H E R   F U N C T I O N S *************************************/

void setup() {
    //Start serial communications.
    Serial.begin(19200);
    
    //PWM frequency change, optional
    //Please refer to user manual for information on how to use this function
    //TCCR1B = TCCR1B & 0xf8 | 0x01;    // Pin9,Pin10 PWM 31250Hz
    //TCCR2B = TCCR2B & 0xf8 | 0x01;    // Pin3,Pin11 PWM 31250Hz
}

void loop() {
  
  char x = 0, y = 0, r = 0;
  //Retrieve the distance from each ultrasonic sensor (0x11, 0x12, and 0x13)
  //int dis11=urm_action(urm11Act,sizeof(urm11Act),urm11Get,sizeof(urm11Get));
  //int dis12=urm_action(urm12Act,sizeof(urm12Act),urm12Get,sizeof(urm12Get));
  //int dis13=urm_action(urm13Act,sizeof(urm13Act),urm13Get,sizeof(urm13Get));
    
  if (Serial.available() > 0){
      
    x = Serial.read();
    y = Serial.read();
    r = Serial.read();
     
    mvt(x, y, r);
   }
  
  
  /*else if (dis11 < dislimit) { //right-hand sensor detects object
     strafeleft();
      turnclkwse();
    }
    else if (dis13 < dislimit) { //left-hand sensor detects object
      straferight();
      turnanticlkwse();
    }
    else if (dis12 < dislimit+50) { //front sensor detects object
      slow2stop();
      backback();
      turnclkwse();
      turnclkwse();
    }
    */
}
