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

//'dislimit' defines the minimum distance for obstacle detection and avoidance.
unsigned char dislimit = 20;


/*
void slow2stop() {{
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
}
*/
int readInteger() {
  int result = 0;
  int sign = 1;
  
  while(Serial.available() == 0)
    delay(1);
  
  if((Serial.peek() == '+' || Serial.peek() == '-') && Serial.read() == '-')
    sign = -1;
  
  do
  {
    while('0' <= Serial.peek() && Serial.peek() <= '9')
    {
      result = result * 10 + Serial.read() - '0';
    }
  }
  while(Serial.available() == 0);
  
  return sign * result;
}

  



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
      
    x = Serial.read()*100 + Serial.read()*10 ;
    y = Serial.read();
    r = Serial.read();
     
    mvt(x, y, r);
   }
   
   delay(500);
   stop();
   
 
  
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
