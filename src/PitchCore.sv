
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

    localparam READ_HEADER = 0;
    localparam READ_DATA   = 1;

    logic [3:0] state, n_state;
    logic       data_state, n_data_state;

    logic n_pitch_done;
    logic n_pitch_read, n_pitch_write;
    logic [22:0] n_pitch_addr;
    logic [31:0] n_pitch_writedata;

    logic [31:0] data_length;
    logic [15:0] left_data [255:0];
    logic [15:0] right_data[255:0];
    logic [31:0] counter, n_counter;

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
            pitch_done <= 0;
            pitch_read <= 0;
            pitch_write <= 0;
            pitch_addr <= 23'd0;
            pitch_writedata <= 32'd0;
            counter <= 0;
            data_state <= 0;
        end else begin
            state <= n_state;
            pitch_done <= n_pitch_done;
            pitch_read <= n_pitch_read;
            pitch_write <= n_pitch_write;
            pitch_addr <= n_pitch_addr;
            pitch_writedata <= n_pitch_writedata;
            n_counter <= counter;
            n_data_state <= data_state;
        end 
    end

    always_comb begin
        n_state = state;
        pitch_done = n_pitch_done;
        pitch_read = n_pitch_read;
        pitch_write = n_pitch_write;
        pitch_addr <= n_pitch_addr;
        pitch_writedata <= n_pitch_writedata;
        counter = n_counter;
        data_state = n_data_state;
        case (state)
            IDLE: begin
                if (pitch_start) begin
                    n_state = READ_SDRAM;
                    n_pitch_read = 1;
                    n_pitch_addr = pitch_select[0];
                end
            end
            READ_SDRAM: begin
                case (data_state)
                    READ_HEADER: begin
                        if (pitch_sdram_finished == 1) begin
                            data_length = pitch_readdata;
                        end
                    end
                    READ_DATA: begin
                        if (pitch_sdram_finished == 1) begin
                            n_counter = counter + 1;
                            left_data[counter] = pitch_readdata[31:16];
                            right_data[counter] = pitch_readdata[15:0];
                            if (counter == 255) begin
                                n_counter = 0;
                                n_state = OLA_COMPUTE;
                            end
                        end
                    end
                endcase
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
