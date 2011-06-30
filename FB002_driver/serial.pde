/*
 *      Read an ASCII decimal number on the serial line, and return the corresponding integer.
 * The function always waits for an unrecognized character (typically whitespace) before returning,
 * so that we don't forget the last digit if the serial line is slow.
 *      An optional leading plus or minus sign is taken into account.
 */
int readInteger() {
  
  while(Serial.available() == 0)
    delay(1); // Wait for one character.
  
  char sign = 1; // Default to positive numbers.
  if(Serial.peek() == '+' || Serial.peek() == '-')
    if(Serial.read() == '-') // We don't lose a digit thanks to the previous test.
      sign = -1;

  int result = 0;
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
  
