#!/usr/bin/python3

import serial
import random
import sys
import array
import argparse
import iobus

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
def send_req(iobus, args):
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
        iobus.write(mo)
        mi = iobus.read()
        print(mi)

# ------------------------------------------------------------------------
# --- MAIN ---------------------------------------------------------------
# ------------------------------------------------------------------------

iobus = iobus.IOBus("/dev/ttyUSB0", 1000000);

parser = argparse.ArgumentParser()

parser.add_argument('-a', type=int, help='Address')
parser.add_argument('-v', type=int, help='Value')
parser.add_argument('-i', action='store_true', help='Send interrupt')
parser.add_argument('-r', action='store_true', help='Read word')
parser.add_argument('-w', action='store_true', help='Write word')

args = parser.parse_args()

if args.i or args.r or args.w:
    send_req(iobus, args)
    sys.exit(0)

addr = 0
addrm = 0
cnt = 0
intspec = 0
mem = array.array('H', (0,) * 0x10000)

while True:
    mi = iobus.read()
    print(mi)

    # no reply to CLEAR needed
    if mi.cmd == CMD_CL:
        continue

    # always reply to SEND
    if mi.cmd == CMD_S:
        mo = Message(MSG_RESP, CMD_OK)
        iobus.write(mo)
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
            iobus.write(mo)
            mi = iobus.read()
            while mi.type != MSG_RESP:
                print("%s (ignored)" % mi)
                mi = iobus.read()
            print(mi)

        elif op == OP_PAL:
            mo = Message(MSG_REQ, CMD_PAL)
            print(mo)
            iobus.write(mo)

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
                iobus.write(mo)
                mi = iobus.read()
                while mi.type != MSG_RESP:
                    print("%s (ignored)" % mi)
                    mi = iobus.read()
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
                iobus.write(mi)
                mi = iobus.read()
                while mi.type != MSG_RESP:
                    print("%s (ignored)" % mi)
                    mi = iobus.read()
                print(mi)
                c += 1
                addr += 1
                addrm += 1

        elif op == OP_GET:
            mo = Message(MSG_RESP, CMD_OK, a3=mem[addr])
            iobus.write(mo)
            print(mo)
            addr += 1

        elif op == OP_PUT:
            mem[addr] = mi.a3
            addr += 1

        elif op == OP_SPEC:
            mo = Message(MSG_RESP, CMD_OK, a3=intspec)
            iobus.write(mo)
            print(mo)

s.close()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
