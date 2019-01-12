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
    input  pitch_sdram_finished,
    // To SRAM
    inout  logic [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
    output logic [19:0] SRAM_ADDR,   // SRAM Address bus 20 Bits
    output logic        SRAM_WE_N,   // SRAM Write Enable
    output logic        SRAM_CE_N,   // SRAM Chip Enable
    output logic        SRAM_OE_N,   // SRAM Output Enable
    output logic        SRAM_LB_N,   // SRAM Low-byte Data Mask 
    output logic        SRAM_UB_N    // SRAM High-byte Data Mask
);  
    localparam SRAM_NOT_SELECT = 5'b01000;
    localparam SRAM_READ       = 5'b10000;
    localparam SRAM_WRITE      = 5'b00000;
    assign SRAM_DQ = SRAM_WE_N ? 16'hzzzz : n_SRAM_DQ;
    logic [15:0] n_SRAM_DQ;
    logic [19:0] n_SRAM_ADDR;
    
    task setSRAMenable;
    input [4:0] mode;
    begin
        SRAM_WE_N = mode[4];
        SRAM_CE_N = mode[3];
        SRAM_OE_N = mode[2];
        SRAM_LB_N = mode[1];
        SRAM_UB_N = mode[0];
    end    
    endtask

    localparam IDLE = 0;
    localparam READ_SDRAM = 1;
    localparam WRITE_SDRAM = 2;
    localparam APPLY_WINDOW = 3;
    localparam OLA_COMPUTE = 4;
    localparam RESAMPLE = 5; // only use when pitch-shift

    localparam READ_HEADER = 0;
    localparam READ_DATA   = 1;

    logic [3:0] state, n_state;
    logic       data_state, n_data_state;

    logic n_pitch_done;
    logic n_pitch_read, n_pitch_write;
    logic [22:0] n_pitch_addr;
    logic [31:0] n_pitch_writedata;

    logic [12:0] H_a; // = H_s * speed, use H_a[12:3] to discard floating point
    logic [31:0] data_length;
    logic signed [15:0] left_data  [AnalysisFrameSize-1:0];
    logic signed [15:0] right_data [AnalysisFrameSize-1:0];
    logic signed [35:0] left_synthesis_frame  [WindowSize-1:0];
    logic signed [35:0] right_synthesis_frame [WindowSize-1:0];
    logic signed [15:0] left_write_data_prev  [WindowSize-1-1:0];
    logic signed [15:0] left_write_data  [WindowSize-1-1:0];
    logic signed [15:0] right_write_data_prev [WindowSize-1-1:0];
    logic signed [15:0] right_write_data [WindowSize-1-1:0];
    logic [31:0] counter, n_counter;
    logic [9:0] data_counter, n_data_counter;
    integer i;
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
            pitch_done <= 0;
            pitch_read <= 0;
            pitch_write <= 0;
            pitch_addr <= 23'd0;
            pitch_writedata <= 32'd0;
            counter <= 0;
            data_counter <= 0;
            data_state <= 0;
            SRAM_ADDR <= 0;
        end else begin
            state <= n_state;
            pitch_done <= n_pitch_done;
            pitch_read <= n_pitch_read;
            pitch_write <= n_pitch_write;
            pitch_addr <= n_pitch_addr;
            pitch_writedata <= n_pitch_writedata;
            counter <= n_counter;
            data_counter <= n_data_counter;
            data_state <= n_data_state;
            SRAM_ADDR <= n_SRAM_ADDR;
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
        data_counter = n_data_counter;
        data_state = n_data_state;
        n_SRAM_DQ = SRAM_DQ;
        n_SRAM_ADDR = SRAM_ADDR;
        setSRAMenable(SRAM_NOT_SELECT);
        case (state)
            IDLE: begin
                if (pitch_start) begin
                    n_state = READ_SDRAM;
                    n_pitch_read = 1;
                    n_pitch_addr = pitch_select[0];
                    H_a = H_s * speed;
                end
            end
            READ_SDRAM: begin
                n_pitch_addr = pitch_addr + 1;
                case (data_state)
                    READ_HEADER: begin
                        if (pitch_sdram_finished == 1) begin
                            data_length = pitch_readdata;
                            n_data_state = READ_DATA;
                        end
                    end
                    READ_DATA: begin
                        if (pitch_sdram_finished == 1) begin
                            counter = counter + 1;
                            left_data[counter] = pitch_readdata[31:16];
                            right_data[counter] = pitch_readdata[15:0];
                            if (counter == AnalysisFrameSize-1) begin
                                n_counter = 0;
                                n_state = APPLY_WINDOW;
                                n_pitch_read = 0;
                            end
                        end
                    end
                endcase
            end 
            WRITE_SDRAM: begin
                if (counter == 0) begin
                    n_pitch_addr = pitch_select[1];
                    n_pitch_write = 1;
                    n_pitch
                end
                n_pitch_write = 1;
                n_pitch_addr = pitch_addr + 1; 
                n_pitch_writedata = {left_write_data[counter], right_write_data[counter]};

            end
            APPLY_WINDOW: begin
                for (i=0; i<WindowSize; i=i+1) begin
                    left_synthesis_frame[i] = left_data * HANN_C[i];
                    right_synthesis_frame[i] = right_data * HANN_C[i];
                end
                n_state = OLA_COMPUTE;
            end
            OLA_COMPUTE: begin
                for (i=0; i<WindowSize; i=i+1) begin
                    left_write_data[i] = left_synthesis_frame[i][35:20];
                    right_write_data[i] = right_synthesis_frame[i][35:20];
                end
                n_state = WRITE_SDRAM;
                n_counter = 0;
            end
            RESAMPLE: begin

            end
        endcase
    end
endmodule
