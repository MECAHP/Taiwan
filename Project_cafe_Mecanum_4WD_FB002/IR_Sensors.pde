float affineDist (char nbPin) {
   float sens = 0;                     // IR sensors' output voltage value
   float dist = -1;                    // Distance in cm
   
   for (int i = 0; i < 10; i++) {      // Allow to average 10 successive values.
    sens += analogRead(nbPin); 
   }
   
   sens = (sens / 10) * 0.0049;        // Average of the 10 values. We multiply by 0.0049 to have a value between 0 and 5 volts
   dist = 1 / ((sens - 0.25) * 0.05);  // Refer to the datasheet to know csaracteristics of IR Sharp sensors. 
   
   if (dist < 7 || dist > 45)          // Values under 7 cm and over 45 cm are OUT OF RANGE
      return -1;
      
   return round((dist - 7) * 100 / (45 - 7)) ; // To have a value between 0 and 100 instead of 7 and 45. 
                                               // 0 means there is an obstacle just close to the robot.
}

// obstacle() allows to stop automatically the robot in front of an obstacle.
void obstacle (char rightSensor, char centerSensor, char leftSensor) {
 if (rightSensor != -1 && rightSensor <  40) {
   if(y > 0)
     y = 0;
   if(fabs(r) > 40) {
     r = sign(r) * 40;
   }
 }
 
 if (leftSensor != -1 && leftSensor < 40) {
   if(y < 0)
     y = 0;
  if(fabs(r) > 40) {
     r = sign(r) * 40;
   }
 }
 
 if (centerSensor != -1 && centerSensor < 25 && x > 0) {
   x = 0;
 }
}
