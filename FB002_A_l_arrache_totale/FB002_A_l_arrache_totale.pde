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


#include <math.h>
///////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////MOTORS////////////////////////////////////////
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
/////////////////////////////////////SENSORS////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

#define urm_TX HIGH
#define urm_RX LOW
#define urm_bufSize 8

//#define urm_baud 115200
#define urm_baud 19200
#define urm_duration 80

unsigned char keyS7=3;
//unsigned int urm_delay=160;
unsigned int urm_delay=1;

unsigned int urm_total=3;

//unsigned char XX[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
unsigned char urm_rcvbuf[8];

unsigned char urm_control=13; //HIGH:SEND, LOW:RECV

unsigned char urm11Addr[]={0x55,0xaa,0xab,0x01,0x55,0x11,0x11};
unsigned char urm11Act[]={0x55,0xaa,0x11,0x00,0x01,0x11};
unsigned char urm11Get[]=   {0x55,0xaa,0x11,0x00,0x02,0x12};

unsigned char urm12Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x12};
unsigned char urm12Act[]={0x55,0xaa,0x12,0x00,0x01,0x12};
unsigned char urm12Get[]=   {0x55,0xaa,0x12,0x00,0x02,0x13};

unsigned char urm13Addr[]={0x55,0xaa,0xab,0x01,0x55,0x13,0x13};
unsigned char urm13Act[]={0x55,0xaa,0x13,0x00,0x01,0x13};
unsigned char urm13Get[]=   {0x55,0xaa,0x13,0x00,0x02,0x14};

unsigned char urm14Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x14};
unsigned char urm14Act[]={0x55,0xaa,0x14,0x00,0x01,0x14};
unsigned char urm14Get[]=   {0x55,0xaa,0x14,0x00,0x02,0x15};
/*
unsigned char urm15Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x15};
unsigned char urm15Act[]={0x55,0xaa,0x15,0x00,0x01,0x15};
unsigned char urm15Get[]=   {0x55,0xaa,0x15,0x00,0x02,0x16};

unsigned char urm16Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x16};
unsigned char urm16Act[]={0x55,0xaa,0x16,0x00,0x01,0x16};
unsigned char urm16Get[]=   {0x55,0xaa,0x16,0x00,0x02,0x17};

unsigned char urm17Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x17};
unsigned char urm17Act[]={0x55,0xaa,0x17,0x00,0x01,0x17};
unsigned char urm17Get[]=   {0x55,0xaa,0x17,0x00,0x02,0x18};

unsigned char urm18Addr[]={0x55,0xaa,0xab,0x01,0x55,0x12,0x18};
unsigned char urm18Act[]={0x55,0xaa,0x18,0x00,0x01,0x18};
unsigned char urm18Get[]=   {0x55,0xaa,0x18,0x00,0x02,0x19};
   
unsigned char XX[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 */

int urm_setMode(int mode);
unsigned char urm_sendCmd(unsigned char urm[],unsigned char size);
unsigned char urm_recvDat(unsigned char size=sizeof(urm_rcvbuf));
int urm_checksum(unsigned char size=sizeof(urm_rcvbuf));
int urm_showDat(unsigned char size=sizeof(urm_rcvbuf));
void urm_initAddr();
void urm_init();
int urm_action(unsigned char* act0,unsigned char act0_size,unsigned char* act1,unsigned char act1_size);
unsigned int urm_update(unsigned int total);
unsigned int urm_getDis(unsigned char* cmd,unsigned int size);
char IR_Right = 0;
char IR_Center = 1;
char IR_Left = 2;

unsigned long time = 0;

int x = 0, y = 0, r = 0;                 // Set point values
int x2 = 0, y2 = 0, r2 = 0;              // Former values. We want to know them.
int x1 = 0, y1 = 0, r1 = 0;              // Former values too.
float stepx = 0, stepy = 0, stepr = 0;   // It is to calculate the different steps in x, y and r for the ramp()
char newcmd = 0;                         // 1 if there are new set point values. Otherwise it is 0
int i = 0;                               // It is for the function ramp()
char error = 0;                          // error = 0 if in calcstep() max = 0
#define epsilon 10

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                            SETUP
//                                                    SETUP
////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  
  Serial.begin(19200); // A baud rate of 19200 is required to communicate with the DUS ultrasonic sensors.
    
  pinMode(E1,OUTPUT);
  pinMode(E2,OUTPUT);
  pinMode(M1,OUTPUT);
  pinMode(M2,OUTPUT);
  
  //urm_init();
  
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                            LOOP
//                                                    LOOP
////////////////////////////////////////////////////////////////////////////////////////////////////////////

void loop() {
     
    
    if(Serial.available() != 0 && Serial.read() == 'M') {
    x = readInteger();
    y = readInteger();
    r = readInteger();
    
    newcmd = 1;
    }
    
    ramp(x, y, r);
   
   
    if (millis() - time > 200) {
    //Serial.print("Right sensor \t");
    Serial.print('S');
    Serial.print(affineDist(IR_Right), 0);
    Serial.print(" ");
    //Serial.print("Center sensor \t");
    Serial.print(affineDist(IR_Center), 0);
    Serial.print(" ");
    //Serial.print("Left sensor\t");
    Serial.print(affineDist(IR_Left), 0);
    Serial.println();
    //Serial.println();
    time = millis();
    }
    
}


