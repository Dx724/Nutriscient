For security and ease of configuration, WiFi credentials are loaded from a separate file. A file called "wifi.txt" should be created, with the first line being the network name (SSID) and the second line being the password. This file can also be uploaded to the ESP8266 via mpfshell using the "put" command.

To run the device, simply:
	import measure
from the device's startup file (main.py)