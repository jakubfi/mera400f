
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
* signals that are not named on schematic get the name `Mxx_yy` where x is the component number, y is the pin number,
* components get uppercase names (related to component function)
* active-low signal names end with underscore
* special characters treatment:
  * special character in the middle of the name is replaced with an underscore (eg. `W->LEGY` becomes `w_legy`, `-EKC*2` becomes `ekc_2_`),
  * star at the end of signal name is replaced with dollar sign (eg. `OK*` becomes `ok$`),
  * `W&` changes name to `w$` (and `-W&` becomes `w$_`),
  * in complex names underscores are used as replacements (eg. `I3/EX+PRZER/` becomes `i3_ex_przer`, `CK->RZ*W` becomes `ck_rz_w`),


