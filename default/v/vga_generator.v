module vga_generator #(
    H_RES=640,
    V_RES=480,
    H_FPORCH=16,
    H_SYNC=96,
    H_BPORCH=48,
    V_FPORCH=10,
    V_SYNC=2,
    V_BPORCH=33,
    H_POL=0,                        // horizontal sync polarity (0:neg, 1:pos)
    V_POL=0                         // vertical sync polarity (0:neg, 1:pos)
    )
    (
    input  wire i_clk,
    input  wire i_rst,
    output wire o_hs,
    output wire o_vs,
    output wire o_de,               // display enable - high during active video
    output wire o_frame,            // high for one tick at the beginning of each frame
    output reg signed [15:0] o_sx,  // x-coord, includes blanking
    output reg signed [15:0] o_sy   // y-coord, includes blanking
    );

    localparam signed [15:0] H_START  = 0 - H_FPORCH - H_SYNC - H_BPORCH;
    localparam signed [15:0] H_SYNC_START = H_START + H_FPORCH;
    localparam signed [15:0] H_SYNC_END = H_SYNC_START + H_SYNC;
    localparam signed [15:0] H_ACTIVE_START = 0;
    localparam signed [15:0] H_ACTIVE_END = H_RES - 1;

    localparam signed [15:0] V_START  = 0 - V_FPORCH - V_SYNC - V_BPORCH;
    localparam signed [15:0] V_SYNC_START = V_START + V_FPORCH; 
    localparam signed [15:0] V_SYNC_END = V_SYNC_START + V_SYNC;
    localparam signed [15:0] V_ACTIVE_START = 0;
    localparam signed [15:0] V_ACTIVE_END = V_RES - 1;

    assign o_hs = H_POL ? (o_sx > H_SYNC_START && o_sx <= H_SYNC_END)
        : ~(o_sx > H_SYNC_START && o_sx <= H_SYNC_END);
    assign o_vs = V_POL ? (o_sy > V_SYNC_START && o_sy <= V_SYNC_END)
        : ~(o_sy > V_SYNC_START && o_sy <= V_SYNC_END);

    assign o_de = (o_sx >= 0 && o_sy >= 0);
    assign o_frame = (o_sy == V_START && o_sx == H_START);

    always @ (posedge i_clk)
    begin
        if (i_rst)
        begin
            o_sx <= H_START;
            o_sy <= V_START;
        end
        else
        begin
            if (o_sx == H_ACTIVE_END)  // end of line
            begin
                o_sx <= H_START;
                if (o_sy == V_ACTIVE_END)  // end of frame
                    o_sy <= V_START;
                else
                    o_sy <= o_sy + 16'sh1;
            end
            else
                o_sx <= o_sx + 16'sh1;
        end
    end

endmodule