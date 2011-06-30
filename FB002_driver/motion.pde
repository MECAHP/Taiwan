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
#define M1 4 // Base arduino board pins
#define E1 5
#define E2 6
#define M2 7
#define M3 8 // Extension pins
#define E3 9
#define E4 10
#define M4 11


/*
 * Set the speed to (x, y) and the rotation speed to r (arbitrary units).
 */
void mvt(char x, char y, char r)
{
  // Normalise values so that their sum can't exceed 255 (maximum power).
  int xNorm = x * 255 / (127 * 3); 
  int yNorm = y * 255 / (127 * 3);
  int rNorm = r * 255 / (127 * 3);
 
  // Compute algebraic motor speeds according to the influence of each basic movement (forward, strafe, turn).
  int m1 = - xNorm - yNorm - rNorm;
  int m2 = - xNorm + yNorm - rNorm;
  int m3 = + xNorm + yNorm - rNorm;
  int m4 = + xNorm - yNorm - rNorm;
  
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


/*
 * Control the robot with the Serial Monitor by sending AZERTY key presses.
 */
void remoteDebug()
{
  while(1) {
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

