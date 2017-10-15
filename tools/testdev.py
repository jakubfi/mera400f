#!/usr/bin/python3

import sys
import array
import argparse
import iobus

OP_INT  = 0b0001
OP_LDA  = 0b0010
OP_RD   = 0b0011
OP_WR   = 0b0100
OP_GET  = 0b0101
OP_PUT  = 0b0110
OP_SPEC = 0b1000
OP_LDM  = 0b1001
OP_PAL  = 0b1010

ops = {
    0: "0",
    1: "int",
    2: "lda",
    3: "rd",
    4: "wr",
    5: "get",
    6: "put",
    7: "7",
    8: "spec",
    9: "ldm",
    10: "pal",
    11: "11",
    12: "12",
    13: "13",
    14: "14",
    15: "15"
}

# ------------------------------------------------------------------------
class TestDev:

    # --------------------------------------------------------------------
    def __init__(self, iobus):
        self.iobus = iobus
        self.addr = 0
        self.addrm = 0
        self.intspec = 0
        self.mem = array.array('H', (0,) * 0x10000)

    # --------------------------------------------------------------------
    def process(self):
        mi = self.iobus.read()
        print(mi)
    
        # no reply to CLEAR needed
        if mi.cmd == iobus.CL:
            return
    
        # always reply to SEND
        if mi.cmd == iobus.S:
            mo = iobus.Message(iobus.RESP, iobus.OK)
            self.iobus.write(mo)
            print(mo)
    
        # process requests
        if mi.type == iobus.REQ:
            op = (mi.a2 >> 8) & 0b1111
            print("   op   %-4s arg: %s" % (ops[op], mi.a3))
    
            if op == OP_INT:
                ch = (mi.a2 & 0xff) << 1
                self.intspec = mi.a3;
                mo = iobus.Message(iobus.REQ, iobus.IN, a3=ch)
                print(mo)
                self.iobus.write(mo)
                mi = self.iobus.read()
                while mi.type != iobus.RESP:
                    print("%s (ignored)" % mi)
                    mi = self.iobus.read()
                print(mi)
    
            elif op == OP_PAL:
                mo = iobus.Message(iobus.REQ, iobus.PAL)
                print(mo)
                self.iobus.write(mo)
    
            elif op == OP_LDA:
                self.addr = mi.a3
    
            elif op == OP_LDM:
                self.addrm = mi.a3
    
            elif op == OP_RD:
                cnt = mi.a3
                c = 0
                while c < cnt:
                    mo = iobus.Message(iobus.REQ, iobus.R, a1=0, a2=self.addrm)
                    print(mo)
                    self.iobus.write(mo)
                    mi = self.iobus.read()
                    while mi.type != iobus.RESP:
                        print("%s (ignored)" % mi)
                        mi = self.iobus.read()
                    print(mi)
                    self.mem[self.addr] = mi.a3
                    c += 1
                    self.addr += 1
                    self.addrm += 1
    
            elif op == OP_WR:
                cnt = mi.a3
                c = 0
                while c < cnt:
                    mo = iobus.Message(iobus.REQ, iobus.W, a1=0, a2=self.addrm, a3=self.mem[self.addr])
                    print(mo)
                    self.iobus.write(mo)
                    mi = self.iobus.read()
                    while mi.type != iobus.RESP:
                        print("%s (ignored)" % mi)
                        mi = self.iobus.read()
                    print(mi)
                    c += 1
                    self.addr += 1
                    self.addrm += 1
    
            elif op == OP_GET:
                mo = iobus.Message(iobus.RESP, iobus.OK, a3=self.mem[self.addr])
                self.iobus.write(mo)
                print(mo)
                self.addr += 1
    
            elif op == OP_PUT:
                self.mem[self.addr] = mi.a3
                self.addr += 1
    
            elif op == OP_SPEC:
                mo = iobus.Message(iobus.RESP, iobus.OK, a3=self.intspec)
                self.iobus.write(mo)
                print(mo)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
