
// Mixing audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)


module MixCore (
    input i_clk,
    input i_rst,
    // To controller
    input  mix_start,
    input  [22:0] mix_select [4:0],
    output mix_done,

    // To SDRAM
    output mix_read,
    output [22:0] mix_addr,
    input  [31:0] mix_readdata,
    output mix_write,
    output [31:0] mix_writedata,
    input  mix_sdram_finished
);
    
endmodule