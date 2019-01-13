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
		$fsdbDumpvars(0,tb,"+mda");
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
		@(negedge clk);
		pitch_sdram_finished = 1;
        pitch_readdata = 32'h00003fff;
        @(negedge clk);
		pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h6bd6e385;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h9a558c31;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h9e0372a7;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'ha0f5d90;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'ha2b125d3;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h136f1aeb;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hf037f272;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h902de496;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hef10ec7d;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hf621b545;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hce867c7c;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h59cc35c3;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hece0d257;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h35510ce5;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hff921483;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h654bf7b;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h28deb9d6;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h68671b70;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'he0318154;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h8b78143b;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h384f80f2;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hce5b6ea6;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hb40d4c25;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h3b36dfb3;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h1fccb1da;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h8c6be3a4;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h38314ea;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hb66565af;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h9944564e;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'ha212db8;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'hb8b2f855;
        @(negedge clk);
        pitch_sdram_finished = 0;
        @(negedge clk);
        pitch_sdram_finished = 1;
        pitch_readdata = 32'h75759a23;
        @(negedge clk);
        pitch_sdram_finished = 0;
        
	end

	initial begin
		#(50000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
