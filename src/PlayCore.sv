
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
    input  logic [1:0] play_num, // 01 for play only, 10 for store only, 11 for both

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

    output [1:0] debug
);
    assign debug = state;

    logic [1:0] state, n_state;
    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam PLAY = 2'b10;
    localparam READ_LENGTH = 2'b11;

    logic [31:0] audio_data, n_audio_data;
    logic [22:0] addr, n_addr, audio_length, n_audio_length;
    assign play_audio_data = audio_data;
    assign play_addr = addr;

    logic counter, n_counter;

    // TODO
    // 1. read datalength
    // 2. read data at play_select

    always_ff @(posedge i_clk or posedge i_rst) begin
        if ( i_rst ) begin
            state <= IDLE;
            audio_data <= 0;
            addr <= 0;
            counter <= 0;
            audio_length <= 0;
        end else begin
            state <= n_state;
            audio_data <= n_audio_data;
            addr <= n_addr;
            counter <= n_counter;
            audio_length <= n_audio_length;
        end
    end


    always_comb begin

        n_state = state;
        n_audio_data = audio_data;
        n_addr = addr; 

        play_read = 0;
        play_audio_valid = 0;

        n_counter = counter;
        n_audio_length = audio_length;
        play_done = 0;

        case(state)
            IDLE: begin
                if (play_start) begin
                    n_state = READ_LENGTH;
                end
                n_addr = play_select;
            end
            READ_LENGTH: begin
                play_read = 1;
                n_audio_length = play_select + play_readdata[22:0] + 1;
                if (play_sdram_finished) begin
                    n_state = READ;
                    n_counter = 0;
                    n_addr = addr + 1;
                end
            end
            READ: begin
                play_read = 1;
                n_audio_data = play_readdata;
                if (play_sdram_finished) begin
                    n_state = PLAY;
                    n_counter = 0;
                    n_addr = addr + 1;
                end
                if (addr >= audio_length) begin
                    n_state = IDLE;
                    play_done = 1;
                end
            end
            PLAY: begin
                play_audio_valid = 1;
                if (play_audio_ready) begin
                    if ( counter == 1 ) begin
                        n_state = READ;
                    end else begin
                        n_counter = 1;
                    end
                end
            end
        endcase
        if (play_stop) begin
            n_state = IDLE;
            play_done = 1;
        end
    end
endmodule