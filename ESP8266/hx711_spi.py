# Based off code from https://github.com/robert-hh/hx711

from machine import idle
import time


class HX711:
    def __init__(self, pd_sck, dout, spi, gain=128):
        self.pSCK = pd_sck
        self.pOUT = dout
        self.spi = spi

        self.pSCK(0)

        self.clock_25 = b'\xaa\xaa\xaa\xaa\xaa\xaa\x80'
        self.clock_26 = b'\xaa\xaa\xaa\xaa\xaa\xaa\xa0'
        self.clock_27 = b'\xaa\xaa\xaa\xaa\xaa\xaa\xa8'
        self.clock = self.clock_25
        self.lookup = (b'\x00\x01\x00\x00\x02\x03\x00\x00\x00\x00\x00\x00'
                       b'\x00\x00\x00\x00\x04\x05\x00\x00\x06\x07\x00\x00'
                       b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
                       b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
                       b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
                       b'\x00\x00\x00\x00\x08\x09\x00\x00\x0a\x0b\x00\x00'
                       b'\x00\x00\x00\x00\x00\x00\x00\x00\x0c\x0d\x00\x00'
                       b'\x0e\x0f')
        self.in_data = bytearray(7)

        self.OFFSET = 0
        self.GRAM = 1

        self.time_constant = 0.1
        self.filtered = 0

        self.set_gain(gain)

    def set_gain(self, gain):
        if gain is 128:
            self.clock = self.clock_25
        elif gain is 64:
            self.clock = self.clock_27
        elif gain is 32:
            self.clock = self.clock_26

        self.read()
        self.filtered = self.read()
        # print('Gain & initial value set')

    def __read(self):
        # wait for the device to get ready
        for _ in range(500):
            if self.pOUT() == 0:
                break
            time.sleep_ms(1)
        else:
            raise OSError("Sensor does not respond")

        # get the data and set channel and gain
        self.spi.write_readinto(self.clock, self.in_data)

        # pack the data into a single value
        result = 0
        for _ in range(6):
            result = (result << 4) + self.lookup[self.in_data[_] & 0x55]

        # return sign corrected result
        return result - ((result & 0x800000) << 1)

    def _read(self): # Account for hardware imperfections
        readings = []
        while True:
            r = self.__read()
            if r != -1:
                readings.append(r)
                if len(readings) == 5: # Median of 5
                    return sorted(readings)[2]
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
        print("Offset: ", self.OFFSET)

    def set_gram(self, amt):
        self.GRAM = amt

    def set_offset(self, offset):
        self.OFFSET = offset

    def adjust_offset(self, adjustment):
        self.OFFSET += adjustment

    def set_time_constant(self, time_constant=None):
        if time_constant is None:
            return self.time_constant
        elif 0 < time_constant < 1.0:
            self.time_constant = time_constant

    def power_down(self):
        self.pSCK.value(False)
        self.pSCK.value(True)

    def power_up(self):
        self.pSCK.value(False)
