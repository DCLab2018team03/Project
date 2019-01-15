module ControlCore (
    input i_clk,
	input i_rst,
    // inputevent
    input logic [3:0] KEY,
    input logic [17:0] SW, 
    input logic [11:0] gpio,

    output logic [3:0] control_mode,

    input  logic loaddata_done,
    output logic mix_start,
    output logic [22:0] mix_select [4:0],
    output logic [4:0] mix_num,
    output logic mix_stop,
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
    output logic [22:0] play_select [1:0],
    output logic play_pause,
    output logic play_stop,
    input  logic play_done,
    output logic play_record,
    output logic play_speed,
    output [3:0] debug
);
    assign debug = state;
    logic [3:0] state, n_state;
    assign control_mode = state;
    
    // see define for control state
    // Modify to GPIO
    logic REC, PLAY, STOP, MIX, PITCH;
    assign REC = gpio[11];
    assign PLAY = gpio[10];
    assign MIX = gpio[9];
    assign STOP = gpio[8];
    
    //assign PITCH = KEY[3];
    
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
    //assign mix_select[4] = 0;
    //assign pitch_start = 0;
    //assign pitch_select[0] = 0;
    //assign pitch_select[1] = 0;
    //assign pitch_mode = 0;
    //assign pitch_speed = 0;
    //assign record_select[0] = 0;
    assign record_select[1] = 0;
    assign record_pause = 0;
    //assign record_stop = 0;
    //assign play_select = 0;
    assign play_pause = 0;
    //assign play_stop = 0;

    int i;

    always_comb begin
        
        n_state = state;
        record_start = 0;
        play_start = 0;
		mix_start = 0;
        pitch_start = 0;
        record_stop = 0;
        play_stop = 0;
		mix_stop = 0;

        record_select[0] = 0;
		play_select = 0;
        for (i = 0; i < 5; i = i+1) begin
            mix_select[i] = 0;
        end
        pitch_select[0] = 0;
        pitch_select[1] = 0;
        pitch_mode = 0;
        pitch_speed = 0;
        mix_num = 4'd0;
        play_record = 0;
        play_speed = 0;
        case(state)
            control_IDLE: begin
                if (REC) begin
                    n_state = control_REC;
                end
                if (PLAY) begin
                    n_state = control_PLAY;
                end
                if (MIX) begin
                    n_state = control_MIX;
                end
                if (PITCH) begin
                    n_state = control_PITCH;
                end
            end
            control_REC: begin
                record_start = 1;
                case(SW[4:0])
                    5'b00001: begin
                        record_select[0] = CHUNK[0];
                        play_record = 1;
                    end
                    5'b00010: begin
                        record_select[0] = CHUNK[1];
                        play_record = 1;
                    end
                    5'b00100: begin
                        record_select[0] = CHUNK[2];
                        play_record = 1;
                    end
                    5'b01000: begin
                        record_select[0] = CHUNK[3];
                        play_record = 1;
                    end
                    5'b10000: begin
                        record_select[0] = CHUNK[4];
                        play_record = 1;
                    end
                    default:  record_select[0] = 0;
                endcase
                if (STOP) begin
                    record_stop = 1;
                end
                if (record_done) begin
                    n_state = control_IDLE;
                end
            end
            control_PLAY: begin
                play_start = 1;
                case(gpio[3:0])
                    4'b0001: begin 
                        mix_select[0] = CHUNK[0];
                    end
                    4'b0010: begin 
                        mix_select[0] = CHUNK[1];
                    end
                    4'b0100: begin 
                        mix_select[0] = CHUNK[2];
                    end
                    4'b1000: begin 
                        mix_select[0] = CHUNK[4];
                    end
                endcase                
                case(SW[4:0])
                    5'b00001: play_select[1] = CHUNK[0];
                    5'b00010: play_select[1] = CHUNK[1];
                    5'b00100: play_select[1] = CHUNK[2];
                    5'b01000: play_select[1] = CHUNK[3];
                    5'b10000: play_select[1] = CHUNK[4];
                    default:  play_select[1] = 0;
                endcase
                play_speed = SW[11:10];
                if (STOP) begin
                    play_stop = 1;
                end
                if (play_done) begin
                    n_state = control_IDLE;
                end
            end
            control_MIX: begin
                mix_start = 1;
                // Modify to GPIO
                case(gpio[3:0])
                    4'b0001: begin 
                        mix_select[0] = CHUNK[0];
                        mix_num[0] = 1;
                    end
                    4'b0010: begin 
                        mix_select[1] = CHUNK[1];
                        mix_num[1] = 1;
                    end
                    4'b0100: begin 
                        mix_select[2] = CHUNK[2];
                        mix_num[2] = 1;
                    end
                    4'b1000: begin 
                        mix_select[3] = CHUNK[4];
                        mix_num[3] = 1;
                    end
                endcase
                case(SW[4:0])
                    5'b00001: mix_select[1] = CHUNK[0];
                    5'b00010: mix_select[1] = CHUNK[1];
                    5'b00100: mix_select[1] = CHUNK[2];
                    5'b01000: mix_select[1] = CHUNK[3];
                    5'b10000: mix_select[1] = CHUNK[4];
                    default:  mix_select[1] = 0;
                endcase
                if (STOP) begin
                    mix_stop = 1;
                end
                if (mix_done) begin
                    n_state = control_IDLE;
                end
            end
            control_PITCH: begin
                pitch_start = 1;
                pitch_speed = 4'b1011;
                pitch_mode = 0;
                pitch_select[0] = CHUNK[0];
                pitch_select[1] = CHUNK[1];
                if (pitch_done) begin
                    n_state = control_IDLE;
                end
            end
            default: n_state =state;
        endcase

    end

endmodule 