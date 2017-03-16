#!/usr/bin/env python3

import serial
import readline
from subprocess import Popen, PIPE, STDOUT

rot_names = {
     0 : "R0",
     1 : "R1",
     2 : "R2",
     3 : "R3",
     4 : "R4",
     5 : "R5",
     6 : "R6",
     7 : "R7",
     8 : "IC",
     9 : "AC",
    10 : "AR",
    11 : "IR",
    12 : "SR",
    13 : "RZ",
    14 : "KB",
    15 : "KB"
} 

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
    "sr"        : 0b11101100,
    "rz"        : 0b11101101,
    "kb"        : 0b11101110,
}

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

# ------------------------------------------------------------------------
def cp(s, cmd):
    s.write([functions[cmd]])

# ------------------------------------------------------------------------
def send_keys(val):
    k1 = (val >> 0)  & 0b111111
    k2 = (val >> 6)  & 0b11111
    k3 = (val >> 11) & 0b11111
    s.write([0b01000000 | k1])
    s.write([0b10000000 | k2])
    s.write([0b10100000 | k3])

# ------------------------------------------------------------------------
def programmer(s, tab):
    pre_s = get_state(s)
    input_process(s, "mode0;clk0;stop;clear;0;ic;load;ar;load;kb")

    for word in tab:
        input_process(s, "%s;store" % word)

    input_process(s, "ar;0;load;ac")
    for word in tab:
        input_process(s, "fetch")
        state = get_state(s)
        if word != state['data']:
            print("UPLOAD FAILED!")
            return

    print("%i word(-s) uploaded and verified OK" % len(tab))
    input_process(s, pre_s['rotaryn']);

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
            tab.append(int(dls[3], 0))
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
def get_state(s):
    s.write([0b11000000])
    res = s.read(4)
    dleds = res[0]*256 + res[1]
    rot = res[3] >> 4
    sleds = (res[2] << 2) | (res[3] & 0b11)
    status = {
        'data' : dleds,
        'rotary' : rot,
        'rotaryn' : rot_names[rot],
        'mode' : (sleds >> 9) & 1,
        'stopn' : (sleds >> 8) & 1,
        'clock' : (sleds >> 7) & 1,
        'q' : (sleds >> 6) & 1,
        'p' : (sleds >> 5) & 1,
        'mc' : (sleds >> 4) & 1,
        'irq' : (sleds >> 3) & 1,
        'run' : (sleds >> 2) & 1,
        'wait' : (sleds >> 1) & 1,
        'alarm' : (sleds >> 0) & 1,
        'leds' : ""
    }
    for name in ['mode', 'stopn', 'clock', 'q', 'p', 'mc', 'irq', 'run', 'wait', 'alarm']:
        if status[name]:
            status['leds'] += name + " "
    return status

# ------------------------------------------------------------------------
def state(s):
    leds = get_state(s);
    print("%s 0x%04x (%i) %s" % (leds['rotaryn'], leds['data'], leds['data'], leds['leds']))

# ------------------------------------------------------------------------
def cmd_process(s, line):
    a = line.lower().split()
    try:
        cmd = a[0]
    except IndexError:
        state(s)
        return 0
    if cmd == "help":
        print(functions.keys())
    elif cmd == "quit":
        return 1
    elif cmd == "asm":
        asm(s, line[4:])
    elif cmd == "upload":
        upload(s, a[1])
    elif cmd == "s":
        state(s)
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
    return quit

# ------------------------------------------------------------------------
def cmd_loop(s):
    quit = 0
    while not quit:
        try:
            line = input("CPU> ")
            quit = input_process(s, line)
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
