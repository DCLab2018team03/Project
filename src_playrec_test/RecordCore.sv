
// Recording audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.
// If 1 is not specified, then it records audio from the microphone

// pause is to change target address
// stop is to stop recording

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)

module RecordCore (
    input i_clk,
    input i_rst,
    // To controller
    input  logic record_start,
    input  logic [22:0] record_select [1:0],
    input  logic record_pause,
    input  logic record_stop,
    output logic record_done,

    // To SDRAM
    output logic record_read,
    output logic [22:0] record_addr,
    input  logic [31:0] record_readdata,
    output logic record_write,
    output logic [31:0] record_writedata,
    input  logic record_sdram_finished,

    // To audio
    output logic record_audio_ready,
    input  logic [31:0] record_audio_data,
    input  logic record_audio_valid
);
    logic [1:0] state, n_state;
    localparam IDLE  = 2'b00;
    localparam REC   = 2'b01;
    localparam WRITE = 2'b10;

    logic [31:0] audio_data, n_audio_data;
    assign record_writedata = audio_data;

    always_ff @(posedge i_clk or posedge i_rst) begin
        if ( i_rst ) begin
            state <= IDLE;
            audio_data <= 0;
        end else begin
            state <= n_state;
            audio_data <= n_audio_data;
        end
    end
    assign record_done = 0;
    assign record_read = 0;
    assign record_addr = 0;

    always_comb begin
        
        n_state = state;
        n_audio_data = audio_data;

        record_audio_ready = 0;
        record_write = 0;

        case(state)
            IDLE: begin
                if (record_start) begin
                    n_state = REC;
                end
            end
            REC: begin
                if (!record_start) begin
                    n_state = IDLE;
                end
                record_audio_ready = 1;
                n_audio_data = record_audio_data;
                if (record_audio_valid) begin
                    n_state = WRITE;
                end
            end
            WRITE: begin
                if (!record_start) begin
                    n_state = IDLE;
                end
                record_write = 1;
                if (record_sdram_finished) begin
                    n_state = REC;
                end
            end
            default: n_state = state;
        endcase

    end
endmodule