module vga_clock #(
    MULTIPLY_BY=74,         // master clock multiplier
    DIVIDE_BY=147,          // master clock divider
    IN_PERIOD_PS=20000      // period of i_clk in ps (50 MHz = 20000 ps)
    )
    (
    input  wire i_clk,      // input clock
    input  wire i_rst,      // reset (active high)
    output wire o_clk,      // output clock
    output wire o_locked    // is lock locked (active high)
    );
	localparam CLK_WIDTH = 5;
	
	wire [CLK_WIDTH-1:0] clk_output;
	assign o_clk = clk_output[0:0];
	 
	altpll  altpll_inst (
                .areset (i_rst),
                .inclk ({1'b0, i_clk}),
                .clk (clk_output),
                .locked (o_locked),
                .activeclock (),
                .clkbad (),
                .clkena ({6{1'b1}}),
                .clkloss (),
                .clkswitch (1'b0),
                .configupdate (1'b0),
                .enable0 (),
                .enable1 (),
                .extclk (),
                .extclkena ({4{1'b1}}),
                .fbin (1'b1),
                .fbmimicbidir (),
                .fbout (),
                .fref (),
                .icdrclk (),
                .pfdena (1'b1),
                .phasecounterselect ({4{1'b1}}),
                .phasedone (),
                .phasestep (1'b1),
                .phaseupdown (1'b1),
                .pllena (1'b1),
                .scanaclr (1'b0),
                .scanclk (1'b0),
                .scanclkena (1'b1),
                .scandata (1'b0),
                .scandataout (),
                .scandone (),
                .scanread (1'b0),
                .scanwrite (1'b0),
                .sclkout0 (),
                .sclkout1 (),
                .vcooverrange (),
                .vcounderrange ());
    defparam
        altpll_inst.bandwidth_type = "AUTO",
        altpll_inst.clk0_divide_by = DIVIDE_BY,
        altpll_inst.clk0_duty_cycle = 50,
        altpll_inst.clk0_multiply_by = MULTIPLY_BY,
        altpll_inst.clk0_phase_shift = "0",
        altpll_inst.compensate_clock = "CLK0",
        altpll_inst.inclk0_input_frequency = IN_PERIOD_PS,
        altpll_inst.intended_device_family = "MAX 10",
        altpll_inst.lpm_hint = "CBX_MODULE_PREFIX=vga_altpll",
        altpll_inst.lpm_type = "altpll",
        altpll_inst.operation_mode = "NORMAL",
        altpll_inst.pll_type = "AUTO",
        altpll_inst.port_activeclock = "PORT_UNUSED",
        altpll_inst.port_areset = "PORT_USED",
        altpll_inst.port_clkbad0 = "PORT_UNUSED",
        altpll_inst.port_clkbad1 = "PORT_UNUSED",
        altpll_inst.port_clkloss = "PORT_UNUSED",
        altpll_inst.port_clkswitch = "PORT_UNUSED",
        altpll_inst.port_configupdate = "PORT_UNUSED",
        altpll_inst.port_fbin = "PORT_UNUSED",
        altpll_inst.port_inclk0 = "PORT_USED",
        altpll_inst.port_inclk1 = "PORT_UNUSED",
        altpll_inst.port_locked = "PORT_USED",
        altpll_inst.port_pfdena = "PORT_UNUSED",
        altpll_inst.port_phasecounterselect = "PORT_UNUSED",
        altpll_inst.port_phasedone = "PORT_UNUSED",
        altpll_inst.port_phasestep = "PORT_UNUSED",
        altpll_inst.port_phaseupdown = "PORT_UNUSED",
        altpll_inst.port_pllena = "PORT_UNUSED",
        altpll_inst.port_scanaclr = "PORT_UNUSED",
        altpll_inst.port_scanclk = "PORT_UNUSED",
        altpll_inst.port_scanclkena = "PORT_UNUSED",
        altpll_inst.port_scandata = "PORT_UNUSED",
        altpll_inst.port_scandataout = "PORT_UNUSED",
        altpll_inst.port_scandone = "PORT_UNUSED",
        altpll_inst.port_scanread = "PORT_UNUSED",
        altpll_inst.port_scanwrite = "PORT_UNUSED",
        altpll_inst.port_clk0 = "PORT_USED",
        altpll_inst.port_clk1 = "PORT_UNUSED",
        altpll_inst.port_clk2 = "PORT_UNUSED",
        altpll_inst.port_clk3 = "PORT_UNUSED",
        altpll_inst.port_clk4 = "PORT_UNUSED",
        altpll_inst.port_clk5 = "PORT_UNUSED",
        altpll_inst.port_clkena0 = "PORT_UNUSED",
        altpll_inst.port_clkena1 = "PORT_UNUSED",
        altpll_inst.port_clkena2 = "PORT_UNUSED",
        altpll_inst.port_clkena3 = "PORT_UNUSED",
        altpll_inst.port_clkena4 = "PORT_UNUSED",
        altpll_inst.port_clkena5 = "PORT_UNUSED",
        altpll_inst.port_extclk0 = "PORT_UNUSED",
        altpll_inst.port_extclk1 = "PORT_UNUSED",
        altpll_inst.port_extclk2 = "PORT_UNUSED",
        altpll_inst.port_extclk3 = "PORT_UNUSED",
        altpll_inst.self_reset_on_loss_lock = "OFF",
        altpll_inst.width_clock = CLK_WIDTH;
	 
endmodule