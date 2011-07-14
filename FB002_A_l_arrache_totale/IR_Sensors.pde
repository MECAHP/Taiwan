float affineDist (char nbPin) {
   float sens = 0;
   float dist = -1;
   
   for (int i = 0; i < 10; i++) {
    sens += analogRead(nbPin); 
   }
   sens = (sens / 10) * 0.0049;
   //Serial.print("Sens : ");
   //Serial.println(sens);
   dist = 1 / ((sens - 0.25) * 0.05);
   if (dist < 7 || dist > 45)
      return -1;
   return round(dist) ; 
}
