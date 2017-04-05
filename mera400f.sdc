# Warning, dirty workaround ahead.
# Dummy "clock" to stop fitter from trying to optimize the design forever and not comming up with anything good.
create_clock -period 10MHz -name DUMMY_CLK [get_ports {RXD}]
derive_pll_clocks
set_clock_groups -asynchronous -group {DUMMY_CLK}
