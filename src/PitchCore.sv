// Pitching audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// mode is either time-stretch (0) or pitch-shift (1)
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
    localparam CROSS_CORRELATION = 4;
    localparam OLA_COMPUTE = 5;
    localparam RESAMPLE = 6; // only use when pitch-shift
    localparam PREDICT_NEXT_FRAME = 7;

    localparam READ_HEADER = 0;
    localparam READ_DATA   = 1;

    localparam RESAMPLE_READ = 0;
    localparam RESAMPLE_WRITE = 1;

    logic [3:0] state, n_state;
    logic       data_state, n_data_state;

    logic n_pitch_done;
    logic n_pitch_read, n_pitch_write;
    logic [22:0] n_pitch_addr;
    logic [31:0] n_pitch_writedata;

    logic [12:0] H_a; // = H_s * speed, use H_a[12:3] to discard floating point
    logic [22:0] data_length;
    logic [31:0] counter, n_counter;           // iterate frames
    logic [9:0] data_counter, n_data_counter;  // iterate in a frame
    logic [10:0] correlation_counter, n_correlation_counter;
    logic sramRW, n_sramRW;
    logic [15:0] temp_data;
    logic [32:0] partial_product, n_partial_product;
    logic [31:0] resample_temp_data;
    logic [22:0] resample_address, n_resample_address;
    logic [15:0] predict_frame [WindowSize-1:0];
    logic [19:0] max_correlation_index;
    logic [32:0] max_correlation_value;
    logic channelLR;
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
            correlation_counter <= 0;
            data_state <= 0;
            SRAM_ADDR <= 0;
            sramRW <= 0;
            resample_address <= 0;
            partial_product <= 0;
        end else begin
            state <= n_state;
            pitch_done <= n_pitch_done;
            pitch_read <= n_pitch_read;
            pitch_write <= n_pitch_write;
            pitch_addr <= n_pitch_addr;
            pitch_writedata <= n_pitch_writedata;
            counter <= n_counter;
            data_counter <= n_data_counter;
            correlation_counter <= n_correlation_counter;
            data_state <= n_data_state;
            SRAM_ADDR <= n_SRAM_ADDR;
            sramRW <= n_sramRW;
            resample_address <= n_resample_address;
            partial_product <= n_partial_product;
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
        correlation_counter = n_correlation_counter;
        data_state = n_data_state;
        n_SRAM_DQ = SRAM_DQ;
        n_SRAM_ADDR = SRAM_ADDR;
        setSRAMenable(SRAM_NOT_SELECT);
        n_sramRW = sramRW;
        n_partial_product = partial_product;
        case (state)
            IDLE: begin
                if (pitch_start) begin
                    n_state = READ_SDRAM;
                    n_pitch_addr = pitch_select [0];
                    n_SRAM_ADDR = 0;
                    H_a = H_s * speed;
                    n_counter =  0;
                    channelLR = 0;
                end
            end
            READ_SDRAM: begin
                n_pitch_read = 1;
                setSRAMenable(SRAM_WRITE);
                case (data_state)
                    READ_HEADER: begin
                        if (pitch_sdram_finished == 1) begin
                            n_pitch_addr = pitch_addr + 1;
                            data_length = pitch_readdata[31:9];
                            n_data_state = READ_DATA;
                        end
                    end
                    READ_DATA: begin
                        if (pitch_sdram_finished == 1) begin
                            n_pitch_addr = pitch_addr + 1;
                            n_SRAM_ADDR = SRAM_ADDR + 1;
                            n_SRAM_DQ = channelLR ? pitch_readdata[15:0] : pitch_readdata[31:16];
                            if (counter == 0) begin
                                if (pitch_addr == WindowSize + H_s) begin
                                    n_state = APPLY_WINDOW;
                                    n_pitch_read = 0;
                                    n_SRAM_ADDR = 0;
                                    n_sramRW = 0;
                                    n_data_counter = 0;
                                    max_correlation_index = 0;
                                end
                            end
                            else begin
                                if (pitch_addr == AnalysisFrameSize-1) begin
                                    n_state = CROSS_CORRELATION;
                                    n_pitch_read = 0;
                                    n_SRAM_ADDR = SRAM_ADDR - AnalysisFrameSize + 1;
                                    n_sramRW = 0;
                                    n_data_counter = 0;
                                    max_correlation_index = 0;
                                    max_correlation_value = 0;
                                end
                            end
                        end
                    end
                endcase
            end 
            WRITE_SDRAM: begin
                setSRAMenable(SRAM_READ);
                n_pitch_write = 1;
                if (!channelLR) begin
                    n_pitch_writedata[31:16] = SRAM_DQ;
                end
                else begin
                    n_pitch_writedata[15:0] = SRAM_DQ;
                end
                if (pitch_sdram_finished == 1) begin
                    n_pitch_addr = pitch_addr + 1;
                    n_SRAM_ADDR = SRAM_ADDR + 1;
                    n_data_counter = data_counter + 1;                    
                end
                if (data_counter == WindowSize >> 1) begin
                    if (!channelLR) begin
                        n_state = READ_DATA;
                        channelLR = 1;
                    end
                    else begin
                        if (!pitch_mode) begin
                            n_state = IDLE;
                        end
                        else begin
                            n_state = RESAMPLE;
                        end
                    end
                    n_pitch_write = 0;
                end
            end
            APPLY_WINDOW: begin
                if (!sramRW) begin
                    setSRAMenable(SRAM_READ);
                    temp_data = SRAM_DQ;
                    n_sramRW = 1;
                end
                else begin
                    setSRAMenable(SRAM_WRITE);
                    n_SRAM_DQ = temp_data * HANN_C[data_counter];
                    n_SRAM_ADDR = SRAM_ADDR + 1;
                    n_data_counter = data_counter + 1;
                    n_sramRW = 0;
                    if (data_counter == WindowSize) begin
                        sramRW = 0;
                        n_SRAM_ADDR = SRAM_ADDR - WindowSize >> 1 + 1;
                        n_data_counter = 0;
                        n_state = OLA_COMPUTE;
                    end
                end
            end
            CROSS_CORRELATION: begin
                setSRAMenable(SRAM_READ);
                temp_data = SRAM_DQ;
                n_partial_product = partial_product + (SRAM_DQ * predict_frame[data_counter]) >>> 10;
                n_data_counter = data_counter + 1;
                n_SRAM_ADDR = SRAM_ADDR + 1;
                if (data_counter == WindowSize - 1) begin
                    n_SRAM_ADDR = SRAM_ADDR + 2 - WindowSize;
                    n_correlation_counter = correlation_counter + 1;
                    n_partial_product = 0;
                    if (partial_product > max_correlation_value) begin
                        max_correlation_value = partial_product;
                        max_correlation_index = data_counter;
                    end
                    if(correlation_counter == WindowSize) begin
                        n_state = PREDICT_NEXT_FRAME;
                        n_SRAM_ADDR = SRAM_ADDR - WindowSize - tolerance << 2 + max_correlation_index + 1;
                    end
                end
            end
            PREDICT_NEXT_FRAME: begin
                setSRAMenable(SRAM_READ);
                predict_frame[data_counter] = SRAM_DQ * HANN_C[data_counter];
                n_data_counter = data_counter + 1;
                n_SRAM_ADDR = SRAM_ADDR + 1;
                if (data_counter == WindowSize-1) begin
                    n_state = APPLY_WINDOW;
                    n_data_counter = 0;
                    n_SRAM_ADDR = SRAM_ADDR - WindowSize + 1 - H_s;
                end
            end
            OLA_COMPUTE: begin
                if (counter == 0) begin
                    n_state = WRITE_SDRAM;
                    n_pitch_addr = pitch_select[1] + 1;
                end
                else begin
                    if (!sramRW) begin
                        setSRAMenable(SRAM_READ);
                        temp_data = SRAM_DQ;
                        n_sramRW = 1;
                    end
                    else begin
                        setSRAMenable(SRAM_WRITE);
                        n_SRAM_DQ = temp_data * HANN_C[data_counter];
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                        n_data_counter = data_counter + 1;
                        n_sramRW = 0;
                        if (data_counter == WindowSize-1) begin
                            sramRW = 0;
                            n_data_counter = 0;
                            n_state = OLA_COMPUTE;
                        end
                    end
                end
            end
            RESAMPLE: begin
                case (data_state) 
                    RESAMPLE_READ: begin
                        n_pitch_read = 1;
                        if (pitch_sdram_finished) begin
                            resample_temp_data = pitch_readdata;
                            n_data_state = RESAMPLE_WRITE;
                            n_pitch_read = 0;
                            n_resample_address = resample_address + speed;
                        end
                    end
                    RESAMPLE_WRITE: begin
                        n_pitch_write = 1;
                        n_pitch_writedata = resample_temp_data;
                        if (pitch_sdram_finished) begin
                            n_data_state = RESAMPLE_READ;
                            n_pitch_write = 0;
                            n_pitch_addr = pitch_addr + resample_address[22:3];
                        end
                    end
                endcase
            end
        endcase
    end
endmodule
