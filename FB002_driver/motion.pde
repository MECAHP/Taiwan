

/*
These functions control the robots movements forward, backward, side to side 
and also clockwise and anti-clockwise rotation.
*/

void mvt(char x, char y, char r) {    // this fonction allows to do all possible movements.
  
  int xNorm = x * 255 / (128 * 3);        // We create xNorm to not go past the maximum valu which is 255/3.
  int yNorm = y * 255 / (128 * 3);
  int rNorm = r * 255 / (128 * 3);
 
  int m1 = xNorm - yNorm + rNorm;            // m1 is the motor 1's speed rotation.
  int m2 = xNorm + yNorm + rNorm;
  int m3 = xNorm - yNorm - rNorm;
  int m4 = xNorm + yNorm - rNorm;
 
   analogWrite(E1, abs(m1));
   if(m1 >= 0)
     digitalWrite(M1, HIGH);
   else
     digitalWrite(M1, LOW);
   analogWrite(E2, abs(m2));
   if(m2 >= 0)
     digitalWrite(M2, HIGH);
   else 
     digitalWrite(M2, LOW);

   analogWrite(E3, abs(m3));
   if(m3 >= 0)
     digitalWrite(M3, HIGH);
   else 
     digitalWrite(M3, LOW);

  analogWrite(E4, abs(m4));
   if(m4 >= 0)
     digitalWrite(M4, HIGH);
   else
     digitalWrite(M4, LOW);
}

/* The following are shortcut functions */

void forward()
{
  mvt (128, 0, 0);
}

void backback()
{
  mvt (-127, 0, 0);
}

void strafeleft()
{
  mvt(0, -127, 0);
}

void straferight()
{
  mvt(0, 128, 0);
}

void turnclkwse()
{
  mvt(0, 0, -127);
}

void turnanticlkwse()
{
  mvt(0, 0, 128);
}

void stop()
{
  mvt(0, 0, 0);
}
