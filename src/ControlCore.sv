module ControlCore (
    input i_clk,
	input i_rst,
    // inputevent
    input [3:0] KEY,
    input [17:0] SW, 

    input  loaddata_done,
    output mix_start,
    output [] mix_select [],
    input  mix_done,
    output pitch_start,
    output [] pitch_select [],
    output pitch_mode,
    output [] pitch_speed,
    input  pitch_done,
    output record_start,
    output [] record_select [],
    output record_pause,
    output record_stop,
    input  record_done
);
    parameter IDLE        = 4'd0;
    parameter LOAD        = 4'd1;
    parameter MIX         = 4'd2;
    parameter PITCH       = 4'd3;
    parameter PLAY        = 4'd4;
    parameter RECORD      = 4'd5;
    


endmodule 