#!/usr/bin/python

import Adafruit_DHT
import time
import datetime
import urllib2

# Sensor should be set to Adafruit_DHT.DHT11,
# Adafruit_DHT.DHT22, or Adafruit_DHT.AM2302.
sensor = Adafruit_DHT.DHT11

# Example using a Beaglebone Black with DHT sensor
# connected to pin P8_11.
pin = 'P8_11'

# Example using a Raspberry Pi with DHT sensor
# connected to GPIO23.
#pin = 23
urltplt = "https://data.sparkfun.com/input/mKqnMWXv7nhVyd5Amlr0?private_key=kzBpkZg5PpFWep84yZrk&humidity=%.2f&temp=%.2f"

while True:
    humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
    if humidity is not None and temperature is not None:
	req = urltplt % (humidity,temperature)
        print(req)
        response = urllib2.urlopen(req)
        the_page = response.read()
    else:
        print('Failed to get reading. Try again!')
    time.sleep(60*5)
