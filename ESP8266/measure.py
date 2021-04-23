import machine, ssd1306, network, time, urequests, ujson, random
from hx711_gpio import HX711
from mfrc522 import MFRC522

# Connect to OLED
i2c = machine.I2C(-1, machine.Pin(5), machine.Pin(4))
oled = ssd1306.SSD1306_I2C(128, 32, i2c)

# Rotate OLED 180 degrees
oled.write_cmd(ssd1306.SET_COM_OUT_DIR)
oled.write_cmd(ssd1306.SET_SEG_REMAP)

# OLED Buttons
#btn_b = machine.Pin(0, machine.Pin.IN)
btn_c = machine.Pin(2, machine.Pin.IN)

# Initialize HX711 (scale)
pin_MOSI = machine.Pin(15, machine.Pin.OUT)
pin_MISO = machine.Pin(16, machine.Pin.IN)
hx = HX711(pin_MOSI, pin_MISO)

# Initialize MFRC522 (tag reader)
rdr = MFRC522(0)

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
        oled.text("{}".format(t3), 0, 20)
    oled.show()

def uid_to_str(uid):
    return "".join(["{:02x}".format(b) for b in uid])

def get_uid():
    return uid_to_str(machine.unique_id())
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
        '''if pin == btn_b:
            btn_b_cb()'''
        if pin == btn_c:
            btn_c_cb()

# Register rising interrupts for buttons
#btn_b.irq(trigger=machine.Pin.IRQ_FALLING, handler=button_cb)
btn_c.irq(trigger=machine.Pin.IRQ_FALLING, handler=button_cb)
### Buttons End ###

### Configuration Start ###
RISE_THRESHOLD = 4000
FALL_THRESHOLD = 2000
SAME_THRESHOLD = 1000
AVG_THRESHOLD = 5000
CALIB_WEIGHTS = [20, 50] # in grams
NICKEL_WEIGHT = 5 # in grams
NUM_AVG_READINGS = 4
NUM_TAG_TRIES = 10
TAP_DURATION_MIN = 50 # in milliseconds
TAP_DURATION_MAX = 300 # in milliseconds
DOUBLE_TAP_DUR_MIN = 200 # in milliseconds
DOUBLE_TAP_DUR_MAX = 750 # in milliseconds
CALIB_FILE = "nutriscient.calibration"
MOV_AVG_FACTOR = 0.35
API_ENDPOINT = "http://ec2-35-153-232-54.compute-1.amazonaws.com:8000/add_weight"
DATA_SEND_TRIES = 5
### Configuration End ###

### State Start ###
class State():
    LOW = 0
    HIGH = 1
    STEADY = 2

state = State.LOW
read_buffer = []
last_tap_time = time.ticks_ms()
tap_timer = time.ticks_ms()
tap_state = State.LOW
moving_average = None
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
    hx.set_offset(c[2] + tare_point)

