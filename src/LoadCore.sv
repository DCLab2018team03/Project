
// Initialization
// Write pre-recorded audio data into the SDRAM
// Output done when all data has been transfered

// refresh signal when change address(byteenable issue)

module LoadCore (
    input i_clk,
    input i_rst,

    // To controller
    output loaddata_done,

    // To SDRAM
    output loaddata_write,
    output [22:0] loaddata_addr,
    output [15:0] loaddata_writedata,
    input  loaddata_sdram_finished,
    output loaddata_sdram_refresh

    // To RS232
);
    
endmodule