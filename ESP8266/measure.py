import machine, ssd1306, network, time, urequests, ujson, random
from hx711_gpio import HX711

# Connect to OLED
i2c = machine.I2C(-1, machine.Pin(5), machine.Pin(4))
oled = ssd1306.SSD1306_I2C(128, 32, i2c)

# OLED Buttons
btn_b = machine.Pin(0, machine.Pin.IN)
btn_c = machine.Pin(2, machine.Pin.IN)

# Initialize HX711
pin_MOSI = machine.Pin(13, machine.Pin.OUT)
pin_MISO = machine.Pin(12, machine.Pin.IN)
hx = HX711(pin_MOSI, pin_MISO)

### Helpers Start ###
def oled_text(t1, t2=None, t3=None):
    oled.fill(0)
    if t1 is not None:
        if len(t1) > 16:
            print("Length Warning: ", t1)
        oled.text("{}".format(t1), 0, 0)
    if t2 is not None:
        if len(t2) > 16:
            print("Length Warning: ", t2)
        oled.text("{}".format(t2), 0, 10)
    if t3 is not None:
        if len(t3) > 16:
            print("Length Warning: ", t3)
        oled.text("{}".format(t2), 0, 20)
    oled.show()

def get_uid():
    return "".join(["{:02x}".format(b) for b in machine.unique_id()])
### Helpers End ###

### Buttons Start ###
# Debouncer (share one between all buttons due to quick timescale)
last_interrupt = time.ticks_ms()

def button_cb(pin):
    global last_interrupt, alarm_set
    if (time.ticks_diff(time.ticks_ms(), last_interrupt) < 100):
        # Ignore interrupt if another one just occurred (within 100 ms)
        return
    last_val = pin.value()
    steady = 0
    while steady < 50:
        # Only accept an interrupt after the value has been steady for 50 ms
        time.sleep_ms(1)
        val = pin.value()
        if val != last_val:
            steady = 0
            last_val = val
        else:
            steady += 1
    last_interrupt = time.ticks_ms()
    if not last_val: # Button pressed down
        if pin == btn_b:
            btn_b_cb()
        elif pin == btn_c:
            btn_c_cb()

# Register rising interrupts for buttons
btn_b.irq(trigger=machine.Pin.IRQ_FALLING, handler=button_cb)
btn_c.irq(trigger=machine.Pin.IRQ_FALLING, handler=button_cb)
### Buttons End ###

### Configuration Start ###
RISE_THRESHOLD = 4000
FALL_THRESHOLD = 2000
SAME_THRESHOLD = 1000
AVG_THRESHOLD = 5000
CALIB_WEIGHTS = [20, 50] # in grams
NICKEL_WEIGHT = 5 # in grams
NUM_AVG_READINGS = 7
### Configuration End ###

### State Start ###
class State():
    LOW = 0
    HIGH = 1
    STEADY = 2

state = State.LOW
read_buffer = []
### State End ###

### Steady Conditions Start ###
def local_steady(rb):
    if len(rb) < 2:
        return False
    return abs(rb[-1] - rb[-2]) < SAME_THRESHOLD

def avg_steady(rb):
    if len(rb) < NUM_AVG_READINGS:
        return False
    return abs(rb[-1] - sum(rb[-NUM_AVG_READINGS:])/NUM_AVG_READINGS) < AVG_THRESHOLD

steady_conditions = [local_steady, avg_steady]
### Steady Conditions End ###

### Calibration Start ###
def tare_scale(c):
    m_per_gram = float(c[1]-c[0])/(CALIB_WEIGHTS[1]-CALIB_WEIGHTS[0])
    tare_point = c[0]-CALIB_WEIGHTS[0]*m_per_gram
    print("Tared to: ", tare_point)
    hx.set_gram(m_per_gram)
    hx.adjust_offset(tare_point)

def calib_start():
    global measurement_cb
    oled_text("Calibration", "Don't touch")
    hx.tare(3)
    oled_text("Calibration", "Put {} nickels".format(CALIB_WEIGHTS[0] // NICKEL_WEIGHT)) # Four nickels, 20g
    measurement_cb = calib_1

def calib_1(m):
    global calib_data, measurement_cb
    calib_data = [m, None]
    oled_text("Remove all then", "put {} nickels".format(CALIB_WEIGHTS[1] // NICKEL_WEIGHT)) # Ten nickels, 50g
    measurement_cb = calib_2

def calib_2(m):
    global calib_data, measurement_cb
    calib_data[1] = m
    tare_scale(calib_data)
    oled_text("Calib. Complete", "ID: {}".format(get_uid()))
    measurement_cb = on_measure

calib_data = None
### Calibration End ###

### Callbacks Start ###
## Note: additional callbacks in Calibration section above ##
def on_measure(m):
    print("Measurement: {}".format(m))

btn_b_cb = lambda: print("BTNB")
btn_c_cb = calib_start
measurement_cb = on_measure
### Callbacks End ###

while True:
    r = hx.read()
    print("DEBUG", r, state)
    if state == State.LOW:
        if r > RISE_THRESHOLD:
            read_buffer.clear()
            state = State.HIGH
    elif state == State.HIGH:
        if r < FALL_THRESHOLD:
            state = State.LOW
        read_buffer.append(r)
        conds = [f(read_buffer) for f in steady_conditions]
        if all(conds):
            print("Steady reading: {}".format(r))
            print("Grams: {}".format(hx.to_grams(r)))
            measurement_cb(r)
            state = State.STEADY
    elif state == State.STEADY:
        if r < FALL_THRESHOLD:
            state = State.LOW

    time.sleep_ms(10)

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
