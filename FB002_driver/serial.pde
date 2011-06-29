
/*
 *       Reads an ASCII decimal number on the serial line, and returns the corresponding integer.
 *  The function always waits for an unrecognized character (typically whitespace) before returning,
 *  so that we don't forget the last digit if the line is slow. This 
 *       An optional leading plus or minus sign is taken into account.
 */
int readInteger() {
  int result = 0;
  char sign = 1; // Default to positive numbers.
  
  while(Serial.available() == 0)
    delay(1); // Wait for one character.
  
  if(Serial.peek() == '+' || Serial.peek() == '-')
    if(Serial.read() == '-') // We don't lose a digit thanks to the previous test.
      sign = -1;

  while(1)
  {
    char c = Serial.read();
    if('0' <= c && c <= '9')
      result = result * 10 + c - '0';
    else if(c == -1) // No character available.
      delay(1);
    else
      break; // An unrecognized character marks the end of the number.
  }
  
  return sign * result;
}
  
