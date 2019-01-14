
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
    output logic [31:0] mix_audio_data,
    input  logic mix_audio_ready
);

    localparam MIX_BIT = 4;
    localparam LG_MIX_BIT = 2;

    logic [2:0] state, n_state;
    logic [31:0] mix_data [MIX_BIT - 1:0], n_mix_data[MIX_BIT - 1:0];
    logic [22:0] length [MIX_BIT - 1:0], n_length [MIX_BIT - 1:0], addr [MIX_BIT - 1:0], n_addr [MIX_BIT - 1:0];
    logic [LG_MIX_BIT - 1:0] mix_amount, n_mix_amount, mix_counter, n_mix_counter, new_amount, n_new_amount;
    logic [LG_MIX_BIT - 1:0] initialize, n_initialize;

    logic [31:0] n_mix_audio_data;
    logic counter, n_counter;

    parameter IDLE = 3'd0;
    parameter READ_LENGTH = 3'd1;
    parameter READ  = 3'd2;
    parameter DIVIDE = 3'd3;
    parameter ADD   = 3'd6;
    parameter PLAY  = 3'd4;
    parameter WRITE = 3'd5;

    integer i; 

    always_ff @(posedge i_clk or posedge i_rst) begin
        if ( i_rst ) begin
            state <= IDLE;
            for (i = 0; i < MIX_BIT; i = i+1) begin
                length[i] <= 0;
                addr[i] <= 0;
                mix_data[i] <= 0;
            end
            mix_amount <= 0;
            new_amount <= 0;
            mix_counter <= 0;
            initialize <= 0;
            mix_audio_data <= 0;
            counter <= 0;
        end else begin
            state <= n_state;
            for (i = 0; i < MIX_BIT; i = i+1) begin
                length[i] <= n_length[i]; // data total length
                addr[i] <= n_addr[i]; // data length (stop when eaual to length)
                mix_data[i] <= n_mix_data[i]; // data 
            end
            mix_amount <= n_mix_amount;  // how many data is mixing now
            new_amount <= n_new_amount;  // update new data amount
            mix_counter <= n_mix_counter; // which data is processing now
            initialize <= n_initialize; // which data to initialize (get length) 
            mix_audio_data <= n_mix_audio_data; // data to audio
            counter <= n_counter; // zero interpolation
        end
    end

    always_comb begin
        // 4'th bit don't bother
        n_state = state;
        for (i = 0; i < MIX_BIT; i = i+1) begin
            n_length[i] = length[i];
            n_addr[i] = addr[i];
            n_mix_data[i] = mix_data[i];
        end
        n_mix_amount = mix_amount;
        n_new_amount = new_amount;
        n_mix_counter = mix_counter;
        n_initialize = initialize;
        n_mix_audio_data = mix_audio_data;
        n_counter = counter;

        mix_read = 0;
        mix_done = 0;
        mix_audio_valid = 0;

        case(state)
            READ_LENGTH: begin
                mix_read = 1;
                n_length[initialize] = addr[initialize] + mix_readdata + 1;
                if (mix_sdram_finished) begin
                    n_state = READ;
                    n_mix_counter = 0;
                    n_addr[initialize] = addr[initialize] + 1;
                end
            end
            READ: begin
                n_mix_data = 0;
                if (length[mix_counter] != addr[mix_counter]) begin
                    mix_read = 1;
                    n_mix_data[mix_counter] = mix_readdata;
                    if (mix_sdram_finished) begin
                        n_state = READ;
                        n_addr[mix_counter] = addr[mix_counter] + 1;
                    end
                end
                n_mix_counter = mix_counter + 1;
                if (mix_counter == 3) begin
                    n_state = MIX;
                    n_mix_counter = 0;
                    n_new_amount = 4;
                end
            end
            DIVIDE: begin
                n_mix_data[mix_counter] = mix_data[mix_counter] / mix_amount;
                n_mix_counter = mix_counter + 1
                if (mix_counter == 3) begin
                    n_state = ADD;
                    n_mix_counter = 0;
                end
                if (addr[mix_counter] == length[mix_counter]) begin
                    n_new_amount = new_amount - 1;
                end
            end
            ADD: begin
                n_mix_audio_data = mix_data[0] + mix_data[1] + mix_data[2] + mix_data[3];
                n_state = PLAY;
                n_mix_amount = new_amount;
            end
            PLAY: begin
                mix_audio_valid = 1;
                if (mix_audio_ready) begin
                    if ( counter == 1 ) begin
                        n_state = READ;
                    end else begin
                        n_counter = 1;
                    end
                end
            end
            WRITE: begin
                n_state = state;
            end
            default: begin
                n_state = state;
            end
        endcase
        case(mix_num[3:0]) begin
            5'b0001: begin
                n_addr[0] = mix_select[0];
                n_state = READ_LENGTH;
                n_mix_amount = mix_amount + 1;
                n_initialize = 0;
            end
            5'b0010: begin
                n_addr[1] = mix_select[1];
                n_state = READ_LENGTH;
                n_mix_amount = mix_amount + 1;
                n_initialize = 1;
            end
            5'b0100: begin
                n_addr[2] = mix_select[2];                
                n_state = READ_LENGTH; 
                n_mix_amount = mix_amount + 1;
                n_initialize = 2;
            end
            5'b1000: begin
                n_addr[3] = mix_select[3];                
                n_state = READ_LENGTH;  
                n_mix_amount = mix_amount + 1;
                n_initialize = 3;
            end
        end
        if (mix_amount == 0) begin
            n_state = IDLE;
            mix_done = 1;
        end
    end
endmodule