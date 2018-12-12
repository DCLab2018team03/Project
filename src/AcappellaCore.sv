module AcappellaCore (
    input  logic         i_clk,
    input  logic         i_rst,
    input [3:0] KEY,
    input [17:0] SW,
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

    output logic [22:0] new_sdram_controller_0_s1_address,                //                   new_sdram_controller_0_s1.address
	output logic [3:0]  new_sdram_controller_0_s1_byteenable_n,           //                   .byteenable_n
	output logic        new_sdram_controller_0_s1_chipselect,             //                   .chipselect
	output logic [31:0] new_sdram_controller_0_s1_writedata,              //                   .writedata
	output logic        new_sdram_controller_0_s1_read_n,                 //                   .read_n
	output logic        new_sdram_controller_0_s1_write_n,                //                   .write_n
	input  logic [31:0] new_sdram_controller_0_s1_readdata,               //                   .readdata
	input  logic        new_sdram_controller_0_s1_readdatavalid,          //                   .readdatavalid
	input  logic        new_sdram_controller_0_s1_waitrequest,            //                   .waitrequest

);
    logic loaddata_done, loaddata_write, loaddata_sdram_finished
    logic [22:0] loaddata_addr;
    logic [31:0] loaddata_writedata;
    LoadCore loader(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // To controller
        .loaddata_done(loaddata_done),

        // To SDRAM
        .loaddata_write(loaddata_write),
        .loaddata_addr(loaddata_addr),
        .loaddata_writedata(loaddata_writedata),
        .loaddata_sdram_finished(loaddata_sdram_finished),

        // To RS232
    );

    logic mix_start, mix_done;
    logic [22:0] mix_select [4:0]; 
    logic mix_read, mix_write, mix_sdram_finished;
    logic [22:0] mix_addr;
    logic [31:0] mix_readdata, mix_writedata;
    MixCore mixer(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // To controller
        .mix_start(mix_start),
        .mix_select(mix_select),
        .mix_done(mix_done),

        // To SDRAM
        .mix_read(mix_read),
        .mix_addr(mix_addr),
        .mix_readdata(mix_readdata),
        .mix_write(mix_write),
        .mix_writedata(mix_writedata),
        .mix_sdram_finished(mix_sdram_finished)
    );
    
    logic pitch_start, pitch_done;
    logic [22:0] pitch_select [1:0];
    logic pitch_mode;
    logic [3:0] pitch_speed;

    logic pitch_read, pitch_write, pitch_sdram_finished;
    logic [22:0] pitch_addr;
    logic [31:0] pitch_readdata, pitch_writedata;
    PitchCore pitcher(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // To controller
        .pitch_start(pitch_start),
        .pitch_select(pitch_select),
        .pitch_mode(pitch_mode),
        .pitch_speed(pitch_speed),
        .pitch_done(pitch_done),

        // To SDRAM
        .pitch_read(pitch_read),
        .pitch_addr(pitch_addr),
        .pitch_readdata(pitch_readdata),
        .pitch_write(pitch_write),
        .pitch_writedata(pitch_writedata),
        .pitch_sdram_finished(pitch_sdram_finished)
    );

    logic record_start, record_pause, record_stop, record_done;
    logic [22:0] record_select [1:0];

    logic record_read, record_write, record_sdram_finished;
    logic [22:0] record_addr;
    logic [31:0] record_readdata, record_writedata;

    logic record_audio_valid, record_audio_ready;
    logic [15:0] record_audio_data;
    RecordCore recorder(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // To controller
        .record_start(record_start),
        .record_select(record_select),
        .record_pause(record_pause),
        .record_stop(record_stop),
        .record_done(record_done),

        // To SDRAM
        .record_read(record_read),
        .record_addr(record_addr),
        .record_readdata(record_readdata),
        .record_write(record_write),
        .record_writedata(record_writedata),
        .record_sdram_finished(record_sdram_finished)

        // To audio
        .record_audio_ready(record_audio_ready),
        .record_audio_data(record_audio_data),
        .record_audio_valid(record_audio_valid)
    );

    logic play_start, play_pause, play_stop, play_done;
    logic [22:0] play_select;

    logic play_read, play_sdram_finished;
    logic [22:0] play_addr;
    logic [31:0] play_readdata;

    logic play_audio_valid, play_audio_ready;
    logic [31:0] play_audio_data;

    PlayCore player(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // to controller
        .play_start(play_start),
        .play_select(play_select),
        .play_pause(play_pause),
        .play_stop(play_stop),
        .play_done(play_done),

        // To SDRAM
        .play_read(play_read),
        .play_addr(play_addr),
        .play_readdata(play_readdata),
        .play_sdram_finished(play_sdram_finished),

        // To audio
        .play_audio_valid(play_audio_valid),
        .play_audio_data(play_audio_data),
        .play_audio_ready(play_audio_ready)
    );

    ControlCore controller(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // input signal
        .KEY(KEY),
        .SW(SW),

        .loaddata_done(loaddata_done),

        .mix_start(mix_start),
        .mix_select(mix_select),
        .mix_done(mix_done),

        .pitch_start(pitch_start),
        .pitch_select(pitch_select),
        .pitch_mode(pitch_mode),
        .pitch_speed(pitch_speed),
        .pitch_done(pitch_done),

        .record_start(record_start),
        .record_select(record_select),
        .record_pause(record_pause),
        .record_stop(record_stop),
        .record_done(record_done),

        .play_start(play_start),
        .play_select(play_select),
        .play_pause(play_pause),
        .play_stop(play_stop),
        .play_done(play_done),
    );

    AudioBus audiobus(
        .i_clk(i_clk),
        .i_rst(i_rst),

        // avalon_left_channel_source
        .from_adc_left_channel_ready(w_adc_left_ready),
        .from_adc_left_channel_data(w_adc_left_data),
        .from_adc_left_channel_valid(w_adc_left_valid),
        // avalon_right_channel_source
        .from_adc_right_channel_ready(w_adc_right_ready),
        .from_adc_right_channel_data(w_adc_right_data),
        .from_adc_right_channel_valid(w_adc_right_valid),
        // avalon_left_channel_sink
        .to_dac_left_channel_data(w_dac_left_data),
        .to_dac_left_channel_valid(w_dac_left_valid),
        .to_dac_left_channel_ready(w_dac_left_ready),
        // avalon_left_channel_sink
        .to_dac_right_channel_data(w_dac_right_data),
        .to_dac_right_channel_valid(w_dac_right_valid),
        .to_dac_right_channel_ready(w_dac_right_ready),

        .record_audio_ready(record_audio_ready),
        .record_audio_data(record_audio_data),
        .record_audio_valid(record_audio_valid),

        .play_audio_valid(play_audio_valid),
        .play_audio_data(play_audio_data),
        .play_audio_ready(play_audio_ready)
    );

    logic sdram_read, sdram_write, sdram_finished;
    logic [22:0] sdram_addr;
    logic [31:0] sdram_readdata, sdram_writedata;

    // WARNING: all input signal should be set to 0 if not used !!!!!!!
    // Maybe use MUX is better. need some discusssion 
    assign sdram_read = mix_read | pitch_read | record_read | play_read;
    assign sdram_write = loaddata_write | mix_write | pitch_write | record_write;
    assign sdram_addr = loaddata_addr | mix_addr | pitch_addr | record_addr | play_addr;
    assign sdram_writedata = loaddata_writedata | mix_writedata | pitch_writedata | record_writedata;

    assign mix_readdata    = sdram_readdata;
    assign pitch_readdata  = sdram_readdata;
    assign record_readdata = sdram_readdata;
    assign play_readdata   = sdram_readdata;

    assign loaddata_sdram_finished = sdram_finished;
    assign mix_sdram_finished      = sdram_finished;
    assign pitch_sdram_finished    = sdram_finished;
    assign record_sdram_finished   = sdram_finished;
    assign play_sdram_finished     = sdram_finished;


    SDRAMBus sdrambus(
        .new_sdram_controller_0_s1_address         (new_sdram_controller_0_s1_address),
        .new_sdram_controller_0_s1_byteenable_n    (new_sdram_controller_0_s1_byteenable_n),
        .new_sdram_controller_0_s1_chipselect      (new_sdram_controller_0_s1_chipselect),
        .new_sdram_controller_0_s1_writedata       (new_sdram_controller_0_s1_writedata),
        .new_sdram_controller_0_s1_read_n          (new_sdram_controller_0_s1_read_n),
        .new_sdram_controller_0_s1_write_n         (new_sdram_controller_0_s1_write_n),
        .new_sdram_controller_0_s1_readdata        (new_sdram_controller_0_s1_readdata),
        .new_sdram_controller_0_s1_readdatavalid   (new_sdram_controller_0_s1_readdatavalid),
        .new_sdram_controller_0_s1_waitrequest     (new_sdram_controller_0_s1_waitrequest),

        .sdram_addr(sdram_addr),
        .sdram_read(sdram_read),
        .sdram_readdata(sdram_readdata),
        .sdram_write(sdram_write),
        .sdram_writedata(sdram_writedata),
        .sdram_finished(sdram_finished)
        /*
        .loaddata_write(loaddata_write),
        .loaddata_addr(loaddata_addr),
        .loaddata_writedata(loaddata_writedata),
        .loaddata_finished(loaddata_finished)
        .mix_read(mix_read),
        .mix_addr(mix_addr),
        .mix_readdata(mix_readdata),
        .mix_read_finished(mix_read_finished)
        .mix_write(mix_write),
        .mix_writedata(mix_writedata),
        .mix_write_finished(mix_write_finished),
        .pitch_read(pitch_read),
        .pitch_addr(pitch_addr),
        .pitch_readdata(pitch_readdata),
        .pitch_read_finished(pitch_read_finished)
        .pitch_write(pitch_write),
        .pitch_writedata(pitch_writedata),
        .pitch_write_finished(pitch_write_finished),
        .record_read(record_read),
        .record_addr(record_addr),
        .record_readdata(record_readdata),
        .record_read_finished(record_read_finished)
        .record_write(record_write),
        .record_writedata(record_writedata),
        .record_write_finished(record_write_finished),
        .play_read(play_read),
        .play_addr(play_addr),
        .play_readdata(play_readdata),
        .play_read_finished(play_read_finished)
        */
    );
endmodule