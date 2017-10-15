#!/usr/bin/env python3

import os
import sys
import iobus

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
    "start" : [ iobus.CPF, 0b00100000 ],
    "stop"  : [ iobus.CPF, 0b00000000 ],
    "mode1" : [ iobus.CPF, 0b00100001 ],
    "mode0" : [ iobus.CPF, 0b00000001 ],
    "clk1"  : [ iobus.CPF, 0b00100010 ],
    "clk0"  : [ iobus.CPF, 0b00000010 ],
    "stopn" : [ iobus.CPF, 0b00100011 ],
    "step"  : [ iobus.CPF, 0b00100100 ],
    "fetch" : [ iobus.CPF, 0b00100101 ],
    "store" : [ iobus.CPF, 0b00100110 ],
    "cycle" : [ iobus.CPF, 0b00100111 ],
    "load"  : [ iobus.CPF, 0b00101000 ],
    "bin"   : [ iobus.CPF, 0b00101001 ],
    "oprq"  : [ iobus.CPF, 0b00101010 ],
    "clear" : [ iobus.CPF, 0b00101011 ],

    "r0"    : [ iobus.CPR, 0b00000000 ],
    "r1"    : [ iobus.CPR, 0b00000001 ],
    "r2"    : [ iobus.CPR, 0b00000010 ],
    "r3"    : [ iobus.CPR, 0b00000011 ],
    "r4"    : [ iobus.CPR, 0b00000100 ],
    "r5"    : [ iobus.CPR, 0b00000101 ],
    "r6"    : [ iobus.CPR, 0b00000110 ],
    "r7"    : [ iobus.CPR, 0b00000111 ],
    "ic"    : [ iobus.CPR, 0b00001000 ],
    "ac"    : [ iobus.CPR, 0b00001001 ],
    "ar"    : [ iobus.CPR, 0b00001010 ],
    "ir"    : [ iobus.CPR, 0b00001011 ],
    "sr"    : [ iobus.CPR, 0b00001100 ],
    "rz"    : [ iobus.CPR, 0b00001101 ],
    "kb"    : [ iobus.CPR, 0b00001110 ],
}

# ------------------------------------------------------------------------
class m4state:
# ------------------------------------------------------------------------

    # --------------------------------------------------------------------
    def __init__(self, mi):
        self.data = mi.a2
        self.rot = mi.a3 & 0b1111
        self.rot_n = rot_names[self.rot]
        self.sleds = mi.a3 >> 6
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
    def __init__(self, iobus):
        try:
            self.debug = os.environ['CPDBG']
        except:
            self.debug = 0

        self.iobus = iobus

    # --------------------------------------------------------------------
    def cmd(self, cmd):
        if self.debug:
            print("  %s" % cmd, file=sys.stderr);
        try:
            self.iobus.write(iobus.Message(iobus.REQ, functions[cmd][0], a1=functions[cmd][1]))
        except:
            raise SyntaxError("No such command: %s" % cmd)

    # --------------------------------------------------------------------
    def keys(self, val):
        if self.debug:
            print("  keys: 0x%04x" % val, file=sys.stderr);
        self.iobus.write(iobus.Message(iobus.REQ, iobus.CPK, a3=val))

    # --------------------------------------------------------------------
    def state(self):
        self.iobus.write(iobus.Message(iobus.REQ, iobus.CPS))
        mi = self.iobus.read()
        # ignore everything that doesn't look like response for CP req
        while (mi.type != iobus.RESP) or (mi.cmd != iobus.OK):
            #print(mi)
            mi = self.iobus.read()
        st = m4state(mi)
        if self.debug:
            print("  %s" % st, file=sys.stderr);
        return st;

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
        self.cmds("stop;%i;ar;load;kb" % start_addr)
    
        for word in tab:
            self.cmds("%s;store" % word)
    
        self.cmds("ar;%i;load;ac" % start_addr)
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
