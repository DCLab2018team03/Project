`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic clk, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [3:0] KEY;
    logic [17:0] SW;
    logic from_adc_left_channel_ready;
    logic [15:0] from_adc_left_channel_data;
    logic from_adc_left_channel_valid;
    logic from_adc_right_channel_ready;
    logic [15:0] from_adc_right_channel_data;
    logic from_adc_right_channel_valid;
    logic [15:0] to_dac_left_channel_data;
    logic to_dac_left_channel_valid;
    logic to_dac_left_channel_ready;
    logic [15:0] to_dac_right_channel_data;
    logic to_dac_right_channel_valid;
    logic to_dac_right_channel_ready;
    logic [22:0]new_sdram_controller_0_s1_address;
    logic [3:0] new_sdram_controller_0_s1_byteenable_n;
    logic new_sdram_controller_0_s1_chipselect;
    logic [31:0] new_sdram_controller_0_s1_writedata;
    logic new_sdram_controller_0_s1_read_n;
    logic new_sdram_controller_0_s1_write_n;
    logic [31:0] new_sdram_controller_0_s1_readdata;
    logic new_sdram_controller_0_s1_readdatavalid;
    logic new_sdram_controller_0_s1_waitrequest;

    AcappellaCore acappellacore(
		.i_clk(clk),
		.i_rst(rst),
		// Input
		.KEY(KEY),
        .SW(SW),
		.LEDG(),
        // avalon_audio_slave
        // avalon_left_channel_source
		.from_adc_left_channel_ready(from_adc_left_channel_ready),
        .from_adc_left_channel_data(from_adc_left_channel_data),
        .from_adc_left_channel_valid(from_adc_left_channel_valid),
        // avalon_right_channel_source
        .from_adc_right_channel_ready(from_adc_right_channel_ready),
        .from_adc_right_channel_data(from_adc_right_channel_data),
        .from_adc_right_channel_valid(from_adc_right_channel_valid),
        // avalon_left_channel_sink
        .to_dac_left_channel_data(to_dac_left_channel_data),
        .to_dac_left_channel_valid(to_dac_left_channel_valid),
        .to_dac_left_channel_ready(to_dac_left_channel_ready),
        // avalon_left_channel_sink
        .to_dac_right_channel_data(to_dac_right_channel_data),
        .to_dac_right_channel_valid(to_dac_right_channel_valid),
        .to_dac_right_channel_ready(to_dac_right_channel_ready),
        // SDRAM
        .new_sdram_controller_0_s1_address         (new_sdram_controller_0_s1_address),
        .new_sdram_controller_0_s1_byteenable_n    (new_sdram_controller_0_s1_byteenable_n),
        .new_sdram_controller_0_s1_chipselect      (new_sdram_controller_0_s1_chipselect),
        .new_sdram_controller_0_s1_writedata       (new_sdram_controller_0_s1_writedata),
        .new_sdram_controller_0_s1_read_n          (new_sdram_controller_0_s1_read_n),
        .new_sdram_controller_0_s1_write_n         (new_sdram_controller_0_s1_write_n),
        .new_sdram_controller_0_s1_readdata        (new_sdram_controller_0_s1_readdata),
        .new_sdram_controller_0_s1_readdatavalid   (new_sdram_controller_0_s1_readdatavalid),
        .new_sdram_controller_0_s1_waitrequest     (new_sdram_controller_0_s1_waitrequest)
	);

	initial begin
		$fsdbDumpfile("project.fsdb");
		$fsdbDumpvars;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
		rst = 1;
		#(2*CLK)
		rst = 0;
		@(posedge clk)
        from_adc_left_channel_data = 0;
        from_adc_left_channel_valid = 1;
        from_adc_right_channel_data = 0;
        from_adc_right_channel_valid = 1;
        to_dac_left_channel_ready = 1;
        to_dac_right_channel_ready = 1;
        new_sdram_controller_0_s1_waitrequest = 0;
        KEY = 0;
        @(posedge clk)
        @(posedge clk)
        KEY[0] = 1;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        KEY[0] = 0;
        KEY[1] = 1;
        new_sdram_controller_0_s1_readdatavalid = 1;
        new_sdram_controller_0_s1_readdata = 32'd123546464;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
		$finish;
	end


endmodule


