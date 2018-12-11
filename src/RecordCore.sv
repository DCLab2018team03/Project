
// Recording audio
// Activated by _start, and _done = 1 after finishing
// _select is an "address array"
// 0 is the storage address, and others are target address.
// If 1 is not specified, then it records audio from the microphone

// pause is to change target address
// stop is to stop recording

// Communicate with SDRAM by read, write.
// Give control signal, address(and data).
// Once finished = 1, data has been writen(or the readdate is correct)

module RecordCore (
    input i_clk,
    input i_rst,
    // To controller
    input  record_start,
    input  [22:0] record_select [1:0],
    input  record_pause,
    input  record_stop,
    output record_done,

    // To SDRAM
    output record_read,
    output [22:0] record_addr,
    input  [15:0] record_readdata,
    input  record_read_finished
    output record_write,
    output [15:0] record_writedata,
    input  record_write_finished,

    // To audio
    output record_audio_ready,
    input  [15:0] record_audio_data,
    input  record_audio_valid
);
    
endmodule