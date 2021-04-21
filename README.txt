For security and ease of configuration, WiFi credentials are loaded from a separate file. A file called "wifi.txt" should be created, with the first line being the network name (SSID) and the second line being the password. This file can also be uploaded to the ESP8266 via mpfshell using the "put" command.

To run the device, simply:
	import measure
from the device's startup file (main.py)


Connect MFRC522
Power/GND
SCK, MOSI, MISO (matching)
RST (+Vcc)
SDA (Pin 0)

Connect OLED
Power/GND
SCL, SDA as expected (I2C)
Connect button C to pin 2 with pull-up resistor

Connect HX711
Power/GND
SCK to 15
DT to 16