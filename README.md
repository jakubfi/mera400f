
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

All signal names match those on original schematics, with the following
'cosmetic' changes:

* all signal names are lowercase instead of uppercase,
* bus signals are grouped together (IR0..IR15 becomes ir[0:15]),
* special characters (star, up arrow, parentheses, equal signs, ...) are replaced with underscores:
  * with a single underscore, when special character occures in the middle of the name (eg. `W->LEGY` becomes `w_legy`),
  * with a double underscore, when special character is at the end (eg. `OK*` becomes `ok__`),
  * with a single underscores for complex names (eg. `I3/EX+PRZER/` becomes `i3_ex_przer`, `CK->RZ*W` becomes `ck_rz_w`),

Additional signal names (that are not part of the original schematics) start with double underscore.

