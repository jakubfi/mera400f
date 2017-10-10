#!/usr/bin/python3

import serial
import random
import sys
import array
import argparse

UART_DEBUG = 0

MSG_REQ = 1
MSG_RESP = 0

CMD_PAL = 0b0000
CMD_CL = 0b0001
CMD_W = 0b0010
CMD_R = 0b0011
CMD_S = 0b0100
CMD_F = 0b0101
CMD_IN = 0b0110
CMD_CPD = 0b1000
CMD_CPR = 0b1001
CMD_CPF = 0b1010
CMD_CPS = 0b1011

CMD_EN = 1
CMD_OK = 2
CMD_PE = 3

requests = {
    0b0000: "PA",
    0b0001: "CL",
    0b0010: "W",
    0b0011: "R",
    0b0100: "S",
    0b0101: "F",
    0b0110: "IN",
    0b0111: "0111",
    0b1000: "CPD",
    0b1001: "CPR",
    0b1010: "CPF",
    0b1011: "CPS",
    0b1100: "1100",
    0b1101: "1101",
    0b1110: "1110",
    0b1111: "1111"
}

replies = {
    0b0001: "EN",
    0b0010: "OK",
    0b0011: "PE"
}

# ------------------------------------------------------------------------
def sread(s):
    data = ord(s.read(1))
    if UART_DEBUG: print("UART RX: %s" % data)
    return data

# ------------------------------------------------------------------------
def swrite(s, data):
    if UART_DEBUG: print("UART TX: %s" % data)
    s.write(data)

# ------------------------------------------------------------------------
class Message:

    # --------------------------------------------------------------------
    def __init__(self, mtype, cmd, a1=None, a2=None, a3=None, direction="  "):
        self.type = mtype
        self.cmd = cmd
        self.a1 = a1
        self.a2 = a2
        self.a3 = a3
        self.direction = direction

    # --------------------------------------------------------------------
    @classmethod
    def fromserial(cls, s):
        msg = []
        pos = 0
        msg.append(sread(s))
        mtype = (msg[pos] >> 7) & 1
        cmd = (msg[pos] >> 3) & 0b1111
        has_a1 = (msg[pos] >> 2) & 1
        has_a2 = (msg[pos] >> 1) & 1
        has_a3 = (msg[pos] >> 0) & 1
        pos += 1

        if has_a1:
            msg.append(sread(s))
            a1 = msg[pos]
            pos += 1
        else:
            a1 = None

        if has_a2:
            msg.append(sread(s))
            msg.append(sread(s))
            a2 = 256 * msg[pos] + msg[pos+1]
            pos += 2
        else:
            a2 = None

        if has_a3:
            msg.append(sread(s))
            msg.append(sread(s))
            a3 = 256 * msg[pos] + msg[pos+1]
        else:
            a3 = None

        return cls(mtype, cmd, a1, a2, a3, direction="->")

    # --------------------------------------------------------------------
    def __str__(self):
        return "%s %-4s %-4s %s  %s  %s" % (
            self.direction,
            ("REQ" if self.type else "RESP"),
            requests[self.cmd] if self.type else replies[self.cmd],
            (("A1: 0x%02x" % self.a1) if self.a1 is not None else "A1: ----"),
            (("A2: 0x%04x" % self.a2) if self.a2 is not None else "A2: ------"),
            (("A3: 0x%04x" % self.a3) if self.a3 is not None else "A3: ------")
        )

    # --------------------------------------------------------------------
    def serialize(self):
        t = [(self.type << 7) | (self.cmd << 3)]

        if self.a1 is not None:
            t[0] |= 0b100
            t.append(self.a1)
        if self.a2 is not None:
            t[0] |= 0b10
            t.append(self.a2 >> 8)
            t.append(self.a2 & 0xff)
        if self.a3 is not None:
            t[0] |= 1
            t.append(self.a3 >> 8)
            t.append(self.a3 & 0xff)

        return t

