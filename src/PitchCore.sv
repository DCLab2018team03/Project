
// Pitching audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// mode is either time-stretch or pitch-shift
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
    localparam IDLE = 0;
    localparam READ_SDRAM = 1;
    localparam WRITE_SDRAM = 2;
    localparam OLA_COMPUTE = 3;
    localparam RESAMPLE = 4; // only use when pitch-shift
    logic [3:0] state, n_state;

    logic [:] input_buffer;
    logic [:] output_buffer;
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
        end else begin
            state <= n_state;
        end 
    end

    always_comb begin
        n_state = state;
        case (state)
            IDLE: begin
                if (pitch_start) begin
                    n_state = READ_SDRAM;
                end
            end
            READ_SDRAM: begin

            end 
            WRITE_SDRAM: begin

            end
            OLA_COMPUTE: begin

            end
            RESAMPLE: begin

            end
        endcase
    end
endmodule
