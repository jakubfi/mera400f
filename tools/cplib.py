#!/usr/bin/env python3

import serial

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
class m4state:
# ------------------------------------------------------------------------

    # --------------------------------------------------------------------
    def __init__(self, val):
        self.data = val[0]*256 + val[1]
        self.rot = val[3] >> 4
        self.rot_n = rot_names[self.rot]
        self.sleds = (val[2] << 2) | (val[3] & 0b11)
        self.mode = (self.sleds >> 9) & 1
        self.stopn = (self.sleds >> 8) & 1
        self.clock = (self.sleds >> 7) & 1
        self.q = (self.sleds >> 6) & 1
        self.p = (self.sleds >> 5) & 1
        self.mc = (self.sleds >> 4) & 1
        self.irq = (self.sleds >> 3) & 1
        self.run = (self.sleds >> 2) & 1
        self.wait = (self.sleds >> 1) & 1
        self.alarm = (self.sleds >> 0) & 1
        self.leds = ""
        for name in ['mode', 'stopn', 'clock', 'q', 'p', 'mc', 'irq', 'run', 'wait', 'alarm']:
            if self.__dict__[name]:
                self.leds += name + " "

    # --------------------------------------------------------------------
    def __str__(self):
        return "%s 0x%04x (%i) %s" % (self.rot_n, self.data, self.data, self.leds)

# ------------------------------------------------------------------------
class m4cp:
# ------------------------------------------------------------------------

    # --------------------------------------------------------------------
    def __init__(self, device, baud):
        self.s = serial.Serial(
            port = device,
            baudrate = baud,
            bytesize = serial.EIGHTBITS,
            parity = serial.PARITY_NONE,
            stopbits = serial.STOPBITS_ONE,
            timeout = 1,
            xonxoff = False,
            rtscts = False,
            dsrdtr = False)

        self.s.flushInput()
        self.s.flushOutput()

    # --------------------------------------------------------------------
    def close(self):
        self.s.flushInput()
        self.s.flushOutput()
        self.s.close()
    
    # --------------------------------------------------------------------
    def cmd(self, cmd):
        try:
            self.s.write([functions[cmd.lower()]])
        except:
            raise SyntaxError("No such command: %s" % cmd)

    # --------------------------------------------------------------------
    def keys(self, val):
        k1 = (val >> 0)  & 0b111111
        k2 = (val >> 6)  & 0b11111
        k3 = (val >> 11) & 0b11111
        self.s.write([0b01000000 | k1])
        self.s.write([0b10000000 | k2])
        self.s.write([0b10100000 | k3])

    # --------------------------------------------------------------------
    def state(self):
        self.s.write([0b11000000])
        res = self.s.read(4)
        return m4state(res)

    # --------------------------------------------------------------------
    def cmds(self, line):
        commands = line.lower().split(";")
        for cmd in commands:
            if cmd in functions:
                self.cmd(cmd)
            else:
                try:
                    val = int(cmd, 0)
                except:
                    raise SyntaxError("No such command: %s" % cmd)
                self.keys(val)

    # --------------------------------------------------------------------
    def upload(self, start_addr, tab):
        pre_s = self.state()
        self.cmds("mode0;clk0;stop;clear;0;ic;load;%i;ar;load;kb" % start_addr)
    
        for word in tab:
            self.cmds("%s;store" % word)
    
        self.cmds("ar;0;load;ac")
        count = 0;
        for word in tab:
            self.cmds("fetch")
            state = self.state()
            if word != state.data:
                raise IOError("UPLOAD FAILED @ %i: expected 0x%04x, got 0x%04x" % (count, word, state.data))
            count += 1
    
        self.cmds(pre_s.rot_n);

    # --------------------------------------------------------------------
    def upload_file(self, start_addr, f):
        tab = []
        fh = open(f, "rb")
        while True:
            w = fh.read(2)
            if len(w)<2:
                break
            word = 256*w[0] + w[1]
            tab.append(word)

        self.upload(start_addr, tab)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
