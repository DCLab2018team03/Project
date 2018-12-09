module AcappellaCore (
    input  logic         i_clk,
    input  logic         i_rst,
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
    logic loaddata_done, loaddata_valid, loaddata_done;
    logic [22:0] loaddata_addr;
    logic [] loaddata_data;
    LoadCore loader(
        .i_clk(i_clk),
        .i_rst(i_rst),
        // To controller
        .loaddata_done(loaddata_done),

        // To SDRAM
        .loaddata_valid(loadata_valid),
        .loaddata_addr(loaddata_addr),
        .loaddata_data(loaddata_data),
        .loaddata_finished(loaddata_finished)

        // To RS232
    );

    logic mix_start, mix_done;
    logic [] mix_select []; 
    logic mix_read, mix_write, mix_read_finished, mix_write_finished;
    logic [22:0] mix_addr;
    logic [] mix_readdata, mix_writedata;
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
        .mix_read_finished(mix_read_finished)
        .mix_write(mix_write),
        .mix_addr(mix_addr),
        .mix_writedata(mix_writedata),
        .mix_write_finished(mix_write_finished)
    );
    
    logic pitch_start, pitch_done;
    logic [] pitch_select [];
    logic pitch_mode;
    logic [] pitch_speed;

    logic pitch_start, pitch_done;
    logic [] pitch_select []; 
    logic pitch_read, pitch_write, pitch_read_finished, pitch_write_finished;
    logic [22:0] pitch_addr;
    logic [] pitch_readdata, pitch_writedata;
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
        .pitch_read_finished(pitch_read_finished)
        .pitch_write(pitch_write),
        .pitch_addr(pitch_addr),
        .pitch_writedata(pitch_writedata),
        .pitch_write_finished(pitch_write_finished)
    );

    logic record_start, record_pause, record_stop, record_done;
    logic [] record_select [];

    logic record_start, record_done;
    logic [] record_select []; 
    logic record_read, record_write, record_read_finished, record_write_finished;
    logic [22:0] record_addr;
    logic [] record_readdata, record_writedata;
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
        .record_read_finished(record_read_finished)
        .record_write(record_write),
        .record_addr(record_addr),
        .record_writedata(record_writedata),
        .record_write_finished(record_write_finished)
    );

    ControlCore controller(
        .i_clk(i_clk),
        .i_rst(i_rst),
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
        .record_done(record_done)
    );

    AudioBus audiobus(
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
        .to_dac_right_channel_ready(w_dac_right_ready)
    );

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

        .loaddata_valid(loadata_valid),
        .loaddata_addr(loaddata_addr),
        .loaddata_data(loaddata_data),
        .loaddata_finished(loaddata_finished),
        .mix_read(mix_read),
        .mix_addr(mix_addr),
        .mix_readdata(mix_readdata),
        .mix_read_finished(mix_read_finished)
        .mix_write(mix_write),
        .mix_addr(mix_addr),
        .mix_writedata(mix_writedata),
        .mix_write_finished(mix_write_finished),
        .pitch_read(pitch_read),
        .pitch_addr(pitch_addr),
        .pitch_readdata(pitch_readdata),
        .pitch_read_finished(pitch_read_finished)
        .pitch_write(pitch_write),
        .pitch_addr(pitch_addr),
        .pitch_writedata(pitch_writedata),
        .pitch_write_finished(pitch_write_finished),
        .record_read(record_read),
        .record_addr(record_addr),
        .record_readdata(record_readdata),
        .record_read_finished(record_read_finished)
        .record_write(record_write),
        .record_addr(record_addr),
        .record_writedata(record_writedata),
        .record_write_finished(record_write_finished)
    );
endmodule