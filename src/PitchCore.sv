
// Pitching audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// mode is either speed-up or shift frequency
// speed is the required ratio of each of them

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)
`include "PitchDefine.sv"

module PitchCore (
    input i_clk,
    input i_rst,
    // To controller
    input  pitch_start,
    input  [22:0] pitch_select [1:0],
    input  pitch_mode,
    input  [3:0] pitch_speed,
    output pitch_done,

    // To SDRAM
    output pitch_read,
    output [22:0] pitch_addr,
    input  [31:0] pitch_readdata,
    output pitch_write,
    output [31:0] pitch_writedata,
    input  pitch_sdram_finished
);

    
    
endmodule

module HannWindow (
    input i_clk,
    input [$clog2(WindowSize):0] address, // address for get Hanning Window value
    output [15:0] coeff // not sure about the bit length yet
);
    logic [15:0] coeff;
    always_ff (posedge i_clk) begin
	case (address)
        8'h00: coeff = 15'h0000;
        
    
    endcase
endmodule
