
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

//Ultrasonic Sensors
#define urm_duration 80
#define urm_delay 1
#define urm_TX HIGH
#define urm_RX LOW
#define urm_bufSize 8
unsigned char urm_rcvbuf[8];
unsigned char urm_control=13;


//Commands for the ultrasonic sensors.  Please refer to the ultrasonic sensor 
//data sheet for more detailed information on these commands.
unsigned char urm11Act[]={0x55,0xaa,0x11,0x00,0x01,0x11};
unsigned char urm11Get[]={0x55,0xaa,0x11,0x00,0x02,0x12};
unsigned char urm12Act[]={0x55,0xaa,0x12,0x00,0x01,0x12};
unsigned char urm12Get[]={0x55,0xaa,0x12,0x00,0x02,0x13};
unsigned char urm13Act[]={0x55,0xaa,0x13,0x00,0x01,0x13};
unsigned char urm13Get[]={0x55,0xaa,0x13,0x00,0x02,0x14};

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
