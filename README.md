
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


