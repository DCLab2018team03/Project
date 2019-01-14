// Pitching audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// mode is either time-stretch (0) or pitch-shift (1)
// speed is the required ratio of each of them

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdata is correct)

module PitchCore (
    input i_clk,
    input i_rst,
    // To controller
    input  logic pitch_start,
    input  logic [22:0] pitch_select [1:0],
    input  logic pitch_mode,
    input  logic [3:0] pitch_speed,
    output logic pitch_done,

    // To SDRAM
    output logic pitch_read,
    output logic [22:0] pitch_addr,
    input  logic [31:0] pitch_readdata,
    output logic pitch_write,
    output logic [31:0] pitch_writedata,
    input  logic pitch_sdram_finished,
    // To SRAM
    inout  logic [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
    output logic [19:0] SRAM_ADDR,   // SRAM Address bus 20 Bits
    output logic        SRAM_WE_N,   // SRAM Write Enable
    output logic        SRAM_CE_N,   // SRAM Chip Enable
    output logic        SRAM_OE_N,   // SRAM Output Enable
    output logic        SRAM_LB_N,   // SRAM Low-byte Data Mask 
    output logic        SRAM_UB_N    // SRAM High-byte Data Mask
);  
  /*  localparam SRAM_NOT_SELECT = 5'b01000;
    localparam SRAM_READ       = 5'b10000;
    localparam SRAM_WRITE      = 5'b00000;
    logic [15:0] n_SRAM_DQ;
    logic [19:0] n_SRAM_ADDR;
    assign SRAM_DQ = SRAM_WE_N ? 16'hzzzz : n_SRAM_DQ;

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

    logic [2:0] state, n_state;
    logic       data_state, n_data_state;

    logic n_pitch_done;
    logic n_pitch_read, n_pitch_write;
    logic [22:0] n_pitch_addr;
    logic [31:0] n_pitch_writedata;

    logic [15:0] temp_H_a;
    logic [12:0] H_a; // = H_s * speed, use H_a[12:3] to discard floating point
    logic [22:0] data_length;
    logic [22:0] frame_counter, n_frame_counter; // iterate frames (0~)
    logic [11:0] data_counter, n_data_counter;  // iterate in a frame (0~2559)
    logic [10:0] correlation_counter, n_correlation_counter; // iterate correlation (0~1024)
    logic [22:0] data_length_counter, n_data_length_counter; // iterate data_length (0~datalength)
    logic sramRW, n_sramRW;
    logic [15:0] temp_data;
    logic [35:0] temp_hann_data;
    logic [32:0] partial_product, n_partial_product;
    logic [31:0] resample_temp_data;
    logic [25:0] resample_address, n_resample_address;
    logic [15:0] predict_frame [WindowSize-1:0];
    logic [31:0] overlap_data [HalfWindowSize-1:0];
    logic [19:0] max_correlation_index;
    logic [32:0] max_correlation_value;
    logic [9:0] frame_size_not_enough;
    logic channelLR, n_channelLR;
    integer i;
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
            pitch_done <= 0;
            pitch_read <= 0;
            pitch_write <= 0;
            pitch_addr <= 23'd0;
            pitch_writedata <= 32'd0;
            frame_counter <= 0;
            data_counter <= 0;
            correlation_counter <= 0;
            data_length_counter <= 0;
            data_state <= 0;
            SRAM_ADDR <= 0;
            sramRW <= 0;
            resample_address <= 0;
            partial_product <= 0;
            channelLR <= 0;
        end else begin
            state <= n_state;
            pitch_done <= n_pitch_done;
            pitch_read <= n_pitch_read;
            pitch_write <= n_pitch_write;
            pitch_addr <= n_pitch_addr;
            pitch_writedata <= n_pitch_writedata;
            frame_counter <= n_frame_counter;
            data_counter <= n_data_counter;
            correlation_counter <= n_correlation_counter;
            data_length_counter <= n_data_length_counter;
            data_state <= n_data_state;
            SRAM_ADDR <= n_SRAM_ADDR;
            sramRW <= n_sramRW;
            resample_address <= n_resample_address;
            partial_product <= n_partial_product;
            channelLR <= n_channelLR;
        end 
    end

    always_comb begin
        n_state = state;
        n_pitch_done = pitch_done;
        n_pitch_read = pitch_read;
        n_pitch_write = pitch_write;
        n_pitch_addr = pitch_addr;
        n_pitch_writedata = pitch_writedata;
        n_frame_counter = frame_counter;
        n_data_counter = data_counter;
        n_correlation_counter = correlation_counter;
        n_data_length_counter = data_length_counter;
        n_data_state = data_state;
        n_SRAM_DQ = SRAM_DQ;
        n_SRAM_ADDR = SRAM_ADDR;
        setSRAMenable(SRAM_NOT_SELECT);
        n_sramRW = sramRW;
        n_partial_product = partial_product;
        n_channelLR = channelLR;
        case (state)
            IDLE: begin
                if (pitch_start) begin
                    n_state = READ_SDRAM;
                    n_data_state = READ_HEADER;
                    n_pitch_read = 1;
                    n_pitch_write = 0;
                    n_pitch_addr = pitch_select [0];
                    n_SRAM_ADDR = 0;
                    n_sramRW = 0;
                    temp_H_a = H_s * pitch_speed; 
                    H_a = temp_H_a >> 3;
                    n_frame_counter = 0;
                    n_data_length_counter = 0;
                    n_data_counter = 0;
                    n_channelLR = 0;
                    frame_size_not_enough = 0;
                end
            end
            READ_SDRAM: begin
                n_pitch_read = 1;
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
                            setSRAMenable(SRAM_WRITE);
                            if (!channelLR) begin
                                n_SRAM_ADDR = SRAM_ADDR + 1;
                                n_SRAM_DQ = pitch_readdata[31:16];
                                n_channelLR = 1;
                            end
                            else begin
                                n_pitch_addr = pitch_addr + 1;
                                n_SRAM_ADDR = SRAM_ADDR + 1;
                                n_SRAM_DQ = pitch_readdata[15:0];
                                n_channelLR = 0;
                                n_data_counter = data_counter + 1;
                            end
                            if (pitch_addr == pitch_select[0] + data_length && channelLR == 1) begin
                                n_state = CROSS_CORRELATION;
                                n_pitch_read = 0;
                                n_SRAM_ADDR = 0;
                                n_sramRW = 0;
                                n_data_counter = 0;
                                n_channelLR = 0;
                                max_correlation_index = 0;
                                max_correlation_value = 0;
                                frame_size_not_enough = data_length_counter;
                            end
                            else begin
                                if (frame_counter == 0) begin
                                    if (data_counter == (WindowSize + H_s - 1) && channelLR == 1) begin
                                        n_state = APPLY_WINDOW;
                                        n_pitch_read = 0;
                                        n_SRAM_ADDR = 0;
                                        n_sramRW = 0;
                                        n_data_counter = 0;
                                        n_channelLR = 0;
                                        max_correlation_index = 0;
                                        frame_size_not_enough = 0;
                                    end
                                end
                                else begin
                                    if (data_counter == AnalysisFrameSize-1 && channelLR == 1) begin
                                        n_state = CROSS_CORRELATION;
                                        n_pitch_read = 0;
                                        n_SRAM_ADDR = 0;
                                        n_sramRW = 0;
                                        n_data_counter = 0;
                                        n_channelLR = 0;
                                        max_correlation_index = 0;
                                        max_correlation_value = 0;
                                    end
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
                    if (pitch_sdram_finished == 1) begin
                        n_pitch_addr = pitch_addr;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                        n_data_counter = data_counter;
                        n_channelLR = 1;                    
                    end
                    if (frame_counter == 0) begin
                        n_pitch_writedata[31:16] = SRAM_DQ;
                    end
                    else begin
                        n_pitch_writedata[31:16] = SRAM_DQ + overlap_data[data_counter][31:16];
                    end
                end
                else begin
                    if (pitch_sdram_finished == 1) begin
                        n_pitch_addr = pitch_addr + 1;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                        n_data_counter = data_counter + 1; 
                        n_channelLR = 0;                   
                    end
                    if (frame_counter == 0) begin
                        n_pitch_writedata[15:0] = SRAM_DQ;
                    end
                    else begin
                        n_pitch_writedata[15:0] = SRAM_DQ + overlap_data[data_counter][15:0];
                    end
                end
                if (data_counter == HalfWindowSize - 1 && channelLR == 1) begin
                    if (frame_counter*H_a + WindowSize < data_length) begin
                        n_state = READ_DATA;
                        n_SRAM_ADDR = 0;
                        if (pitch_select[0] + frame_counter*H_a < tolerance) begin
                            n_pitch_addr = pitch_select[0] + 1;
                            frame_size_not_enough = AnalysisFrameSize - frame_counter*H_a;
                        end
                        else begin
                            n_pitch_addr = pitch_select[0] + 1 + frame_counter * H_a - tolerance;
                        end
                        n_frame_counter = frame_counter + 1;
                    end
                    else begin
                        if (!pitch_mode) begin
                            n_state = IDLE;
                            n_pitch_done = 1;
                        end
                        else begin
                            n_state = RESAMPLE;
                            n_pitch_addr = pitch_select[0] + 1;
                            if (pitch_speed >= 4'b1000) begin
                                n_resample_address = {pitch_select[1], 3'b000};
                            end
                            else begin
                                n_resample_address = {pitch_select[1]+data_length, 3'b000};
                            end
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
                    temp_hann_data = temp_data * HANN_C[data_counter];
                    n_SRAM_DQ = temp_hann_data[34:19];
                    n_SRAM_ADDR = SRAM_ADDR + 1;
                    n_sramRW = 0;
                    if (!channelLR) begin
                        n_channelLR = 1;
                    end
                    else begin
                        n_channelLR = 0;
                        n_data_counter = data_counter + 1;
                        if (data_counter == WindowSize - 1) begin
                            n_sramRW = 0;
                            n_SRAM_ADDR = SRAM_ADDR - WindowSize;
                            n_data_counter = 0;
                            n_state = OLA_COMPUTE;
                        end
                    end    
                end
            end
            CROSS_CORRELATION: begin
                setSRAMenable(SRAM_READ);
                temp_data = SRAM_DQ;
                n_partial_product = partial_product + (SRAM_DQ * predict_frame[data_counter]) >>> 4;
                n_data_counter = data_counter + 1;
                n_SRAM_ADDR = SRAM_ADDR + 2;
                if (data_counter == WindowSize - 1) begin
                    n_SRAM_ADDR = SRAM_ADDR + 2 - 2*WindowSize;
                    n_correlation_counter = correlation_counter + 1;
                    n_partial_product = 0;
                    if (partial_product > max_correlation_value) begin
                        max_correlation_value = partial_product;
                        max_correlation_index = data_counter;
                    end
                    if (frame_size_not_enough > 0) begin
                        if (correlation_counter == frame_size_not_enough - H_s) begin
                            n_data_counter = 0;
                            n_state = APPLY_WINDOW;
                            n_SRAM_ADDR = SRAM_ADDR - 2*WindowSize + max_correlation_index;
                        end
                    end
                    if(correlation_counter == WindowSize) begin
                        n_data_counter = 0;
                        n_state = PREDICT_NEXT_FRAME;
                        n_SRAM_ADDR = SRAM_ADDR - 2*WindowSize + max_correlation_index + H_s;
                    end
                end   
            end
            PREDICT_NEXT_FRAME: begin
                setSRAMenable(SRAM_READ);
                predict_frame[data_counter] = SRAM_DQ * HANN_C[data_counter];
                n_data_counter = data_counter + 1;
                n_SRAM_ADDR = SRAM_ADDR + 2;
                if (data_counter == WindowSize-1) begin
                    if (!channelLR) begin
                        n_state = CROSS_CORRELATION;
                        n_data_counter = 0;
                        n_channelLR = 1;
                        n_SRAM_ADDR = SRAM_ADDR - 2*WindowSize + 2 - H_s;
                    end
                    else begin
                        n_state = APPLY_WINDOW;
                        n_data_counter = 0;
                        n_channelLR = 0;
                        n_SRAM_ADDR = SRAM_ADDR - 2*WindowSize - H_s;
                    end
                end
            end
            OLA_COMPUTE: begin
                if (frame_counter == 0) begin
                    setSRAMenable(SRAM_READ);
                    if (!channelLR) begin
                        overlap_data[data_counter][31:16] = SRAM_DQ;
                        n_channelLR = 1;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                    end
                    else begin
                        overlap_data[data_counter][15:0] = SRAM_DQ;
                        n_channelLR = 0;
                        n_data_counter = data_counter + 1;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                        if (data_counter == HalfWindowSize - 1) begin
                            n_state = WRITE_SDRAM;
                            n_pitch_addr = pitch_select[1] + 1;
                            n_SRAM_ADDR = SRAM_ADDR - WindowSize - WindowSize;
                            n_data_counter = 0;
                        end
                    end
                end
                else begin
                    setSRAMenable(SRAM_READ);
                    if (!channelLR) begin
                        overlap_data[data_counter][31:16] = SRAM_DQ;
                        n_channelLR = 1;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                    end
                    else begin
                        overlap_data[data_counter][15:0] = SRAM_DQ;
                        n_channelLR = 0;
                        n_data_counter = data_counter + 1;
                        n_SRAM_ADDR = SRAM_ADDR + 1;
                        if (data_counter == WindowSize-1) begin
                            n_data_counter = 0;
                            n_state = WRITE_SDRAM;
                            n_pitch_addr = pitch_select[1] + 1 + HalfWindowSize*frame_counter;
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
                            if (pitch_speed >= 4'b1000) begin
                                n_resample_address = resample_address + pitch_speed;
                            end
                            else begin
                                n_resample_address = resample_address - pitch_speed;
                            end
                        end
                    end
                    RESAMPLE_WRITE: begin
                        n_pitch_write = 1;
                        n_pitch_writedata = resample_temp_data;
                        if (pitch_sdram_finished) begin
                            n_data_state = RESAMPLE_READ;
                            n_pitch_write = 0;
                            n_pitch_addr = resample_address[25:3];
                            n_data_length_counter = data_length_counter + 1;
                            if (data_length_counter == data_length) begin
                                n_state = IDLE;
                                n_pitch_done = 1;
                            end
                        end
                    end
                endcase
            end
        endcase
    end*/
endmodule
