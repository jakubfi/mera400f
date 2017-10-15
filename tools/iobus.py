#!/usr/bin/python3

import sys
import serial

UART_DEBUG = 0

REQ = 1
RESP = 0

PA = 0b0000
CL = 0b0001
W = 0b0010
R = 0b0011
S = 0b0100
F = 0b0101
IN = 0b0110
CPK = 0b1000
CPR = 0b1001
CPF = 0b1010
CPS = 0b1011

EN = 1
OK = 2
PE = 3

requests = {
    0b0000: "PA",
    0b0001: "CL",
    0b0010: "W",
    0b0011: "R",
    0b0100: "S",
    0b0101: "F",
    0b0110: "IN",
    0b0111: "0111",
    0b1000: "CPK",
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
class IOBus:

    # --------------------------------------------------------------------
    def __init__(self, device, baud):
        self.s = serial.Serial(
            port = device,
            baudrate = baud,
            bytesize = serial.EIGHTBITS,
            parity = serial.PARITY_NONE,
            stopbits = serial.STOPBITS_ONE,
            timeout = None,
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

    # ------------------------------------------------------------------------
    def sread(self):
        data = ord(self.s.read(1))
        if UART_DEBUG: print("UART RX: %s" % data, file=sys.stderr)
        return data

    # ------------------------------------------------------------------------
    def swrite(self, data):
        if UART_DEBUG: print("UART TX: %s" % data, file=sys.stderr)
        self.s.write(data)

    # --------------------------------------------------------------------
    def read(self):
        mi = Message.fromserial(self)
        #print(mi, file=sys.stderr)
        return mi

    # --------------------------------------------------------------------
    def write(self, m):
        #print(m, file=sys.stderr)
        self.swrite(m.serialize())

    # --------------------------------------------------------------------
    def fileno(self):
        return self.s.fileno()

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
    def fromserial(cls, iobus):
        msg = []
        pos = 0
        msg.append(iobus.sread())
        mtype = (msg[pos] >> 7) & 1
        cmd = (msg[pos] >> 3) & 0b1111
        has_a1 = (msg[pos] >> 2) & 1
        has_a2 = (msg[pos] >> 1) & 1
        has_a3 = (msg[pos] >> 0) & 1
        pos += 1

        if has_a1:
            msg.append(iobus.sread())
            a1 = msg[pos]
            pos += 1
        else:
            a1 = None

        if has_a2:
            msg.append(iobus.sread())
            msg.append(iobus.sread())
            a2 = 256 * msg[pos] + msg[pos+1]
            pos += 2
        else:
            a2 = None

        if has_a3:
            msg.append(iobus.sread())
            msg.append(iobus.sread())
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

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
