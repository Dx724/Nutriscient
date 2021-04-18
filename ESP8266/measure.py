import machine, ssd1306, network, time, urequests, ujson, random
from hx711_spi import HX711

# Connect to OLED
i2c = machine.I2C(-1, machine.Pin(5), machine.Pin(4))
oled = ssd1306.SSD1306_I2C(128, 32, i2c)

# OLED Buttons
btn_a = machine.Pin(13, machine.Pin.IN)
btn_b = machine.Pin(0, machine.Pin.IN)
btn_c = machine.Pin(2, machine.Pin.IN)

# Initialize hardware SPI
pin_MOSI = machine.Pin(13, machine.Pin.OUT)
pin_MISO = machine.Pin(12, machine.Pin.IN)
hspi = machine.SPI(1, baudrate=1000000, polarity=0, phase=0)

# Initialize HX711
hx = HX711(pin_MOSI, pin_MISO, hspi)

while True:
    print(hx.read())
    time.sleep_ms(500)

'''
# Get API Key
with open("tweet-key.txt", "r") as f:
    key = f.readline().rstrip("\r\n") # Geolocation API
if len(key) == 0:
    print("Failed to load API keys")

# Get Network SSID and Password
with open("wifi.txt", "r") as f:
    ssid = f.readline().rstrip("\r\n")
    password = f.readline().rstrip("\r\n")
if len(ssid) == 0:
    print("Failed to load WiFi credentials")

# Connect to Wi-Fi
sta = network.WLAN(network.STA_IF)
if not sta.isconnected():
    sta.active(True)
    sta.connect(ssid, password)
    print("Connecting to Wi-Fi")
    while not sta.isconnected():
        pass
print("Connected to Wi-Fi!")

# Disable unused access point interface
network.WLAN(network.AP_IF).active(False)

# APIs
TWEET_API = "https://api.thingspeak.com/apps/thingtweet/1/statuses/update"
rand_data = random.getrandbits(16)
tweet_data = ujson.dumps({"api_key": key, "status": "[{}] Hello from ESP8266!".format(rand_data)})
tweet_headers = {"content-type": "application/json"}

def tweet(): # Note that a randomized number is added to the message so it is not blocked by Twitter's repeated status check
    res = urequests.post(TWEET_API, headers=tweet_headers, data=tweet_data)
    print("Tweet result: {}".format(res.text))
    oled.fill(0)
    oled.text("Tweet Result: {}".format(res.text), 0, 0)
    oled.text("UID: {}".format(rand_data), 0, 10)
    oled.show()

def do_tweet():
    while True: # Retry until success
        try:
            tweet()
            return
        except OSError:
            # Some firmware versions fail on requests occasionally
            time.sleep(1)

do_tweet()
'''
