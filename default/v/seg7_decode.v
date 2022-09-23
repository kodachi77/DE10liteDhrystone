`timescale 1ns / 1ps
`default_nettype none

module seg7_decode(input [3:0] bcd, output reg [7:0] hex);
    always @(bcd)
    begin
        case(bcd)
            4'h0: hex = 8'b11000000;
            4'h1: hex = 8'b11111001;    // x--0--x
            4'h2: hex = 8'b10100100;    // |     |
            4'h3: hex = 8'b10110000;    // 5     1
            4'h4: hex = 8'b10011001;    // |     |
            4'h5: hex = 8'b10010010;    // x--6--x
            4'h6: hex = 8'b10000010;    // |     |
            4'h7: hex = 8'b11111000;    // 4     2
            4'h8: hex = 8'b10000000;    // |     |
            4'h9: hex = 8'b10011000;    // x--3--x
                  
            default: hex = 8'b11111111;
        endcase
    end
endmodule
