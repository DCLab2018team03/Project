
// Playing audio
// Activated by _start, and _done = 1 after finishing
// _select is the targeted address

// pause
// stop is to stop recording

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)

module PlayCore (
    input i_clk,
    input i_rst,
    // to controller
    input  play_start,
    input  [22:0] play_select,
    input  play_pause,
    input  play_stop,
    output play_done,

    // To SDRAM
    output play_read,
    output [22:0] play_addr,
    input  [15:0] play_readdata,
    input  play_read_finished,

    // To audio
    output play_audio_valid,
    output [15:0] play_audio_data,
    input  play_audio_ready
);
    
endmodule