OP_INT      = 0b0001
OP_LDA      = 0b0010
OP_RD       = 0b0011
OP_WR       = 0b0100
OP_GET      = 0b0101
OP_PUT      = 0b0110
OP_SPEC     = 0b1000
OP_LDM      = 0b1001
OP_PAL       = 0b1010

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
def send_req(s, args):
    mo = None
    if args.i:
        if args.v is None:
            print("Need a value");
        else:
            mo = Message(MSG_REQ, CMD_IN, a3=args.v)
    elif args.r:
        if args.a is None:
            print("Need an address");
        else:
            mo = Message(MSG_REQ, CMD_R, a2=args.a)
    elif args.w:
        if args.v is None or args.a is None:
            print("Need a value and an address");
        else:
            mo = Message(MSG_REQ, CMD_W, a2=args.a, a3=args.v)

    if mo is not None:
        print(mo)
        swrite(s, mo.serialize())
        print("Waiting for the reply from the CPU")
        mi = Message.fromserial(s)
        print(mi)

# ------------------------------------------------------------------------
# --- MAIN ---------------------------------------------------------------
# ------------------------------------------------------------------------

s = serial.Serial(
    port = "/dev/ttyUSB1",
    baudrate = 1000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    timeout = None,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False)

s.flushInput()
s.flushOutput()

parser = argparse.ArgumentParser()

parser.add_argument('-a', type=int, help='Address')
parser.add_argument('-v', type=int, help='Value')
parser.add_argument('-i', action='store_true', help='Send interrupt')
parser.add_argument('-r', action='store_true', help='Read word')
parser.add_argument('-w', action='store_true', help='Write word')

args = parser.parse_args()

if args.i or args.r or args.w:
    send_req(s, args)
    sys.exit(0)

addr = 0
addrm = 0
cnt = 0
intspec = 0
mem = array.array('H', (0,) * 0x10000)

while True:
    mi = Message.fromserial(s)
    print(mi)

    # no reply to CLEAR needed
    if mi.cmd == CMD_CL:
        continue

    # always reply to SEND
    if mi.cmd == CMD_S:
        mo = Message(MSG_RESP, CMD_OK)
        swrite(s, mo.serialize())
        print(mo)

    # process requests
    if mi.type == MSG_REQ:
        op = (mi.a2 >> 8) & 0b1111
        print("   op   %-4s arg: %s" % (ops[op], mi.a3))

        if op == OP_INT:
            ch = (mi.a2 & 0xff) << 1
            intspec = mi.a3;
            mo = Message(MSG_REQ, CMD_IN, a3=ch)
            print(mo)
            swrite(s, mo.serialize())
            mi = Message.fromserial(s)
            while mi.type != MSG_RESP:
                print("%s (ignored)" % mi)
                mi = Message.fromserial(s)
            print(mi)

        elif op == OP_PAL:
            mo = Message(MSG_REQ, CMD_PAL)
            print(mo)
            swrite(s, mo.serialize())

        elif op == OP_LDA:
            addr = mi.a3

        elif op == OP_LDM:
            addrm = mi.a3

        elif op == OP_RD:
            cnt = mi.a3
            c = 0
            while c < cnt:
                mo = Message(MSG_REQ, CMD_R, a1=0, a2=addrm)
                print(mo)
                swrite(s, mo.serialize())
                mi = Message.fromserial(s)
                while mi.type != MSG_RESP:
                    print("%s (ignored)" % mi)
                    mi = Message.fromserial(s)
                print(mi)
                mem[addr] = mi.a3
                c += 1
                addr += 1
                addrm += 1

        elif op == OP_WR:
            cnt = mi.a3
            c = 0
            while c < cnt:
                mo = Message(MSG_REQ, CMD_W, a1=0, a2=addrm, a3=mem[addr])
                print(mo)
                swrite(s, mo.serialize())
                mi = Message.fromserial(s)
                while mi.type != MSG_RESP:
                    print("%s (ignored)" % mi)
                    mi = Message.fromserial(s)
                print(mi)
                c += 1
                addr += 1
                addrm += 1

        elif op == OP_GET:
            mo = Message(MSG_RESP, CMD_OK, a3=mem[addr])
            swrite(s, mo.serialize())
            print(mo)
            addr += 1

        elif op == OP_PUT:
            mem[addr] = mi.a3
            addr += 1

        elif op == OP_SPEC:
            mo = Message(MSG_RESP, CMD_OK, a3=intspec)
            swrite(s, mo.serialize())
            print(mo)
            pass

s.close()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
