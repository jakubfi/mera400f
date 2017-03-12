#!/usr/bin/env python3

import serial
import readline
from subprocess import Popen, PIPE, STDOUT

# ------------------------------------------------------------------------
def serial_open(device, baud):
    s = serial.Serial(
        port = device,
        baudrate = baud,
        bytesize = serial.EIGHTBITS,
        parity = serial.PARITY_NONE,
        stopbits = serial.STOPBITS_ONE,
        timeout = 1,
        xonxoff = False,
        rtscts = False,
        dsrdtr = False)

    s.flushInput()
    s.flushOutput()
    print("%s @ %i bps" % (device, baud))
    return s

functions = {
    "start"     : 0b00100001,
    "stop"      : 0b00100000,
    "mode1"     : 0b00100011,
    "mode0"     : 0b00100010,
    "clk1"      : 0b00100101,
    "clk0"      : 0b00100100,
    "stopn"     : 0b00100111,
    "step"      : 0b00101001,
    "fetch"     : 0b00101011,
    "store"     : 0b00101101,
    "cycle"     : 0b00101111,
    "load"      : 0b00110001,
    "bin"       : 0b00110011,
    "oprq"      : 0b00110101,
    "clear"     : 0b00110111,

    "r0"        : 0b11100000,
    "r1"        : 0b11100001,
    "r2"        : 0b11100010,
    "r3"        : 0b11100011,
    "r4"        : 0b11100100,
    "r5"        : 0b11100101,
    "r6"        : 0b11100110,
    "r7"        : 0b11100111,

    "ic"        : 0b11101000,
    "ac"        : 0b11101001,
    "ar"        : 0b11101010,
    "ir"        : 0b11101011,
    "rs"        : 0b11101100,
    "rz"        : 0b11101101,
    "kb"        : 0b11101110,
}

# ------------------------------------------------------------------------
def cp(s, cmd):
    s.write([functions[cmd]])

# ------------------------------------------------------------------------
def send_keys(val):
    print("Keys: 0x%04x" % val)
    k1 = (val >> 0)  & 0b111111
    k2 = (val >> 6)  & 0b11111
    k3 = (val >> 11) & 0b11111
    s.write([0b01000000 | k1])
    s.write([0b10000000 | k2])
    s.write([0b10100000 | k3])

# ------------------------------------------------------------------------
def programmer(s, tab):
    input_process(s, "stop;clear;0;ic;load;ar;load;kb")
    count = 0
    for word in tab:
        input_process(s, "%s;store" % word)
        count += 1
    print("%i word(-s) uploaded" % count)

# ------------------------------------------------------------------------
def asm(s, l):
    tab = []
    print("running emas: %s" % l)
    p = Popen(['emas', '-O', 'debug'], stdout=PIPE, stdin=PIPE, stderr=PIPE)
    stdout_data = p.communicate(l.encode('ascii'))[0].decode('ascii').split("\n")
    for line in stdout_data:
        if len(line) > 0 and "none" not in line:
            print("   %s" % line)
            dls = line.split()
            tab.append(dls[3])
    programmer(s, tab)

# ------------------------------------------------------------------------
def upload(s, f):
    tab = []
    print("Uploading: %s" % f)
    fh = open(f, "rb")
    while True:
        w = fh.read(2)
        if len(w)<2:
            break
        word = 256*w[0] + w[1]
        tab.append(word)
    programmer(s, tab)

# ------------------------------------------------------------------------
def cmd_process(s, line):
    a = line.lower().split()
    cmd = a[0]
    if len(a) == 0:
        return 0
    elif cmd == "help":
        print(functions.keys())
    elif cmd == "quit":
        return 1
    elif cmd == "asm":
        asm(s, line[4:])
    elif cmd == "upload":
        upload(s, a[1])
    elif cmd in functions:
        cp(s, cmd)
    else:
        try:
            val = int(cmd, 0)
        except:
            print("No such command: %s" % a[0])
            return 0
        send_keys(val)

    return 0

# ------------------------------------------------------------------------
def input_process(s, line):
    for cmd in line.split(";"):
        quit = cmd_process(s, cmd)

# ------------------------------------------------------------------------
def cmd_loop(s):
    quit = 0
    while not quit:
        try:
            line = input("CPU> ")
            input_process(s, line)
        except (EOFError, KeyboardInterrupt):
            print("")
            quit = 1

# ------------------------------------------------------------------------
# --- MAIN ---------------------------------------------------------------
# ------------------------------------------------------------------------

readline.set_history_length(1000)

s = serial_open("/dev/ttyUSB0", 1000000)
cmd_loop(s)
s.close()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
