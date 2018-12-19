
// SDRAM access core
// Be ware of that the input from other module is 16-bit

module SDRAMBus (
    input i_clk,
    input i_rst,

    output logic [22:0] new_sdram_controller_0_s1_address,       
	output logic [3:0]  new_sdram_controller_0_s1_byteenable_n,        
	output logic        new_sdram_controller_0_s1_chipselect,        
	output logic [31:0] new_sdram_controller_0_s1_writedata,        
	output logic        new_sdram_controller_0_s1_read_n,        
	output logic        new_sdram_controller_0_s1_write_n,        
	input  logic [31:0] new_sdram_controller_0_s1_readdata,        
	input  logic        new_sdram_controller_0_s1_readdatavalid,        
	input  logic        new_sdram_controller_0_s1_waitrequest,  

    input  logic [22:0] sdram_addr,
    input  logic sdram_read,
    output logic [31:0] sdram_readdata,
    input  logic sdram_write,
    input  logic [31:0] sdram_writedata,
    output logic sdram_finished,
    output [1:0] debug

);
    assign new_sdram_controller_0_s1_address = sdram_addr;
    assign new_sdram_controller_0_s1_read_n = !sdram_read;
    assign new_sdram_controller_0_s1_write_n = !sdram_write;
    assign new_sdram_controller_0_s1_chipselect = 1'b1;

    assign new_sdram_controller_0_s1_byteenable_n = 4'd0;
    // May cause critical path, if so, block FFs here.
    assign sdram_readdata = new_sdram_controller_0_s1_readdata;
    assign new_sdram_controller_0_s1_writedata = sdram_writedata;
    
    logic [1:0] state, n_state;
    assign debug = state;
    localparam IDLE  = 2'b00;
    localparam READ  = 2'b01;
    localparam WRITE = 2'b10;

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
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
                if (!sdram_read) begin
                    n_state = IDLE;
                end
                if (!new_sdram_controller_0_s1_waitrequest && new_sdram_controller_0_s1_readdatavalid) begin
                    sdram_finished = 1;
                    n_state = IDLE;
                end
            end
            WRITE: begin
                if (!sdram_write) begin
                    n_state = IDLE;
                end
                if (!new_sdram_controller_0_s1_waitrequest) begin
                    sdram_finished = 1;
                    n_state = IDLE;
                end
            end
            default: n_state = state;
        endcase
    end
endmodule