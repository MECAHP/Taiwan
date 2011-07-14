/*
 * These functions control the robot movements efficiently.
 * 
 * FIXME: improve the maximum speed in cases like mvt(128, 0, 0) because we don't use the motors to their full power.
 * FIXME: add a function to speed up gradually.
 */


/*
 * Pin definitions for motor number 'x' :
 *   Mx is for the direction, HIGH for counterclockwise, LOW for clockwise.
 *   Ex is for the power, from 0 to 255.
 */
 
/*
 * Set the speed to (x, y) and the rotation speed to r (arbitrary units).
 */
void mvt(int x, int y, int r)
{
  // Normalise values so that their sum can't exceed 255 (maximum power).
  int xNorm = x * 255 / (127 * 3); 
  int yNorm = y * 255 / (127 * 3);
  int rNorm = r * 255 / (127 * 3);
 
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
  
  // Set the power of each motor.
  analogWrite(E1, abs(m1));
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

void calcstep(int x, int y, int r) {
  int sup = maximum(maximum(fabs(x - x2), fabs(y - y2)), fabs(r - r2));
  /*
  Serial.print("sup : ");
  Serial.println(sup);
  Serial.print("x2 : ");
  Serial.println(x2);
  Serial.print("y2 : ");
  Serial.println(y2);
  Serial.print("r2 : ");
  Serial.println(r2);
  */
  if (sup !=0) {
    stepx = (float(x - x2)) / sup;
    stepy = (float(y - y2)) / sup;
    stepr = (float(r - r2)) / sup;
    error = 0;
  }
  else {
    stepx = 0;
    stepy = 0;
    stepr = 0;
    error = 1; 
  }
  /*
  Serial.print("stepx : ");
  Serial.println(stepx);
  Serial.print("stepy : ");
  Serial.println(stepy);
  Serial.print("stepr : ");
  Serial.println(stepr);
  */
}

void ramp (int x, int y, int r) {                          // To avoid violent changes of speed
  if (newcmd) {
    x2 = x1;
    y2 = y1;
    r2 = r1;
    calcstep(x, y, r);
    newcmd = 0;
    i = 0;
  }
  
  if (fabs(x1 - x) > epsilon || fabs(y1 - y) > epsilon || fabs(r1 - r) > epsilon || error ) {
    i++;
    mvt((int)(x2 + i*stepx), (int)(y2 + i*stepy), (int)(r2 + i*stepr));
    x1 = (x2 + i*stepx);
    y1 = (y2 + i*stepy);
    r1 = (r2 + i*stepr);
    /*
    Serial.print("i : ");
    Serial.println(i);
    Serial.print("stepx : ");
    Serial.println(stepx);
    Serial.print("stepy : ");
    Serial.println(stepy);
    Serial.print("stepr : ");
    Serial.println(stepr);
    Serial.println();
    Serial.print("x : ");
    Serial.println(x1);
    Serial.print("y : ");
    Serial.println(y1);
    Serial.print("r : ");
    Serial.println(r1);
    Serial.println();
    Serial.println();
    */
  }
  else {
    mvt (x, y, r);
    x1 = x;
    y1 = y;
    r1 = r;
    /*
    Serial.print("Valeur de i : ");
    Serial.println(i);
    Serial.print("Valeur de x : ");
    Serial.println(x);
    Serial.print("Valeur de y : ");
    Serial.println(y);
    Serial.print("Valeur de r : ");
    Serial.println(r);
    Serial.println();
    */  
  }
  delay(3);
}



/*
 * Control the robot with the Serial Monitor by sending AZERTY key presses.
 */
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
        continue; // Ignore whitespace.
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

