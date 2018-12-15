module ControlCore (
    input i_clk,
	input i_rst,
    // inputevent
    input logic [3:0] KEY,
    input logic [17:0] SW, 

    input  logic loaddata_done,
    output logic mix_start,
    output logic [22:0] mix_select [4:0],
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
    input  logic play_done,
);
    logic [3:0] state, n_state;
    parameter IDLE        = 4'd0;
    parameter LOAD        = 4'd1;
    parameter MIX         = 4'd2;
    parameter PITCH       = 4'd3;
    parameter PLAY        = 4'd4;
    parameter RECORD      = 4'd5;
    
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= IDLE;
        end else begin
            state <= n_state;
        end
    end

    always_comb begin
        
        record_start = 0;
        pitch_start = 0;
        mix_start = 0;
        play_start = 0;

        case(state)
            IDLE: begin
                if (KEY[0]) begin
                    n_state = RECORD;
                end
            end
            RECORD: begin
                record_start = 1;
                if (KEY[1]) begin
                    n_state = PLAY;
                end
            end
            PLAY: begin
                play_start = 1;
                if (KEY[0]) begin
                    n_state = REC;
                end
            end
            default:
        endcase

    end

endmodule 