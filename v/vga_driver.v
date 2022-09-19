`timescale 1ns / 1ps
`default_nettype none

module vga_driver(
    input  wire CLK,                // board clock: 50 MHz on MAX10
    input  wire RST_BTN_N,
    output wire VGA_HS,
    output wire VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
    );

    wire vga_clk;
    wire clk_locked;

	 
	 // VGA timings were taken from this post
	 // https://projectf.io/posts/video-timings-vga-720p-1080p/
	 //
	 // Resolution     640x480    800x600 		1280x720 	1920x1080
	 // Clock (MHz)     25.175         40     	74.25 	    148.5
	 // Multiplier          74          4        	95    	    95
	 // Divider            147          5        	64       	 32
	 // 50 MHz = 20000 ps
	 
    vga_clock #(                  
        .MULTIPLY_BY(74),         
        .DIVIDE_BY(147),             
        .IN_PERIOD_PS(20000)
    )
    u0
    (
       .i_clk(CLK),
       .i_rst(~RST_BTN_N),
       .o_clk(vga_clk),
       .o_locked(clk_locked)
    );

    wire signed [15:0] sx;
    wire signed [15:0] sy;
	 
    wire h_sync;
    wire v_sync;
    wire de;                        // display enabled
    wire frame;

    vga_generator #(                // 640x480  800x600 1280x720 1920x1080
        .H_RES(640),                //     640      800     1280      1920
        .V_RES(480),                //     480      600      720      1080
        .H_FPORCH(16),              //      16       40      110        88
        .H_SYNC(96),                //      96      128       40        44
        .H_BPORCH(48),              //      48       88      220       148
        .V_FPORCH(10),              //      10        1        5         4
        .V_SYNC(2),                 //       2        4        5         5
        .V_BPORCH(33),              //      33       23       20        36
        .H_POL(0),                  //       0        1        1         1
        .V_POL(0)                   //       0        1        1         1
    )
    u1 (
        .i_clk(vga_clk),
        .i_rst(!clk_locked),
        .o_hs(h_sync),
        .o_vs(v_sync),
        .o_de(de),
        .o_frame(frame),
        .o_sx(sx),
        .o_sy(sy)
    );

    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    simple_display #(
        .H_RES(640),
		  .V_RES(480)
    ) u2 (
		  .i_clk(vga_clk),
        .i_x(sx),
		  .i_y(sy),
		  .i_frame(frame),
        .o_r(red),
        .o_g(green),
        .o_b(blue)
    );

    assign VGA_HS   = h_sync;
    assign VGA_VS   = v_sync;
    assign VGA_R    = de ? red : 4'b0;
    assign VGA_G    = de ? green : 4'b0;
    assign VGA_B    = de ? blue : 4'b0;
	 
endmodule