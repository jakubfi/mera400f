
About mera400f
============================================

Mera400f is a reimplementation of MERA-400 CPU in Verilog.
It aims to be 100% true to the original on functional and logical level:
it uses the same signals running through the same functional blocks,
yielding the same results. It does not try to redo the 74xx
implementation, but rather reimplement the logical structure
using current tools.


Signal naming changes
============================================

All names match those on original schematic, with the following 'cosmetic' changes:

* all signal names are lowercase instead of uppercase,
* bus signals are grouped together (IR0..IR15 becomes ir[0:15]),
* additional named signals get the name `Mxx_yy` where x is the component number, y is the pin number from which the signal originates,
* components and submodules get uppercase names (related to component function, in most cases),
* active-low signal names end with underscore,
* special characters treatment:
  * special characters in the middle of the name are replaced with an underscore (eg. `W->LEGY` becomes `w_legy`, `-EKC*2` becomes `ekc_2_`),
  * star or atmark at the end of signal name is replaced with dollar sign (eg. `OK*` becomes `ok$`, `-W&` becomes `w$_`),
  * for complex names underscores are used as special characters replacements (eg. `I3/EX+PRZER/` becomes `i3_ex_przer`, `CK->RZ*W` becomes `ck_rz_w`),
* signal names which start with a number are prefixed with an underscore (eg. `0->V` becomes `_0_v`),
* polish diacritics are replaced with non-diacritics,
* for a couple of signal names polarity (and also the name) has been changed to reflect the reality

Control Panel serial protocol
============================================

Control Panel recognizes following serial commands (8N1):

* `001 FFFF V` - Set function key FFFF (see below) to position V (0-off, 1-on)
* `01 KKKKKK` - set data keys 10-15 to binary value K
* `100 KKKKK` - set data keys 5-9 to binary value K
* `101 KKKKK` - set data keys 0-4 to binary value K
* `110 xxxxx` - read LED status (unimplemented)
* `111 xPPPP` - Set rotary switch to position PPPP (see below)

`x` bits value doesn't matter.

Function keys (FFFF):

* `0000` - START
* `0001` - MODE
* `0010` - CLOCK
* `0011` - STOP*N (momentary)
* `0100` - STEP (momentary)
* `0101` - FETCH (momentary)
* `0110` - STORE (momentary)
* `0111` - CYCLE (momentary)
* `1000` - LOAD (momentary)
* `1001` - BIN (momentary)
* `1010` - OPRQ (momentary)
* `1011` - CLEAR (momentary)

If a momentary switch is set to 1, it automaticaly bounces back, there is no need to explicitly set it back to 0.

Rotary switch positions (PPPP):

* `0000` - R0
* `0001` - R1
* `0010` - R2
* `0011` - R3
* `0100` - R4
* `0101` - R5
* `0110` - R6
* `0111` - R7
* `1000` - IC
* `1001` - AC
* `1010` - AR
* `1011` - IR
* `1100` - RS
* `1101` - RZ
* `1110` - KB
