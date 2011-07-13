/*
 * These functions control the robot movements efficiently.
 */
 
/*
 * Set the speed to (x, y) and the rotation speed to r (arbitrary units).
 */
 
void mvt (char x, char y, char r)
{
  int xNorm = 0, yNorm = 0, rNorm = 0;
  // Normalise values so that their sum can't exceed 255 (maximum power).
  if (x > 100 && x < 127 && y == 0 && r == 0)    // That's for the maximum speed.
     xNorm = x * 255 / (127 * 2);
  if (x == 127 && y == 0 && r == 0)
     xNorm = x * 255 / 127;
  if(x <= 100) {
    xNorm = x * 255 / (127 * 3);
    yNorm = y * 255 / (127 * 3);
    rNorm = r * 255 / (127 * 3);
  }
 
  // Compute algebraic motor speeds according to the influence of each basic movement (forward, strafe, turn).
  int m1 = - xNorm + yNorm - rNorm;
  int m2 = - xNorm - yNorm - rNorm;
  int m3 = + xNorm - yNorm - rNorm;
  int m4 = + xNorm + yNorm - rNorm;
  
  // Set the direction of each motor according to the sign of the speed we want.
  // Each test returns a boolean (true or false), which is equivalent to HIGH or LOW.
  digitalWrite(M1, m1 >= 0);
  digitalWrite(M2, m2 >= 0);
  digitalWrite(M3, m3 >= 0);
  digitalWrite(M4, m4 >= 0);
  
  
  analogWrite(E2, abs(m2));
  analogWrite(E3, abs(m3));
  analogWrite(E4, abs(m4));
}


/*
 * The following are shortcut functions for basic movements.
 */
 
void forward() {
  mvt( 127, 0, 0);
}

void backward() {
  mvt(-127, 0, 0);
}

void strafeLeft() {
  mvt(0, -127, 0);
}

void strafeRight() {
  mvt(0,  127, 0);
}

void turnLeft() {
  mvt(0, 0, -127);
}

void turnRight() {
  mvt(0, 0,  127);
}

void stop() {
  mvt(0, 0, 0);
}


// This function calculate the value of each step in x, y and r. We use them in the function ramp() which is underneath.
void calcstep(char x, char y, char r) {
  int sup = maximum(maximum(fabs(x - x2), fabs(y - y2)), fabs(r - r2));
 
  if (sup !=0) {                   // It's forbiden to devide by 0 ;-)
    stepx = (float(x - x2)) / sup;
    stepy = (float(y - y2)) / sup;
    stepr = (float(r - r2)) / sup;
    error = 0;
  }
  else {                          // sup be likely equal to 0 only when there are two successive commands equal to (0, 0, 0). In this case, each step is equal to 0.
    stepx = 0;
    stepy = 0;
    stepr = 0;
    error = 1; 
  }
}

// This function avoid violent changes of speed in creating a ramp of speed between two set points.
void ramp (char x, char y, char r) {          
  if (newcmd) {
    x2 = x1;
    y2 = y1;
    r2 = r1;
    calcstep(x, y, r);
    newcmd = 0;
    i = 0;
  }
  
  if(x == 0 && y == 0 && r == 0) {
    mvt(0, 0, 0);
    x1 = 0;
    y1 = 0;
    r1 = 0; 
  }
  
  else if (fabs(x1 - x) > epsilon || fabs(y1 - y) > epsilon || fabs(r1 - r) > epsilon || error ) {
    i++;
    mvt((char)(x2 + i*stepx), (char)(y2 + i*stepy), (char)(r2 + i*stepr));            // The ramp is creating here. We change gradually values in x, y and r
    x1 = (x2 + i*stepx);                                                              // Each time, we copy values in x, y and r.  
    y1 = (y2 + i*stepy);
    r1 = (r2 + i*stepr);
  }
  
  else {
    mvt (x, y, r);
    x1 = x;
    y1 = y;
    r1 = r;  
  }
  
  delay(2);           // This delay allow to control ramp's slope. 
}



/*
 * Control the robot with the Serial Monitor by sending AZERTY key presses.
 */
 
void keyboardControl () {
   x = readInteger();
   y = readInteger();
   r = readInteger();
   ramp(x, y, r);
   newcmd = 1; 
}

void remoteControl () {
    x = readInteger();
    y = readInteger();
    r = readInteger();
    x1 = x;
    y1 = y;
    r1 = r;
    mvt(x, y, r); 
}

void remoteDebug()
{
  while(1) {
    while (Serial.available() == 0);
    switch(Serial.read()) {
      case 'z':
        forward();
        break;
      case 's':
        backward();
        break;
      case 'q':
        strafeLeft();
        break;
      case 'd':
        strafeRight();
        break;
      case 'a':
        turnLeft();
        break;
      case 'e':
        turnRight();
        break;
      case ' ':
      case '\r':
      case '\n':
        continue; // Ignore whitespaces end line breaks.
      default :
        return; // Unexpected character, stop interpreting results.
   }
  
   delay(500);
   stop();
  }
}


int minimum (int a, int b) {          
  if(a <= b)
      return a;
  return b;
}

int maximum (int a, int b) {
  if(a >= b)
      return a;
  return b; 
}

