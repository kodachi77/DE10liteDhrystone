module DE10_LITE_Minimal (

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

    //////////// KEY //////////
    input            [1:0]      KEY
);

    assign DRAM_UDQM = DRAM_LDQM;                               
   
    Embed u0  (
        .clk_clk                             (MAX10_CLK1_50),
        .reset_reset_n                       (1'b1),
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
        .key_external_connection_export      (KEY)
   );
    
endmodule
