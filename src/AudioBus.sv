
// record and play controller

module AudioBus (
    input i_clk,
    input i_rst,
    // avalon_audio_slave
    // avalon_left_channel_source
    output logic from_adc_left_channel_ready,
    input  logic [15:0] from_adc_left_channel_data,
    input  logic from_adc_left_channel_valid,
    // avalon_right_channel_source
    output logic from_adc_right_channel_ready,
    input  logic [15:0] from_adc_right_channel_data,
    input  logic from_adc_right_channel_valid,
    // avalon_left_channel_sink
    output logic [15:0] to_dac_left_channel_data,
    output logic to_dac_left_channel_valid,
    input  logic to_dac_left_channel_ready,
    // avalon_right_channel_sink
    output logic [15:0] to_dac_right_channel_data,
    output logic to_dac_right_channel_valid,
    input  logic to_dac_right_channel_ready,

    input  logic record_audio_ready,
    output logic [31:0] record_audio_data,
    output logic record_audio_valid,

    input  logic play_audio_valid,
    input  logic [31:0] play_audio_data,
    output logic play_audio_ready,
    output [1:0] debug
);
    logic to_left_valid, to_right_valid, n_to_left_valid, n_to_right_valid;
    assign to_dac_left_channel_valid = to_left_valid;
    assign to_dac_right_channel_valid = to_right_valid;
    assign to_dac_left_channel_data = play_audio_data[31:16];
    assign to_dac_right_channel_data = play_audio_data[15:0];


    logic from_left_ready, from_right_ready, n_from_left_ready, n_from_right_ready;
    logic [31:0] audio_data, n_audio_data;
    assign from_adc_left_channel_ready = from_left_ready;
    assign from_adc_right_channel_ready = from_right_ready;
    assign record_audio_data = audio_data;

    assign debug = state;

    logic [1:0] state, n_state;
    localparam IDLE = 2'b00;
    localparam PLAY = 2'b01;
    localparam REC  = 2'b10;

    

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
            to_left_valid <= 0;
            to_right_valid <= 0;
            from_left_ready <= 0;
            from_right_ready <= 0;
            audio_data <= 0;
        end else begin
            state <= n_state;
            to_left_valid <= n_to_left_valid;
            to_right_valid <= n_to_right_valid;
            from_left_ready <= n_from_left_ready;
            from_right_ready <= n_from_right_ready;
            audio_data <= n_audio_data;
        end
    end

    always_comb begin
        
        n_state = state;
        n_to_left_valid = to_left_valid;
        n_to_right_valid = to_right_valid;
        n_from_left_ready = from_left_ready;
        n_from_right_ready = from_right_ready;
        n_audio_data = audio_data;

        play_audio_ready = 0;
        record_audio_valid = 0;

        case(state)
            IDLE: begin
                if (play_audio_valid) begin
                    n_to_left_valid = 1;
                    n_to_right_valid = 1;
                    n_state = PLAY;
                end
                if (record_audio_ready) begin
                    n_from_left_ready = 1;
                    n_from_right_ready = 1;
                    n_state = REC;
                end
            end
            PLAY: begin
                if (to_dac_left_channel_ready) begin
                    n_to_left_valid = 0;
                end
                if (to_dac_right_channel_ready) begin
                    n_to_right_valid = 0;
                end
                if (!to_left_valid && !to_right_valid) begin
                    play_audio_ready = 1;
                    n_state = IDLE;
                end
                if (!play_audio_valid) begin
                    n_state = IDLE;
                    n_to_left_valid = 0;
				    n_to_right_valid = 0;
                end
            end
            REC: begin
                if (from_adc_left_channel_valid) begin
                    n_audio_data[31:16] = from_adc_left_channel_data;
                    n_from_left_ready = 0;
                end
                if (from_adc_right_channel_valid) begin
                    n_audio_data[15:0] = from_adc_right_channel_data;
                    n_from_right_ready = 0;
                end
                if (!from_left_ready && !from_right_ready) begin
                    record_audio_valid = 1;
                    n_state = IDLE;
                end
                if (!record_audio_ready) begin
                    n_state = IDLE;
                    n_from_left_ready = 0;
				    n_from_right_ready = 0;
                end
            end
            default: n_state = state;
        endcase
    end

    
endmodule