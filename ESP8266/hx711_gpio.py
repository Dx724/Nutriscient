# Based off code from https://github.com/robert-hh/hx711

from machine import enable_irq, disable_irq, idle
import time

class HX711:
    def __init__(self, pd_sck, dout, gain=128):
        self.pSCK = pd_sck
        self.pOUT = dout
        self.pSCK.value(False)

        self.GAIN = 0
        self.OFFSET = 0
        self.GRAM = 1

        self.READ_SAMPLES = 1 # Set to 5 on faulty hardware

        self.time_constant = 0.25
        self.filtered = 0

        self.set_gain(gain)

    def set_gain(self, gain):
        if gain is 128:
            self.GAIN = 1
        elif gain is 64:
            self.GAIN = 3
        elif gain is 32:
            self.GAIN = 2

        self.read()
        self.filtered = self.read()

    def is_ready(self):
        return self.pOUT() == 0

    def __read(self):
        # wait for the device being ready
        for _ in range(500):
            if self.pOUT() == 0:
                break
            time.sleep_ms(1)
        else:
            raise OSError("Sensor does not respond")

        # shift in data, and gain & channel info
        result = 0
        for j in range(24 + self.GAIN):
            state = disable_irq()
            self.pSCK(True)
            self.pSCK(False)
            enable_irq(state)
            result = (result << 1) | self.pOUT()

        # shift back the extra bits
        result >>= self.GAIN

        # check sign
        if result > 0x7fffff:
            result -= 0x1000000

        return result

    def _read(self): # Account for hardware imperfections
        readings = []
        while True:
            r = self.__read()
            if r != -1:
                readings.append(r)
                if len(readings) == self.READ_SAMPLES: # Take median
                    return sorted(readings)[self.READ_SAMPLES // 2]
            else:
                time.sleep_ms(1)

    def read(self): # Read tared value
        return self._read() - self.OFFSET

    def _read_average(self, times=3):
        sum = 0
        for i in range(times):
            sum += self._read()
        return sum / times

    def read_average(self, times=3):
        return self._read_average(times) - self.OFFSET

    def read_lowpass(self):
        self.filtered += self.time_constant * (self.read() - self.filtered)
        return self.filtered

    def get_value(self):
        return self.read_lowpass() - self.OFFSET

    def to_grams(self, m):
        return float(m) / self.GRAM

    def tare(self, times=15):
        self.set_offset(self._read_average(times))

    def set_gram(self, amt):
        self.GRAM = amt

    def set_offset(self, offset):
        self.OFFSET = offset

    def adjust_offset(self, adjustment):
        self.OFFSET += adjustment

    def set_time_constant(self, time_constant = None):
        if time_constant is None:
            return self.time_constant
        elif 0 < time_constant < 1.0:
            self.time_constant = time_constant

    def power_down(self):
        self.pSCK.value(False)
        self.pSCK.value(True)

    def power_up(self):
        self.pSCK.value(False)
