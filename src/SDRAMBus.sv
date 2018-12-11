
// SDRAM access core
// Be ware of that the input from other module is 16-bit

module SDRAMBus (
    output [22:0] new_sdram_controller_0_s1_address,       
	output [3:0]  new_sdram_controller_0_s1_byteenable_n,        
	output        new_sdram_controller_0_s1_chipselect,        
	output [31:0] new_sdram_controller_0_s1_writedata,        
	output        new_sdram_controller_0_s1_read_n,        
	output        new_sdram_controller_0_s1_write_n,        
	input  [31:0] new_sdram_controller_0_s1_readdata,        
	input         new_sdram_controller_0_s1_readdatavalid,        
	input         new_sdram_controller_0_s1_waitrequest,  

    input  loaddata_write,
    input  [22:0] loaddata_addr,
    input  [16:0] loaddata_writedata,
    output loaddata_finished
    input  mix_read,
    input  [22:0] mix_addr,
    output [15:0] mix_readdata,
    output mix_read_finished
    input  mix_write,
    input  [15:0] mix_writedata,
    output mix_write_finished,
    input  pitch_read,
    input  [22:0] pitch_addr,
    output [15:0] pitch_readdata,
    output pitch_read_finished
    input  pitch_write,
    input  [15:0]pitch_writedata,
    output pitch_write_finished,
    input  record_read,
    input  [22:0] record_addr,
    output [15:0] record_readdata,
    output record_read_finished
    input  record_write,
    input  [15:0] record_writedata,
    output record_write_finished,
    input  play_read,
    input  [22:0] play_addr,
    output [15:0] play_readdata,
    output play_read_finished

);
    
endmodule