def calib_start():
    global measurement_cb, double_tap_cb
    double_tap_cb = lambda: None
    oled.invert(1)
    oled_text("Calibration", "Don't touch")
    hx.tare(3)
    oled_text("Calibration", "Put {} nickels".format(CALIB_WEIGHTS[0] // NICKEL_WEIGHT)) # Four nickels, 20g
    measurement_cb = calib_1

def calib_1(m):
    global calib_data, measurement_cb
    calib_data = [m, None]
    oled_text("Remove all then", "put {} nickels".format(CALIB_WEIGHTS[1] // NICKEL_WEIGHT)) # Ten nickels, 50g
    oled.invert(1)
    measurement_cb = calib_2

def calib_2(m):
    global calib_data, measurement_cb, double_tap_cb
    calib_data[1] = m
    calib_data.append(hx.OFFSET) # Store calibration baseline tare
    store_calibration()
    calib_complete(loaded_from_file=False)
    oled.invert(1)
    measurement_cb = on_measure
    double_tap_cb = calib_start

def calib_complete(loaded_from_file):
    global calib_data, moving_average, tap_state
    tare_scale(calib_data)
    moving_average = hx.read()
    tap_state = State.LOW
    oled_text("Calib. Loaded" if loaded_from_file else "Calib. Complete", "ID: {}".format(get_uid()))

def store_calibration():
    global calib_data
    if calib_data is None:
        return
    dat = " ".join([str(i) for i in calib_data])
    with open(CALIB_FILE, "w") as f:
        f.write(dat)

def load_calibration():
    global calib_data
    try:
        with open(CALIB_FILE, "r") as f:
            l = f.readline()
            d = l.split(" ")
            if len(d) != len(CALIB_WEIGHTS) + 1:
                return False
            calib_data = []
            for p in d:
                try:
                    v = float(p)
                    calib_data.append(v)
                except ValueError: # Not an integer
                    calib_data = None
                    return False
            return True
                    
    except OSError: # File not found
        return False

calib_data = None
### Calibration End ###

### Tag Reader Start ###
def read_tag():
    for _ in range(NUM_TAG_TRIES):
        (stat, tag_type) = rdr.request(rdr.REQIDL)
        print("STAT", stat)
        if stat == rdr.OK:
            (stat, raw_uid) = rdr.anticoll()
            if stat == rdr.OK:
                return uid_to_str(raw_uid)
    return None
### Tag Reader End ###

### Networking Start ###
def wifi_setup():
    # Get Network SSID and Password
    with open("wifi.txt", "r") as f:
        ssid = f.readline().rstrip("\r\n")
        password = f.readline().rstrip("\r\n")

    # Connect to Wi-Fi
    sta = network.WLAN(network.STA_IF)
    if not sta.isconnected():
        sta.active(True)
        sta.connect(ssid, password)
        print("Connecting to Wi-Fi")
        oled_text("Connecting...")
        while not sta.isconnected():
            pass
    print("Connected to Wi-Fi!")

def send_to_server(uid, rfid, kg):
    #wparam = {'Client-Id': uid, 'RFID-Id': rfid, 'Weight': kg}
    req_target = API_ENDPOINT + "?Client-Id={}&RFID-Id={}&Weight={}".format(uid, rfid, kg)
    for _ in range(DATA_SEND_TRIES):
        try:
            res = urequests.post(req_target)
            if res.status_code == 200:
                return
        except OSError:
            time.sleep_ms(10)
    oled_text("Network Error.")
### Networking End ###

### Callbacks Start ###
## Note: additional callbacks in Calibration section above ##
def on_clear():
    oled.invert(0)

def on_measure(m):
    print("Measurement: {}".format(m))
    uid = get_uid()
    rfid_tag = read_tag()
    kg_weight = round(hx.to_grams(m)/1000, 3)
    print("Tag: {}".format(read_tag()))
    oled_text("Weight: {:.3f}kg".format(kg_weight), "ID: {}".format(uid),
              "Tag Detected" if rfid_tag is not None else "No Tag Found")
    oled.invert(1)
    if rfid_tag is not None: # Can send data after object is removed for speed
        send_to_server(uid, rfid_tag, kg_weight)

def on_tap():
    global last_tap_time
    t = time.ticks_ms()
    #print("DURDD", t - last_tap_time)
    if DOUBLE_TAP_DUR_MIN < (t - last_tap_time) < DOUBLE_TAP_DUR_MAX:
        double_tap_cb()
    last_tap_time = t

def on_button():
    oled_text(None)

#btn_b_cb = lambda: print("BTNB")
btn_c_cb = on_button
s2l_cb = on_clear # Steady to low
measurement_cb = on_measure
tap_cb = on_tap
double_tap_cb = calib_start
### Callbacks End ###

### Pre-Loop Start ###
wifi_setup()

if not load_calibration():
    calib_start()
else:
    calib_complete(True)
### Pre-Loop End ###

while True:
    r = hx.read()
    #print("DEBUG", r, state)
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
            measurement_cb(sum(read_buffer[-2:])/2.0) # Pass in average of last two
            state = State.STEADY
    elif state == State.STEADY:
        if r < FALL_THRESHOLD:
            s2l_cb()
            state = State.LOW

    # The tap input is handled with its own dynamically-updating "tare"
    # This is done to ensure that taps can be detected even when
    # calibration was performed incorrectly, allowing for recovery
    # from such a state.
    moving_average += (r - moving_average) * MOV_AVG_FACTOR
    #print("TAPDEBUG", moving_average, tap_state)
    if tap_state == State.LOW and r > moving_average + RISE_THRESHOLD:
        tap_timer = time.ticks_ms()
        tap_state = State.HIGH
    elif tap_state == State.HIGH and r < moving_average + FALL_THRESHOLD:
        tap_duration = time.ticks_ms() - tap_timer
        #print("DUR", tap_duration)
        if TAP_DURATION_MIN < tap_duration < TAP_DURATION_MAX:
            tap_cb()
        tap_state = State.LOW

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
