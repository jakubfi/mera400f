#!/usr/bin/python3

import serial
import random
import sys

s = serial.Serial(
    port = "/dev/ttyUSB1",
    baudrate = 1000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    timeout = 1,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False)

s.flushInput()
s.flushOutput()

while True:
    x = s.read()

    if not x:
        continue

    cmd = ord(x);
    print(format(cmd, "08b"))

s.close()
