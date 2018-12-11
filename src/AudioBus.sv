
// record and play core

module AudioBus (
    input i_clk,
    input i_rst,
    // avalon_audio_slave
    // avalon_left_channel_source
    output from_adc_left_channel_ready,
    input  [15:0] from_adc_left_channel_data,
    input  from_adc_left_channel_valid,
    // avalon_right_channel_source
    output from_adc_right_channel_ready,
    input  [15:0] from_adc_right_channel_data,
    input  from_adc_right_channel_valid,
    // avalon_left_channel_sink
    output [15:0] to_dac_left_channel_data,
    output to_dac_left_channel_valid,
    input  to_dac_left_channel_ready,
    // avalon_right_channel_sink
    output [15:0] to_dac_right_channel_data,
    output to_dac_right_channel_valid,
    input  to_dac_right_channel_ready,

    input  record_audio_ready,
    output [15:0] record_audio_data,
    output record_audio_valid,

    input  play_audio_valid,
    input  [15:0] play_audio_data,
    output play_audio_ready
);
    
endmodule