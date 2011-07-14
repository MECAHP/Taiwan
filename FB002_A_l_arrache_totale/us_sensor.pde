/*******************************************************/



/*******************************************************/


int urm_setMode(int mode) {		// HIGH:urm_TX, LOW:urm_RX
	digitalWrite(urm_control,mode);
	return mode;
}

unsigned char urm_sendCmd(unsigned char urm[],unsigned char size) {
  //digitalWrite(urm_control,HIGH);
	urm_setMode(urm_TX);
  //delay(10);
  //Serial.write(urm,size);
  for(int i=0;i<size;++i) {
      Serial.print(urm[i]);
  }
  return size;
}
unsigned char urm_recvDat(unsigned char size) {
  for(int i=0;i<sizeof(urm_rcvbuf);++i) {
      urm_rcvbuf[i]=0;
  }
  //digitalWrite(urm_control,LOW);
	urm_setMode(urm_RX);
  //delay(10);
  //for(int i=0,j=0;i<size&&j<1000;++j) {
   for(int i=0,j=0;i<size&&j<5000;++j) {
    unsigned char ibyte=Serial.read();
    if(0<=ibyte && ibyte<0xff) {
        urm_rcvbuf[i++]=ibyte;
     //   ++i;
     //   LCD_Data_Write(XX[ibyte>>4]);
     //   LCD_Data_Write(XX[ibyte%16]);
    }
    //delayMicroseconds(5);
  }
}
int urm_checksum(unsigned char size) {
    unsigned char sum=0;
    if(urm_rcvbuf[0]==0) return -1;
    for(int i=0;i<size-1;++i) {
        sum+=urm_rcvbuf[i];
    }
    if(sum!=urm_rcvbuf[size-1]) return -1;
    else return 0;
}
int urm_showDat(unsigned char size) {
    //LCD_SET_XY(0,0);
    //if(urm_checksum(size)<0) {
    //    LCD_Write_String(0,0,"Checksum Error");
    //    return;
    //}


    //for(int i=0;i<size;++i) {
    //    LCD_Data_Write(XX[urm_rcvbuf[i]>>4]);
    //    LCD_Data_Write(XX[urm_rcvbuf[i]%16]);
    //}

    //digitalWrite(urm_control,HIGH);
	//urm_setMode(urm_RX);
     int result;
     
    for(int i=0;i<size;++i) {
                if (i == 6) {
                //Serial.print("disance : ");
                result = urm_rcvbuf[i];
		Serial.print(result, DEC);
                //Serial.print(" cm");
                //Serial.print(" ");
                }
    }
    //Serial.println("");
    return(result);
}
void urm_initAddr() {
    unsigned int startTime=millis();
    unsigned int delta=0;
    boolean got_key=false;
    
    while(digitalRead(keyS7)==LOW) {
        got_key=true;
    //    LCD_Write_String(0,0,"Got keyS7:(ms)");
    //    LCD_Write_Number(0,1,delta=millis()-startTime);
        delay(100);
        Serial.println(delta=millis()-startTime,DEC);
    }
    if(got_key==true) {
    //    digitalWrite(urm_control,HIGH);
		urm_setMode(urm_TX);
        Serial.print("Got keyS7:(ms) ");
        Serial.println(delta=millis()-startTime,DEC);
    }
/*
    if(delta>=8000)      urm_sendCmd(urm18Addr,sizeof(urm18Addr));
    else if(delta>=7000) urm_sendCmd(urm17Addr,sizeof(urm17Addr));
    else if(delta>=6000) urm_sendCmd(urm16Addr,sizeof(urm16Addr));
    else if(delta>=5000) urm_sendCmd(urm15Addr,sizeof(urm15Addr));
 */
    if(delta>=4000) urm_sendCmd(urm14Addr,sizeof(urm14Addr));
    else if(delta>=3000) urm_sendCmd(urm13Addr,sizeof(urm13Addr));
    else if(delta>=2000) urm_sendCmd(urm12Addr,sizeof(urm12Addr));
    else if(delta>=1000)  urm_sendCmd(urm11Addr,sizeof(urm11Addr)); 
    else got_key=false;
    if(got_key) {
        delay(1);
        //delayMicroseconds(200);
        urm_recvDat(7);
        urm_showDat(7);  
    }
}




void urm_init() {
    
    pinMode(urm_control,OUTPUT);
    //digitalWrite(urm_control,HIGH);
    //urm_setMode(urm_TX);
    
    //pinMode(keyS7,INPUT);    // addressing in setup()
    //delay(1000);
    //urm_initAddr();   
    
    delay(500);
    //Wire.begin(); 
}




int urm_action(unsigned char* act0,unsigned char act0_size,unsigned char* act1,unsigned char act1_size) {
  //LCD_Command_Write(0x01);
  //LCD_SET_XY(0,LINE=!LINE);

  urm_sendCmd(act0,act0_size);
  delay(urm_duration);
  urm_sendCmd(act1,act1_size);

  //delayMicroseconds(urm_delay);    // 150 - 240 us
  delay(urm_delay);
  
  urm_recvDat(8);
  //LCD_SET_XY(0,0);
 return urm_showDat();
  
  if(urm_checksum(urm_bufSize)==0)
      return (urm_rcvbuf[5]<<8)+urm_rcvbuf[6];
  return 0; // not available distance
                             
}
