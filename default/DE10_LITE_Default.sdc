#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]

# SDRAM CLK
create_generated_clock -source [get_pins {u0|altpll_0|sd1|pll7|clk[1]}] -name clk_dram_ext [get_ports {DRAM_CLK}]
# workaround for on-chip flash
create_generated_clock -source [get_pins {u0|onchip_flash|avmm_data_controller|flash_se_neg_reg|clk}] -name flash_se_neg_reg -divide_by 2 [get_pins {u0|onchip_flash|avmm_data_controller|flash_se_neg_reg|q}]

create_generated_clock -source {u2|u0|altpll_inst|auto_generated|pll1|inclk[0]} -name clk_vga -divide_by 147 -multiply_by 74 -duty_cycle 50.00 {u2|u0|altpll_inst|auto_generated|pll1|clk[0]}

create_clock -period "30.303 ns" -name {altera_reserved_tck} {altera_reserved_tck}

create_clock -period "5MHz" -name clk_spi_ext [get_ports {GSENSOR_SCLK}]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************

# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)
# max 5.4(max) +0.4(trace delay) +0.1 = 5.9
# min 2.7(min) +0.4(trace delay) -0.1 = 3.0
set_input_delay -max -clock [get_clocks {clk_dram_ext}] 5.9 [get_ports {DRAM_DQ*}]
set_input_delay -min -clock [get_clocks {clk_dram_ext}] 3.0 [get_ports {DRAM_DQ*}]


set_input_delay -max -clock [get_clocks {u0|altpll_0|sd1|pll7|clk[0]}] 0.0 [get_ports {ARDUINO_IO[1] ARDUINO_IO[2] ARDUINO_RESET_N}]
set_input_delay -min -clock [get_clocks {u0|altpll_0|sd1|pll7|clk[0]}] -0.0 [get_ports {ARDUINO_IO[1] ARDUINO_IO[2] ARDUINO_RESET_N}]

set_input_delay -max -clock [get_clocks {clk_spi_ext}] 0.0  [get_ports {GSENSOR_SDI}]
set_input_delay -min -clock [get_clocks {clk_spi_ext}] -0.0 [get_ports {GSENSOR_SDI}]


#**************************************************************
# Set Output Delay
#**************************************************************

# suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
# max 1.5+0.1 =1.6
# min -0.8-0.1 = 0.9
set_output_delay -max -clock [get_clocks {clk_dram_ext}] 1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock [get_clocks {clk_dram_ext}] -0.9 [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock [get_clocks {clk_dram_ext}] 1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock [get_clocks {clk_dram_ext}] -0.9 [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]


set_output_delay -max -clock [get_clocks {clk_vga}] 0.0 [get_ports {VGA_R*}]
set_output_delay -min -clock [get_clocks {clk_vga}] -0.0 [get_ports {VGA_R*}]
set_output_delay -max -clock [get_clocks {clk_vga}] 0.0 [get_ports {VGA_G*}]
set_output_delay -min -clock [get_clocks {clk_vga}] -0.0 [get_ports {VGA_G*}]
set_output_delay -max -clock [get_clocks {clk_vga}] 0.0 [get_ports {VGA_B*}]
set_output_delay -min -clock [get_clocks {clk_vga}] -0.0 [get_ports {VGA_B*}]
set_output_delay -max -clock [get_clocks {clk_vga}] 0.0 [get_ports {VGA_HS VGA_VS}]
set_output_delay -min -clock [get_clocks {clk_vga}] -0.0 [get_ports {VGA_HS VGA_VS}]


set_output_delay -max -clock [get_clocks {clk_spi_ext}] 0.0  [get_ports {GSENSOR_SDO GSENSOR_CS_N}]
set_output_delay -min -clock [get_clocks {clk_spi_ext}] -0.0 [get_ports {GSENSOR_SDO GSENSOR_CS_N}]

set_output_delay -max -clock [get_clocks {u0|altpll_0|sd1|pll7|clk[0]}] 0.0 [get_ports {ARDUINO_IO[3]}]
set_output_delay -min -clock [get_clocks {u0|altpll_0|sd1|pll7|clk[0]}] -0.0 [get_ports {ARDUINO_IO[3]}]

#**************************************************************
# Set Clock Groups
#**************************************************************


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from * -to [get_ports LEDR*]
set_false_path -from * -to [get_ports HEX0*]
set_false_path -from * -to [get_ports HEX1*]
set_false_path -from * -to [get_ports HEX2*]
set_false_path -from * -to [get_ports HEX3*]
set_false_path -from * -to [get_ports HEX4*]
set_false_path -from * -to [get_ports HEX5*]

set_false_path -from [get_ports {KEY[0] KEY[1]}] -to *

set_false_path -from [get_ports SW*] -to *

set_false_path -from * -to [get_ports altera_reserved_tdo]
set_false_path -from [get_ports altera_reserved_tdi] -to *
set_false_path -from [get_ports altera_reserved_tms] -to *

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from [get_clocks {clk_dram_ext}] -to [get_clocks {u0|altpll_0|sd1|pll7|clk[0]}] -setup 2


#**************************************************************
# Set Maximum Delay
#**************************************************************


#**************************************************************
# Set Minimum Delay
#**************************************************************


#**************************************************************
# Set Input Transition
#**************************************************************


#**************************************************************
# Set Load
#**************************************************************
