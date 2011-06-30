
#define us_pin   13 //
#define us_TX    HIGH
#define us_RX    LOW
#define us_delay 5

int us_getDistance(byte addr)
{
  us_triggerMeasurement(addr);
  delay(us_delay);
  return us_readDistance(addr);
}

void us_triggerMeasurement(byte addr)
{
  digitalWrite(us_pin, us_TX);
  
  Serial.write(0x55); // 'U'
  Serial.write(0xaa);
  Serial.write(addr);
  Serial.write((byte)0);
  Serial.write(0x01); // triggerMeasurement command.
  Serial.write(0x55 + 0xaa + addr + 0 + 0x01); // Checksum.
}

int us_readDistance(byte addr)
{
  // Send request packet.
  digitalWrite(us_pin, us_TX);
  
  Serial.write(0x55); // 'U'
  Serial.write(0xaa);
  Serial.write(addr);
  Serial.write((byte)0);
  Serial.write(0x02); // readDistance command.
  Serial.write(0x55 + 0xaa + addr + 0 + 0x02); // Checksum.
  
  // Now wait for answer packet.
  digitalWrite(us_pin, us_RX);
  while(Serial.available() < 6)
    delay(1);

  int res =Serial.read() == 0x55
        && Serial.read() == 0xaa
        && Serial.read() == addr
        && Serial.read() == 0x02
        && Serial.read() == 0x02;
  Serial.println(res, DEC);
  int distance =  Serial.read() << 8;
  distance += Serial.read();
  
  Serial.read(); // TODO: check the checksum

  return distance;
}



byte us_setAddress(byte addr)
{
  Serial.write(0x55); // 'U'
  Serial.write(0xaa);
  Serial.write(0xab); // A kind of of broadcast address.
  Serial.write(0x01);
  Serial.write(0x55); // setDeviceAddress command.
  Serial.write(addr);
  Serial.write(0x55 + 0xaa + 0xab + 0x01 + 0x55 + addr); // Checksum.
  
  //TODO:
  return 0; // Failure
}


/*
int us_readTemperature(byte addr)
{
}
*/
