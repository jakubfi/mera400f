cplib.py
===============================

Python library for accessing control panel.

em400f
===============================

Control panel interface that mimics em400 'cmd' user interface (for running em400 tests on fpga).

cp
===============================

Minimal control panel commandline interface. Each command is either a real command, a macro or a number
(decimal, hexadecimal, octal or binary). Entering a number sets data keys to a specified value.
Entering a command sets a function key or rotary switch position.

Available commands:

* `r1`, ..., `r7`, `ac`, `ic`, `ar`, `ir`, `sr`, `rz`, `kb` - register select (rotary switch position)
* `start`, `stop`, `stopn`, `step`, `fetch`, `store`, `cycle`, `load`, `bin`, `oprq`, `clear` - function keys
* `mode0`, `mode1` - mode of operation
* `clk0`, `clk1` - clock on/off

Commands can be chained together using semicolon as a separator, eg.: `0b10110;r1;load` or `clear;ar;0xbeef;load;0o7377;kb;store`

There are also two macros available:

* `upload FILENAME` - uploads contents of a file at address 0 in memory segment 0
* `asm ASSEMBLER_CODE` - assembles the code and uploads it at address 0 (eg. `asm mcl lwt r1,10 awt r1,20 hlt`)
