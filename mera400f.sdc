create_clock -period 50MHz -name CLK_EXT [get_ports {CLK_EXT}]
derive_pll_clocks
set_clock_groups -asynchronous -group {CLK_EXT}
