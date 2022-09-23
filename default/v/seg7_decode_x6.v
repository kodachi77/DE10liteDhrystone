`timescale 1ns / 1ps
`default_nettype none

module seg7_decode_x6 (input [23:0] bcd_array, 
    output  [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    seg7_decode    u0  ( HEX0, bcd_array[3:0]   );
    seg7_decode    u1  ( HEX1, bcd_array[7:4]   );
    seg7_decode    u2  ( HEX2, bcd_array[11:8]  );
    seg7_decode    u3  ( HEX3, bcd_array[15:12] );
    seg7_decode    u4  ( HEX4, bcd_array[19:16] );
    seg7_decode    u5  ( HEX5, bcd_array[23:20] );

endmodule