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
    output logic [22:0] mix_select [8:0],
    output logic [8:0] mix_num,
    output logic [7:0] mix_loop,
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
    output logic [1:0] play_speed,
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
    
    /*
    assign REC = KEY[0];
    assign PLAY = KEY[1];
    assign MIX = KEY[2];
    assign STOP = KEY[3]; 
    */
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

    int i, j;

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
		play_select[0] = 0;
		play_select[1] = 0;
        for (i = 0; i < 9; i = i+1) begin
            mix_select[i] = 0;
        end
        for (j = 0; j < 8; j = j+1) begin
            mix_loop[j] = 0;
        end
        pitch_select[0] = 0;
        pitch_select[1] = 0;
        pitch_mode = 0;
        pitch_speed = 0;
        mix_num = 9'd0;
        play_record = 0;
        play_speed = 2'b00;
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
                case(SW[7:0])
                    8'b0000_0001: begin
                        record_select[0] = CHUNK[0];
                        record_start = 1;
                    end
                    8'b0000_0010: begin
                        record_select[0] = CHUNK[1];
                        record_start = 1;
                    end
                    8'b0000_0100: begin
                        record_select[0] = CHUNK[2];
                        record_start = 1;
                    end
                    8'b0000_1000: begin
                        record_select[0] = CHUNK[3];
                        record_start = 1;
                    end
                    8'b0001_0000: begin
                        record_select[0] = CHUNK[4];
                        record_start = 1;
                    end
                    8'b0010_0000: begin
                        record_select[0] = CHUNK[5];
                        record_start = 1;
                    end
                    8'b0100_0000: begin
                        record_select[0] = CHUNK[6];
                        record_start = 1;
                    end
                    8'b1000_0000: begin
                        record_select[0] = CHUNK[7];
                        record_start = 1;
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
                case({gpio[13],[6:0]})
                    8'b0000_0001: begin 
                        play_select[0] = CHUNK[0];
                        if(~SW[0]) play_start = 1;
                    end
                    8'b0000_0010: begin 
                        play_select[0] = CHUNK[1];
						if(~SW[1]) play_start = 1;
                    end
                    8'b0000_0100: begin 
                        play_select[0] = CHUNK[2];
						if(~SW[2]) play_start = 1;
                    end
                    8'b0000_1000: begin 
                        play_select[0] = CHUNK[3];
						if(~SW[3]) play_start = 1;
                    end
                    8'b0001_0000: begin
                        play_select[0] = CHUNK[4];
						if(~SW[4]) play_start = 1;
                    end
                    8'b0010_0000: begin
                        play_select[0] = CHUNK[5];
						if(~SW[5])play_start = 1;
                    end
                    8'b0100_0000: begin
                        play_select[0] = CHUNK[6];
						if(~SW[6]) play_start = 1;
                    end
                    8'b1000_0000: begin
                        play_select[0] = CHUNK[7];
						if(~SW[7]) play_start = 1;
                    end
                    default: begin
                        play_select[0] = 0;
                    end
                endcase                
                case(SW[7:0])
                    8'b0000_0001: begin
                        play_select[1] = CHUNK[0];
                        play_record = 1;
                    end
                    8'b0000_0010: begin
                        play_select[1] = CHUNK[1];
                        play_record = 1;
                    end
                    8'b0000_0100: begin
                        play_select[1] = CHUNK[2];
                        play_record = 1;
                    end
                    8'b0000_1000: begin
                        play_select[1] = CHUNK[3];
                        play_record = 1;
                    end
                    8'b0001_0000: begin
                        play_select[1] = CHUNK[4];
                        play_record = 1;
                    end
                    8'b0010_0000: begin
                        play_select[1] = CHUNK[5];
                        play_record = 1;
                    end
                    8'b0100_0000: begin
                        play_select[1] = CHUNK[6];
                        play_record = 1;
                    end
                    8'b1000_0000: begin
                        play_select[1] = CHUNK[7];
                        play_record = 1;
                    end
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
                case({gpio[13],gpio[6:0]})
                    8'b0000_0001: begin 
                        mix_select[0] = CHUNK[0];
                        if(~SW[0]) mix_num[0] = 1;
                    end
                    8'b0000_0010: begin 
                        mix_select[1] = CHUNK[1];
                        if(~SW[1]) mix_num[1] = 1;
                    end
                    8'b0000_0100: begin 
                        mix_select[2] = CHUNK[2];
                        if(~SW[2]) mix_num[2] = 1;
                    end
                    8'b0000_1000: begin 
                        mix_select[3] = CHUNK[3];
                        if(~SW[3]) mix_num[3] = 1;
                    end
                    8'b0001_0000: begin 
                        mix_select[4] = CHUNK[4];
                        if(~SW[4]) mix_num[4] = 1;
                    end
                    8'b0010_0000: begin 
                        mix_select[5] = CHUNK[5];
                        if(~SW[5]) mix_num[5] = 1;
                    end
                    8'b0100_0000: begin 
                        mix_select[6] = CHUNK[6];
                        if(~SW[6]) mix_num[6] = 1;
                    end
                    8'b1000_0000: begin 
                        mix_select[7] = CHUNK[7];
                        if(~SW[7]) mix_num[7] = 1;
                    end
                endcase
                mix_num[8] = 1;
                case(SW[7:0])
                    8'b0000_0001: mix_select[8] = CHUNK[0];
                    8'b0000_0010: mix_select[8] = CHUNK[1];
                    8'b0000_0100: mix_select[8] = CHUNK[2];
                    8'b0000_1000: mix_select[8] = CHUNK[3];
                    8'b0001_0000: mix_select[8] = CHUNK[4];
                    8'b0010_0000: mix_select[8] = CHUNK[5];
                    8'b0100_0000: mix_select[8] = CHUNK[6];
                    8'b1000_0000: mix_select[8] = CHUNK[7];
                    default:  begin
                        mix_select[8] = 0;
                        mix_num[8] = 0;
                    end
                endcase
                case(SW[15:8])
                    8'b0000_0001: mix_loop[0] = 1;
                    8'b0000_0010: mix_loop[1] = 1;
                    8'b0000_0100: mix_loop[2] = 1;
                    8'b0000_1000: mix_loop[3] = 1;
                    8'b0001_0000: mix_loop[4] = 1;
                    8'b0010_0000: mix_loop[5] = 1;
                    8'b0100_0000: mix_loop[6] = 1;
                    8'b1000_0000: mix_loop[7] = 1;
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