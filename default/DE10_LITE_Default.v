module DE10_LITE_Default(

    //////////// CLOCK //////////
    input                       ADC_CLK_10,
    input                       MAX10_CLK1_50,
    input                       MAX10_CLK2_50,

    //////////// SDRAM //////////
    output          [12:0]      DRAM_ADDR,
    output           [1:0]      DRAM_BA,
    output                      DRAM_CAS_N,
    output                      DRAM_CKE,
    output                      DRAM_CLK,
    output                      DRAM_CS_N,
    inout           [15:0]      DRAM_DQ,
    output                      DRAM_LDQM,
    output                      DRAM_RAS_N,
    output                      DRAM_UDQM,
    output                      DRAM_WE_N,

    //////////// SEG7 //////////
    output           [7:0]      HEX0,
    output           [7:0]      HEX1,
    output           [7:0]      HEX2,
    output           [7:0]      HEX3,
    output           [7:0]      HEX4,
    output           [7:0]      HEX5,

    //////////// KEY //////////
    input            [1:0]      KEY,

    //////////// LED //////////
    output           [9:0]      LEDR,

    //////////// SW //////////
    input            [9:0]      SW,

    //////////// VGA //////////
    output           [3:0]      VGA_B,
    output           [3:0]      VGA_G,
    output                      VGA_HS,
    output           [3:0]      VGA_R,
    output                      VGA_VS,

    //////////// Accelerometer //////////
    output                      GSENSOR_CS_N,
    input            [2:1]      GSENSOR_INT,
    output                      GSENSOR_SCLK,
    inout                       GSENSOR_SDI,
    inout                       GSENSOR_SDO,

    //////////// Arduino //////////
    inout           [15:0]      ARDUINO_IO,
    inout                       ARDUINO_RESET_N,
   //////////// GPIO, GPIO connect to GPIO Default //////////
    inout           [35:0]      GPIO
    
);

   Embed u0  (
        .clk_clk                             (MAX10_CLK1_50),
        .reset_reset_n                       (ARDUINO_RESET_N),
        .clk_0_clk                           (ADC_CLK_10),
        .reset_0_reset_n                     (ARDUINO_RESET_N),
        .ledr_export                         (LEDR),
        .sw_export                           (SW),
        .dram_clk_clk                        (DRAM_CLK),
        .dram_addr                           (DRAM_ADDR),
        .dram_ba                             (DRAM_BA),
        .dram_cas_n                          (DRAM_CAS_N),
        .dram_cke                            (DRAM_CKE),
        .dram_cs_n                           (DRAM_CS_N),
        .dram_dq                             (DRAM_DQ),
        .dram_dqm                            (DRAM_LDQM),
        .dram_ras_n                          (DRAM_RAS_N),
        .dram_we_n                           (DRAM_WE_N),
        .gsensor_MISO                        (GSENSOR_SDI),
        .gsensor_MOSI                        (GSENSOR_SDO),
        .gsensor_SCLK                        (GSENSOR_SCLK),
        .gsensor_SS_n                        (GSENSOR_CS_N),
        .modular_adc_0_adc_pll_locked_export (ARDUINO_IO[1]),
        .altpll_1_areset_conduit_export      (ARDUINO_IO[2]),
        .altpll_1_locked_conduit_export      (ARDUINO_IO[3])
   );

    seg7_decode_x6 u1  ( 
            {23{1'b1}}, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 
    );

    vga_driver u2 ( 
            .CLK                             (MAX10_CLK2_50), 
            .RST_BTN_N                       (ARDUINO_RESET_N), 
            .VGA_HS                          (VGA_HS),
            .VGA_VS                          (VGA_VS),
            .VGA_R                           (VGA_R),
            .VGA_G                           (VGA_G),
            .VGA_B                           (VGA_B)
    );
    
    assign DRAM_UDQM = DRAM_LDQM;                               
 
endmodule
