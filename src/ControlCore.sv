module ControlCore (
    input i_clk,
	input i_rst,
    // inputevent
    input logic [3:0] KEY,
    input logic [17:0] SW, 
    input logic [13:0] gpio,

    output logic [3:0] control_mode,

    input  logic loaddata_done,
    output logic mix_start,
    output logic [22:0] mix_select [16:0],
    output logic [16:0] mix_num,
    output logic [15:0] mix_loop,
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
    logic page, n_page;
    logic [23:0] store_addr, n_store_addr;
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
            page <= 0;
            store_addr <= 0;
        end else begin
            state <= n_state;
            page <= n_page;
            store_addr <= n_store_addr;
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
        n_page = page;
        n_store_addr = store_addr;
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
        for (i = 0; i < 16; i = i+1) begin
            mix_select[i] = CHUNK[i];
        end
        mix_select[16] = 0;
        for (j = 0; j < 16; j = j+1) begin
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
                case (SW[15:0])
                    16'h0001: begin
                        n_store_addr[0] = {1'b1,CHUNK[0]};
                    end
                    16'h0002: begin
                        n_store_addr[1] = {1'b1,CHUNK[1]};
                    end
                    16'h0004: begin
                        n_store_addr[2] = {1'b1,CHUNK[2]};
                    end
                    16'h0008: begin
                        n_store_addr[3] = {1'b1,CHUNK[3]};
                    end
                    16'h0010: begin
                        n_store_addr[4] = {1'b1,CHUNK[4]};
                    end
                    16'h0020: begin
                        n_store_addr[5] = {1'b1,CHUNK[5]};
                    end
                    16'h0040: begin
                        n_store_addr[6] = {1'b1,CHUNK[6]};
                    end
                    16'h0080: begin
                        n_store_addr[7] = {1'b1,CHUNK[7]};
                    end
                    16'h0100: begin
                        n_store_addr[8] = {1'b1,CHUNK[8]};
                    end
                    16'h0200: begin
                        n_store_addr[9] = {1'b1,CHUNK[9]};
                    end
                    16'h0400: begin
                        n_store_addr[10] = {1'b1,CHUNK[10]};
                    end
                    16'h0800: begin
                        n_store_addr[11] = {1'b1,CHUNK[11]};
                    end
                    16'h1000: begin
                        n_store_addr[12] = {1'b1,CHUNK[12]};
                    end
                    16'h2000: begin
                        n_store_addr[13] = {1'b1,CHUNK[13]};
                    end
                    16'h4000: begin
                        n_store_addr[14] = {1'b1,CHUNK[14]};
                    end
                    16'h8000: begin
                        n_store_addr[15] = {1'b1,CHUNK[15]};
                    end
                    default:  n_store_addr[0] = 24'd0;
                endcase
            end
            control_REC: begin
                case(SW[15:0])
                    16'h0001: begin
                        record_select[0] = CHUNK[0];
                        record_start = 1;
                    end
                    16'h0002: begin
                        record_select[0] = CHUNK[1];
                        record_start = 1;
                    end
                    16'h0004: begin
                        record_select[0] = CHUNK[2];
                        record_start = 1;
                    end
                    16'h0008: begin
                        record_select[0] = CHUNK[3];
                        record_start = 1;
                    end
                    16'h0010: begin
                        record_select[0] = CHUNK[4];
                        record_start = 1;
                    end
                    16'h0020: begin
                        record_select[0] = CHUNK[5];
                        record_start = 1;
                    end
                    16'h0040: begin
                        record_select[0] = CHUNK[6];
                        record_start = 1;
                    end
                    16'h0080: begin
                        record_select[0] = CHUNK[7];
                        record_start = 1;
                    end
                    16'h0100: begin
                        record_select[0] = CHUNK[8];
                        record_start = 1;
                    end
                    16'h0200: begin
                        record_select[0] = CHUNK[9];
                        record_start = 1;
                    end
                    16'h0400: begin
                        record_select[0] = CHUNK[10];
                        record_start = 1;
                    end
                    16'h0800: begin
                        record_select[0] = CHUNK[11];
                        record_start = 1;
                    end
                    16'h1000: begin
                        record_select[0] = CHUNK[12];
                        record_start = 1;
                    end
                    16'h2000: begin
                        record_select[0] = CHUNK[13];
                        record_start = 1;
                    end
                    16'h4000: begin
                        record_select[0] = CHUNK[14];
                        record_start = 1;
                    end
                    16'h8000: begin
                        record_select[0] = CHUNK[15];
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
                case({gpio[13],gpio[6:0]})
                    8'b0000_0001: begin 
                        play_select[0] = page ? CHUNK[8] : CHUNK[0];
                        if( (~page && store_addr[22:0] != CHUNK[0]) || (page && store_addr[22:0] != CHUNK[8]) ) play_start = 1;
                    end
                    8'b0000_0010: begin 
                        play_select[0] = page ? CHUNK[9] : CHUNK[1];
                        if( (~page && store_addr[22:0] != CHUNK[1]) || (page && store_addr[22:0] != CHUNK[9]) ) play_start = 1;
                    end
                    8'b0000_0100: begin 
                        play_select[0] = page ? CHUNK[10] : CHUNK[2];
                        if( (~page && store_addr[22:0] != CHUNK[2]) || (page && store_addr[22:0] != CHUNK[10]) ) play_start = 1;
                    end
                    8'b0000_1000: begin 
                        play_select[0] = page ? CHUNK[11] : CHUNK[3];
                        if( (~page && store_addr[22:0] != CHUNK[3]) || (page && store_addr[22:0] != CHUNK[11]) ) play_start = 1;
                    end
                    8'b0001_0000: begin
                        play_select[0] = page ? CHUNK[12] : CHUNK[4];
                        if( (~page && store_addr[22:0] != CHUNK[4]) || (page && store_addr[22:0] != CHUNK[12]) ) play_start = 1;
                    end
                    8'b0010_0000: begin
                        play_select[0] = page ? CHUNK[13] : CHUNK[5];
                        if( (~page && store_addr[22:0] != CHUNK[5]) || (page && store_addr[22:0] != CHUNK[13]) ) play_start = 1;
                    end
                    8'b0100_0000: begin
                        play_select[0] = page ? CHUNK[14] : CHUNK[6];
                        if( (~page && store_addr[22:0] != CHUNK[6]) || (page && store_addr[22:0] != CHUNK[14]) ) play_start = 1;
                    end
                    8'b1000_0000: begin
                        play_select[0] = page ? CHUNK[15] : CHUNK[7];
                        if( (~page && store_addr[22:0] != CHUNK[7]) || (page && store_addr[22:0] != CHUNK[15]) ) play_start = 1;
                    end
                endcase
                if (store_addr[23]) begin
                    play_select[1] = store_addr[22:0];
                    play_record = 1;
                end
                /*                
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
                endcase*/
                play_speed = SW[16:15];
                if (STOP) begin
                    play_stop = 1;
                end
                if (play_done) begin
                    n_state = control_IDLE;
                end
                if (REC) n_page = ~page;
            end
            control_MIX: begin
                mix_start = 1;
                case({gpio[13],gpio[6:0]})
                    8'b0000_0001: begin 
                        if( (~page && store_addr[22:0] != CHUNK[0]) ) mix_num[0] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[8]) ) mix_num[8] = 1;
                    end
                    8'b0000_0010: begin 
                        if( (~page && store_addr[22:0] != CHUNK[1]) ) mix_num[1] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[9]) ) mix_num[9] = 1;
                    end
                    8'b0000_0100: begin 
                        if( (~page && store_addr[22:0] != CHUNK[2]) ) mix_num[2] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[10]) ) mix_num[10] = 1;
                    end
                    8'b0000_1000: begin 
                        if( (~page && store_addr[22:0] != CHUNK[3]) ) mix_num[3] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[11]) ) mix_num[11] = 1;
                    end
                    8'b0001_0000: begin
                        if( (~page && store_addr[22:0] != CHUNK[4]) ) mix_num[4] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[12]) ) mix_num[12] = 1;
                    end
                    8'b0010_0000: begin
                        if( (~page && store_addr[22:0] != CHUNK[5]) ) mix_num[5] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[13]) ) mix_num[13] = 1;
                    end
                    8'b0100_0000: begin
                        if( (~page && store_addr[22:0] != CHUNK[6]) ) mix_num[6] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[14]) ) mix_num[14] = 1;
                    end
                    8'b1000_0000: begin
                        if( (~page && store_addr[22:0] != CHUNK[7]) ) mix_num[7] = 1;
                        if( (page  && store_addr[22:0] != CHUNK[15]) ) mix_num[15] = 1;
                    end
                endcase
                if (store_addr[23]) begin
                    mix_select[16] = store_addr[22:0];
                    mix_num[16] = 1;
                end

/*
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
                endcase*/
				mix_loop[15:0] = SW[15:0];
                if (STOP) begin
                    mix_stop = 1;
                end
                if (mix_done) begin
                    n_state = control_IDLE;
                end
                if (REC) n_page = ~page;
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