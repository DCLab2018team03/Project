
// Playing audio
// Activated by _start, and _done = 1 after finishing
// _select is the targeted address

// pause
// stop is to stop recording

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)

module PlayCore (
    input i_clk,
    input i_rst,
    // to controller
    input  logic play_start,
    input  logic [22:0] play_select [1:0],
    input  logic play_pause,
    input  logic play_stop,
    output logic play_done,
    input logic play_record,
    input logic [1:0] play_speed,

    // To SDRAM
    output logic play_read,
    output logic [22:0] play_addr,
    input  logic [31:0] play_readdata,
    input  logic play_sdram_finished,
    output logic play_write,
    output logic [31:0] play_writedata,

    // To audio
    output logic play_audio_valid,
    output logic [31:0] play_audio_data,
    input  logic play_audio_ready,

    output [2:0] debug
);
    assign debug = {1'b0, play_speed};

    logic [2:0] state, n_state;
    localparam IDLE = 3'd0;
    localparam READ = 3'd1;
    localparam PLAY = 3'd2;
    localparam READ_LENGTH = 3'd3;
    localparam WRITE = 3'd4;
    localparam WRITE_LENGTH = 3'd5;

    logic [31:0] audio_data, n_audio_data;
    logic [22:0] read_addr, n_read_addr, write_addr, n_write_addr, audio_length, n_audio_length;
    assign play_audio_data = audio_data;
    assign play_addr = (play_read == 1) ? read_addr : write_addr;
    assign play_writedata = (state == WRITE_LENGTH) ? data_length_counter : audio_data;

    logic [1:0] counter, n_counter;
    logic [22:0] data_length_counter, n_data_length_counter;

    // TODO
    // 1. read datalength
    // 2. read data at play_select

    always_ff @(posedge i_clk or posedge i_rst) begin
        if ( i_rst ) begin
            state <= IDLE;
            audio_data <= 0;
            read_addr <= 0;
            write_addr <= 0;
            counter <= 0;
            data_length_counter <= 0;
            audio_length <= 0;
        end else begin
            state <= n_state;
            audio_data <= n_audio_data;
            read_addr <= n_read_addr;
            write_addr <= n_write_addr;
            counter <= n_counter;
            data_length_counter <= n_data_length_counter;
            audio_length <= n_audio_length;
        end
    end


    always_comb begin
        n_state = state;
        n_audio_data = audio_data;
        n_read_addr = read_addr; 
        n_write_addr = write_addr; 

        play_read = 0;
        play_audio_valid = 0;
        play_write = 0;

        n_counter = counter;
        n_data_length_counter = data_length_counter;
        n_audio_length = audio_length;
        play_done = 0;

        case(state)
            IDLE: begin
                if (play_start) begin
                    n_state = READ_LENGTH;
                end
                n_read_addr = play_select[0];
                n_write_addr = play_select[1] + 1;
            end
            READ_LENGTH: begin
                play_read = 1;
                n_audio_length = read_addr + play_readdata[22:0] + 1;
                if (play_sdram_finished) begin
                    n_state = READ;
                    n_counter = 0;
                    n_read_addr = read_addr + 1;
                end
            end
            READ: begin
                play_read = 1;
                n_audio_data = play_readdata;
                if (play_sdram_finished) begin
                    n_state = PLAY;
                    n_counter = 0;
                    n_read_addr = read_addr + 1;
                end
                if (read_addr > audio_length) begin
                    if (play_record) begin
                        n_state = WRITE_LENGTH;
                        n_write_addr = play_select[1];
                    end
                    else begin
                        n_state = IDLE;
                    end
                end
            end
            PLAY: begin
                play_audio_valid = 1;
                if (play_audio_ready) begin
                    if ( (counter >= 1 && play_speed == 2'b00) || 
                         (counter >= 3 && play_speed == 2'b10) || 
                         (counter >= 0 && play_speed == 2'b01)) begin
                        /*if (play_record) begin
                            n_state = WRITE;
                        end
                        else begin
                            n_counter = 0;
                            n_state = READ;
                        end*/
                        n_state = WRITE;
                        n_counter = 0;
                    end else begin
                        n_counter = counter + 1;
                        /*if (play_record) begin
                            n_state = WRITE;
                        end*/
                    end
                end 
            end
            WRITE: begin
                n_state = READ;
                if (play_record) begin 
                    play_write = 1;
                    n_state = WRITE;
                    if (play_sdram_finished) begin
                        n_write_addr = write_addr + 1;
                        n_data_length_counter = data_length_counter + 1;
                        n_state = READ;
                    /*if ( (counter >= 1 && play_speed == 2'b00) || 
                         (counter >= 3 && play_speed == 2'b10) || 
                         (counter >= 0 && play_speed == 2'b01)) begin
                        n_counter = 0;
                        n_state = READ;
                    end
                    else begin
                        n_state = PLAY;
                    end*/
                    end
                end
            end
            WRITE_LENGTH: begin
                play_write = 1;
                if (play_sdram_finished) begin
                    n_state = IDLE;            
                    play_done = 1;
                end
            end            
        endcase
        if (play_stop) begin
            if (play_record) begin
                n_state = WRITE_LENGTH;
            end
            else begin
                n_state = IDLE;
                play_done = 1;
            end
        end
    end
endmodule