module ControlCore (
    input i_clk,
	input i_rst,
    // inputevent
    input logic [3:0] KEY,
    input logic [17:0] SW, 

    output logic [3:0] control_mode,

    input  logic loaddata_done,
    output logic mix_start,
    output logic [22:0] mix_select [4:0],
    output logic [2:0] mix_num, // how many data to mix
    input  logic mix_done,
    output logic pitch_start,
    output logic [22:0] pitch_select [1:0],
    output logic pitch_mode,
    output logic [3:0] pitch_speed,
    input  logic pitch_done,
    output logic record_start,
    output logic [22:0] record_select [1:0],
    output logic record_pause,
    output logic record_stop,
    input  logic record_done,
    output logic play_start,
    output logic [22:0] play_select,
    output logic play_pause,
    output logic play_stop,
    input  logic play_done
);
    logic [3:0] state, n_state;
    assign control_mode = state;
    
    // see define for control state
    logic REC, PLAY, STOP;
    assign REC = KEY[0];
    assign PLAY = KEY[1];
    assign STOP = KEY[2];
    
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= control_IDLE;
        end else begin
            state <= n_state;
        end
    end
    //assign mix_start = 0;
    //assign mix_select[0] = 0;
    //assign mix_select[1] = 0;
    //assign mix_select[2] = 0;
    //assign mix_select[3] = 0;
    assign mix_select[4] = 0;
    assign pitch_start = 0;
    assign pitch_select[0] = 0;
    assign pitch_select[1] = 0;
    assign pitch_mode = 0;
    assign pitch_speed = 0;
    assign record_select[0] = 0;
    assign record_select[1] = 0;
    assign record_pause = 0;
    //assign record_stop = 0;
    assign play_select = 0;
    assign play_pause = 0;
    assign play_stop = 0;

    always_comb begin
        
        n_state = state;
        record_start = 0;
        play_start = 0;
        record_stop = 0;

        case(state)
            control_IDLE: begin
                if (REC) begin
                    n_state = control_REC;
                end
                if (PLAY) begin
                    n_state = control_PLAY;
                end
                if (SW[0]) begin
                    n_state = control_MIX;
                end
            end
            control_REC: begin
                record_start = 1;
                if (STOP) begin
                    record_stop = 1;
                end
                if (record_done) begin
                    n_state = control_IDLE;
                end
            end
            control_PLAY: begin
                play_start = 1;
                if (play_done) begin
                    n_state = control_IDLE;
                end
            end
            control_MIX: begin
                n_state = state;
            end
            default: n_state =state;
        endcase

    end

endmodule 