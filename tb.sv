`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic clk, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;

	logic start;
	logic [22:0] pitch_select [1:0];
	logic mode;
	logic [3:0] speed;
	logic done;

	logic pitch_read;
    logic [22:0] pitch_addr;
    logic [31:0] pitch_readdata;
    logic pitch_write;
    logic [31:0] pitch_writedata;
    logic pitch_sdram_finished;

	wire [15:0] SRAM_DQ;     // SRAM Data bus 16 Bits
    logic [19:0] SRAM_ADDR;   // SRAM Address bus 20 Bits
    logic        SRAM_WE_N;   // SRAM Write Enable
    logic        SRAM_CE_N;   // SRAM Chip Enable
    logic        SRAM_OE_N;   // SRAM Output Enable
    logic        SRAM_LB_N;   // SRAM Low-byte Data Mask 
    logic        SRAM_UB_N;    // SRAM High-byte Data Mask
	logic [4:0]  SRAM_MODE;
	logic [15:0] sram_data;
	localparam SRAM_NOT_SELECT = 5'b01000;
    localparam SRAM_READ       = 5'b10000;
    localparam SRAM_WRITE      = 5'b00000;

	PitchCore core(
    	.i_clk(clk),
    	.i_rst(rst),
    	// To controller
    	.pitch_start(start),
    	.pitch_select(pitch_select),
    	.pitch_mode(mode),
    	.pitch_speed(speed),
    	.pitch_done(done),

    	// To SDRAM
    	.pitch_read(pitch_read),
    	.pitch_addr(pitch_addr),
    	.pitch_readdata(pitch_readdata),
    	.pitch_write(pitch_write),
    	.pitch_writedata(pitch_writedata),
    	.pitch_sdram_finished(pitch_sdram_finished),

    	// To SRAM
    	.SRAM_DQ(SRAM_DQ),     // SRAM Data bus 16 Bits
    	.SRAM_ADDR(SRAM_ADDR),   // SRAM Address bus 20 Bits
    	.SRAM_WE_N(SRAM_WE_N),   // SRAM Write Enable
    	.SRAM_CE_N(SRAM_CE_N),   // SRAM Chip Enable
    	.SRAM_OE_N(SRAM_OE_N),   // SRAM Output Enable
    	.SRAM_LB_N(SRAM_LB_N),   // SRAM Low-byte Data Mask 
    	.SRAM_UB_N(SRAM_UB_N)    // SRAM High-byte Data Mask
	);
	assign SRAM_MODE = {SRAM_WE_N, SRAM_CE_N, SRAM_OE_N, SRAM_LB_N, SRAM_UB_N};
	assign SRAM_DQ = SRAM_WE_N ? 16'hzzzz : sram_data;
	
	initial begin
		$fsdbDumpfile("pitch.fsdb");
		$fsdbDumpvars;
		rst = 1;
		#(2*CLK)
		rst = 0;
		@(negedge clk);
		@(negedge clk);
		start = 1;
		pitch_select[0] = 0;
		pitch_select[1] = 1024;
		mode = 0;
		speed = 1011;
		@(negedge clk);
		start = 0;
		forever begin
		if (pitch_read) begin
			@(negedge clk);
			@(negedge clk);
			@(negedge clk);
			pitch_sdram_finished = 1;
			pitch_readdata = 512;
			@(negedge clk)
			pitch_sdram_finished = 0;
		end
		if (pitch_write) begin
			@(negedge clk);
			@(negedge clk);
			pitch_sdram_finished = 1;
			@(negedge clk)
			pitch_sdram_finished = 0;
		end
		if (SRAM_MODE == SRAM_READ) begin
			@(negedge clk);
			sram_data = 512;
		end
		end
		forever if (done) $finish;
	end

	initial begin
		#(5000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
