
module Total (
	audio_0_avalon_left_channel_sink_data,
	audio_0_avalon_left_channel_sink_valid,
	audio_0_avalon_left_channel_sink_ready,
	audio_0_avalon_left_channel_source_ready,
	audio_0_avalon_left_channel_source_data,
	audio_0_avalon_left_channel_source_valid,
	audio_0_avalon_right_channel_sink_data,
	audio_0_avalon_right_channel_sink_valid,
	audio_0_avalon_right_channel_sink_ready,
	audio_0_avalon_right_channel_source_ready,
	audio_0_avalon_right_channel_source_data,
	audio_0_avalon_right_channel_source_valid,
	audio_0_external_interface_ADCDAT,
	audio_0_external_interface_ADCLRCK,
	audio_0_external_interface_BCLK,
	audio_0_external_interface_DACDAT,
	audio_0_external_interface_DACLRCK,
	audio_and_video_config_0_external_interface_SDAT,
	audio_and_video_config_0_external_interface_SCLK,
	audio_pll_0_audio_clk_clk,
	clk_clk,
	new_sdram_controller_0_s1_address,
	new_sdram_controller_0_s1_byteenable_n,
	new_sdram_controller_0_s1_chipselect,
	new_sdram_controller_0_s1_writedata,
	new_sdram_controller_0_s1_read_n,
	new_sdram_controller_0_s1_write_n,
	new_sdram_controller_0_s1_readdata,
	new_sdram_controller_0_s1_readdatavalid,
	new_sdram_controller_0_s1_waitrequest,
	new_sdram_controller_0_wire_addr,
	new_sdram_controller_0_wire_ba,
	new_sdram_controller_0_wire_cas_n,
	new_sdram_controller_0_wire_cke,
	new_sdram_controller_0_wire_cs_n,
	new_sdram_controller_0_wire_dq,
	new_sdram_controller_0_wire_dqm,
	new_sdram_controller_0_wire_ras_n,
	new_sdram_controller_0_wire_we_n,
	reset_reset_n,
	sys_sdram_pll_0_sdram_clk_clk);	

	input	[15:0]	audio_0_avalon_left_channel_sink_data;
	input		audio_0_avalon_left_channel_sink_valid;
	output		audio_0_avalon_left_channel_sink_ready;
	input		audio_0_avalon_left_channel_source_ready;
	output	[15:0]	audio_0_avalon_left_channel_source_data;
	output		audio_0_avalon_left_channel_source_valid;
	input	[15:0]	audio_0_avalon_right_channel_sink_data;
	input		audio_0_avalon_right_channel_sink_valid;
	output		audio_0_avalon_right_channel_sink_ready;
	input		audio_0_avalon_right_channel_source_ready;
	output	[15:0]	audio_0_avalon_right_channel_source_data;
	output		audio_0_avalon_right_channel_source_valid;
	input		audio_0_external_interface_ADCDAT;
	input		audio_0_external_interface_ADCLRCK;
	input		audio_0_external_interface_BCLK;
	output		audio_0_external_interface_DACDAT;
	input		audio_0_external_interface_DACLRCK;
	inout		audio_and_video_config_0_external_interface_SDAT;
	output		audio_and_video_config_0_external_interface_SCLK;
	output		audio_pll_0_audio_clk_clk;
	input		clk_clk;
	input	[22:0]	new_sdram_controller_0_s1_address;
	input	[3:0]	new_sdram_controller_0_s1_byteenable_n;
	input		new_sdram_controller_0_s1_chipselect;
	input	[31:0]	new_sdram_controller_0_s1_writedata;
	input		new_sdram_controller_0_s1_read_n;
	input		new_sdram_controller_0_s1_write_n;
	output	[31:0]	new_sdram_controller_0_s1_readdata;
	output		new_sdram_controller_0_s1_readdatavalid;
	output		new_sdram_controller_0_s1_waitrequest;
	output	[12:0]	new_sdram_controller_0_wire_addr;
	output	[1:0]	new_sdram_controller_0_wire_ba;
	output		new_sdram_controller_0_wire_cas_n;
	output		new_sdram_controller_0_wire_cke;
	output		new_sdram_controller_0_wire_cs_n;
	inout	[31:0]	new_sdram_controller_0_wire_dq;
	output	[3:0]	new_sdram_controller_0_wire_dqm;
	output		new_sdram_controller_0_wire_ras_n;
	output		new_sdram_controller_0_wire_we_n;
	input		reset_reset_n;
	output		sys_sdram_pll_0_sdram_clk_clk;
endmodule
