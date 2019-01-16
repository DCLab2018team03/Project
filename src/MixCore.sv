
// Mixing audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)


module MixCore (
    input logic i_clk,
    input logic i_rst,
    // To controller
    input  logic mix_start,
    input  logic [22:0] mix_select [4:0],
    input  logic [4:0] mix_num,
    input  logic mix_stop,
    output logic mix_done,

    // To SDRAM
    output logic mix_read,
    output logic [22:0] mix_addr,
    input  logic [31:0] mix_readdata,
    output logic mix_write,
    output logic [31:0] mix_writedata,
    input  logic mix_sdram_finished,

    // To Audio
    output logic mix_audio_valid,
    output logic signed [31:0] mix_audio_data,
    input  logic mix_audio_ready,

    output [2:0] debug
);

    //assign debug = state;

    localparam MIX_BIT = 4;
    localparam LG_MIX_BIT = 2;

    logic [2:0] state, n_state;
    logic signed [31:0] mix_data [MIX_BIT - 1:0], n_mix_data[MIX_BIT - 1:0];
    logic [22:0] length [MIX_BIT - 1:0], n_length [MIX_BIT - 1:0], addr [MIX_BIT - 1:0], n_addr [MIX_BIT - 1:0];
    logic [LG_MIX_BIT:0] mix_amount, n_mix_amount;
    logic [LG_MIX_BIT - 1:0] initialize, n_initialize, mix_counter, n_mix_counter;

    logic signed [31:0] n_mix_audio_data;
    logic counter, n_counter;

    parameter IDLE = 3'd0;
    parameter READ_LENGTH = 3'd1;
    parameter READ  = 3'd2;
    parameter DIVIDE = 3'd3;
    parameter ADD   = 3'd4;
    parameter PLAY  = 3'd5;
    parameter WRITE = 3'd6;
    parameter WRITE_LENGTH = 3'd7;

    logic [22:0] write_addr, n_write_addr;

    integer i, j ,k; 

    always_ff @(posedge i_clk or posedge i_rst) begin
        if ( i_rst ) begin
            state <= IDLE;
            for (i = 0; i < MIX_BIT; i = i+1) begin
                length[i] <= 0;
                addr[i] <= 0;
                mix_data[i] <= 0;
            end
            mix_amount <= 0;
            mix_counter <= 0;
            initialize <= 0;
            mix_audio_data <= 0;
            counter <= 0;

            write_addr <= 0;
        end else begin
            state <= n_state;
            for (j = 0; j < MIX_BIT; j = j+1) begin
                length[j] <= n_length[j]; // data total length
                addr[j] <= n_addr[j]; // data length (stop when eaual to length)
                mix_data[j] <= n_mix_data[j]; // data 
            end
            mix_amount <= n_mix_amount;  // how many data is mixing now
            mix_counter <= n_mix_counter; // which data is processing now
            initialize <= n_initialize; // which data to initialize (get length) 
            mix_audio_data <= n_mix_audio_data; // data to audio
            counter <= n_counter; // zero interpolation

            write_addr <= n_write_addr;
        end
    end

    always_comb begin
        // 4'th bit don't bother
        n_state = state;
        for (k = 0; k < MIX_BIT; k = k+1) begin
            n_length[k] = length[k];
            n_addr[k] = addr[k];
            n_mix_data[k] = mix_data[k];
        end
        n_mix_amount = mix_amount;
        n_mix_counter = mix_counter;
        n_initialize = initialize;
        n_counter = counter;

        n_mix_audio_data = mix_audio_data;
        mix_audio_valid = 0;

        mix_addr = 0;
        mix_read = 0;
        n_write_addr = write_addr;
        mix_write = 0;
        mix_writedata = 0;

        mix_done = 0;

        case(state)
            IDLE: begin
                n_length[0] = 0;
                n_length[1] = 0;
                n_length[2] = 0;
                n_length[3] = 0;
                n_addr[0] = 0;
                n_addr[1] = 0;
                n_addr[2] = 0;
                n_addr[3] = 0;
                n_mix_data[0] = 0;
                n_mix_data[1] = 0;
                n_mix_data[2] = 0;
                n_mix_data[3] = 0;
                n_write_addr = mix_select[4] + 1;
            end
            READ_LENGTH: begin
                mix_read = 1;
                mix_addr = addr[initialize];
                if (mix_sdram_finished) begin
                    n_length[initialize] = addr[initialize] + mix_readdata[22:0];
                    n_state = READ;
                    n_mix_counter = 0;
                    n_addr[initialize] = addr[initialize] + 1;

                    n_mix_amount = 0;
                end
            end
            READ: begin
                mix_addr = addr[mix_counter];
                if (length[mix_counter] != addr[mix_counter]) begin
                    mix_read = 1;
                    if (mix_sdram_finished) begin
                        n_mix_data[mix_counter] = $signed(mix_readdata);
                        n_state = READ;
                        n_addr[mix_counter] = addr[mix_counter] + 1;
                        n_mix_counter = mix_counter + 1;
                        n_mix_amount = mix_amount + 1;
                        if (mix_counter == 3) begin
                            n_state = DIVIDE;
                            n_mix_counter = 0;
                        end
                    end
                end
                else begin
                    n_mix_data[mix_counter] = 0;
                    n_mix_counter = mix_counter + 1;
                    if (mix_counter == 3) begin
                        n_state = DIVIDE;
                        n_mix_counter = 0;
                    end
                end
            end
            DIVIDE: begin
                case (mix_amount)
                    3'd2:    n_mix_data[counter] = {1'b0, mix_data[counter][14], mix_data[counter][14:1]};
                    3'd3:    n_mix_data[counter] = {1'b0, {2{mix_data[counter][14]}}, mix_data[counter][14:2]} + {1'b0, {4{mix_data[counter][14]}}, mix_data[counter][14:4]} + {1'b0, {6{mix_data[counter][14]}}, mix_data[counter][14:6]};
                    3'd4:    n_mix_data[counter] = {1'b0, {2{mix_data[counter][14]}}, mix_data[counter][14:2]};
                    default: n_mix_data[counter] = mix_data[counter];
                endcase
                //n_mix_data[mix_counter][31:16] = {1'b0, mix_data[mix_counter][30], mix_data[mix_counter][30:17]};
                //n_mix_data[mix_counter][15:0] = {1'b0, mix_data[mix_counter][14], mix_data[mix_counter][14:1]};
                n_mix_counter = mix_counter + 1;
                if (mix_counter == 3) begin
                    n_state = ADD;
                    n_mix_counter = 0;
                end
                if (mix_amount == 0) begin
                    n_state = IDLE;
                end
            end
            ADD: begin
                n_mix_audio_data[31:16] = $signed(mix_data[0][31:16]) + $signed(mix_data[1][31:16]) + $signed(mix_data[2][31:16]) + $signed(mix_data[3][31:16]);
                n_mix_audio_data[15:0] = $signed(mix_data[0][15:0]) + $signed(mix_data[1][15:0]) + $signed(mix_data[2][15:0]) + $signed(mix_data[3][15:0]);
                n_state = PLAY;
            end
            PLAY: begin
                mix_audio_valid = 1;
                if (mix_audio_ready) begin
                    if ( counter == 1 ) begin
                        n_state = WRITE;
                        n_counter = 0;
                        n_mix_amount = 0;
                    end else begin
                        n_counter = 1;
                    end
                end
            end
            WRITE: begin
                n_state = READ;
                if (mix_num[4]) begin
                    mix_addr = write_addr;
                    mix_write = 1;
                    mix_writedata = mix_audio_data;
                    if (mix_sdram_finished) begin
                        n_state = READ;
                        n_write_addr = write_addr + 1;
                    end
                end
            end
            WRITE_LENGTH: begin
               n_state = IDLE;
               mix_done = 1;
               if (mix_num[4]) begin
                    mix_addr = mix_select[4];
                    mix_write = 1;
                    mix_writedata = {9'd0, write_addr - mix_select[4] - 1};
                    if (mix_sdram_finished) begin
                        n_state = IDLE;
                        mix_done = 1;
                    end
               end
            end
        endcase
        case(mix_num[3:0])
            5'b0001: begin
                n_addr[0] = mix_select[0];
                n_state = READ_LENGTH;
                //n_mix_amount = mix_amount + 1;
                n_initialize = 0;
            end
            5'b0010: begin
                n_addr[1] = mix_select[1];
                n_state = READ_LENGTH;
                //n_mix_amount = mix_amount + 1;
                n_initialize = 1;
            end
            5'b0100: begin
                n_addr[2] = mix_select[2];                
                n_state = READ_LENGTH; 
                //n_mix_amount = mix_amount + 1;
                n_initialize = 2;
            end
            5'b1000: begin
                n_addr[3] = mix_select[3];                
                n_state = READ_LENGTH;  
                //n_mix_amount = mix_amount + 1;
                n_initialize = 3;
            end
        endcase
        if(mix_stop) begin
            n_state = WRITE_LENGTH;
        end
    end

task SHIFT;
    input [15:0] data; 
    input [2:0]  divisor;
    output [15:0] n_data;
        
    case (divisor)
        3'd2:    n_data = {1'b0, data[14], data[14:1]};
        3'd3:    n_data = {1'b0, {2{data[14]}}, data[14:2]} + {1'b0, {4{data[14]}}, data[14:4]} + {1'b0, {6{data[14]}}, data[14:6]};
        3'd4:    n_data = {1'b0, {2{data[14]}}, data[14:2]};
        default: n_data = data;
    endcase
endtask

endmodule