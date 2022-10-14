`timescale 1ns / 1ps
`default_nettype none

module simple_display #(
        H_RES=640,
        V_RES=480
    ) (
	 input wire i_clk,
    input wire signed [15:0] i_x,
    input wire signed [15:0] i_y,
	 input wire i_frame,
    output wire [3:0] o_r,
    output wire [3:0] o_g,
    output wire [3:0] o_b
    );

    localparam FRAME_CNT = 60;
	 
    reg [$clog2(FRAME_CNT):0] frame_cnt;
    reg [3:0] color_idx;
	 reg color_inc;
	 
	 initial begin
		color_inc <= 1'b1;
	 end

    always @(posedge i_clk) begin
        if (i_frame) begin
		  
				if(color_idx == 4'hE) begin
					color_inc <= ~color_inc;
				end
				
            if (frame_cnt == FRAME_CNT-1) begin
               frame_cnt <= 0;
               color_idx <= (color_inc) ? color_idx + 4'b01 : color_idx - 4'b01;
            end else frame_cnt <= frame_cnt + 4'b01;
        end
    end

    assign o_r = color_idx;
    assign o_g = i_x[7:4];
    assign o_b = i_y[7:4];

endmodule
