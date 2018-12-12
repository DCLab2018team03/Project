
// SDRAM access core
// Be ware of that the input from other module is 16-bit

module SDRAMBus (
    input i_clk,
    input i_rst,

    output [22:0] new_sdram_controller_0_s1_address,       
	output [3:0]  new_sdram_controller_0_s1_byteenable_n,        
	output        new_sdram_controller_0_s1_chipselect,        
	output [31:0] new_sdram_controller_0_s1_writedata,        
	output        new_sdram_controller_0_s1_read_n,        
	output        new_sdram_controller_0_s1_write_n,        
	input  [31:0] new_sdram_controller_0_s1_readdata,        
	input         new_sdram_controller_0_s1_readdatavalid,        
	input         new_sdram_controller_0_s1_waitrequest,  

    input  [22:0] sdram_addr,
    input  sdram_read,
    output [15:0] sdram_readdata,
    input  sdram_write,
    input  [15:0] sdram_writedata,
    output sdram_finished,

);
    assign new_sdram_controller_0_s1_address = sdram_addr;
    assign new_sdram_controller_0_s1_read_n = ~sdram_read;
    assign new_sdram_controller_0_s1_write_n = ~sdram_write;
    assign new_sdram_controller_0_s1_chipselect = 1'b1;

    assign new_sdram_controller_0_s1_byteenable_n = 4'd0;
    // May cause critical path, if so, block FFs here.
    assign sdram_readdata = new_sdram_controller_0_s1_readdata;
    assign new_sdram_controller_0_s1_writedata = sdram_writedata;
    
    logic [1:0] state, n_state;
    localparam IDLE  = 2'b00;
    localparam READ  = 2'b01;
    localparam WRITE = 2'b10;

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= n_state;
        end
    end

    always_comb begin

        n_state = state;
        sdram_finished = 0;
        
        case(state)
            IDLE: begin
                if (sdram_read) begin
                    n_state = READ;
                end
                if (sdram_write) begin
                    n_state = WRITE;
                end
            end
            READ: begin
                if (!new_sdram_controller_0_s1_waitrequest && new_sdram_controller_0_s1_readdatavalid) begin
                    sdram_finished = 1;
                    n_state = IDLE;
                end
            end
            WRITE: begin
                if (!new_sdram_controller_0_s1_waitrequest) begin
                    sdram_finished = 1;
                    n_state = IDLE;
                end
            end
            default: n_state = state;
        endcase
    end
endmodule