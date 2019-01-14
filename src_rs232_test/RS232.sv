module Rsa256Wrapper(
    input avm_rst,
    input avm_clk,
    output [4:0] avm_address,
    output avm_read,
    input [31:0] avm_readdata,
    output avm_write,
    output [31:0] avm_writedata,
    input avm_waitrequest,
    // sdram
    output  logic [22:0] sdram_addr,
    output  logic sdram_read,
    input logic [31:0] sdram_readdata,
    output  logic sdram_write,
    output  logic [31:0] sdram_writedata,
    input logic sdram_finished
);
    localparam RX_BASE     = 0*4;
    localparam TX_BASE     = 1*4;
    localparam STATUS_BASE = 2*4;
    localparam TX_OK_BIT = 6;
    localparam RX_OK_BIT = 7;

    // Feel free to design your own FSM!    
	localparam QUERY_RX      = 0;
	localparam READ          = 1;
	localparam STORE         = 2;
	localparam QUERY_TX      = 3;
	localparam WRITE         = 4;

    localparam READ_ADDRESS  = 0;
    localparam READ_HEADER   = 1;
    localparam READ_DATA     = 2;

    localparam STORE_HEADER  = 0;
    localparam STORE_DATA    = 1;
	
    logic [2:0] state_r, state_w;
    logic [1:0] data_state_r, data_state_w; 
    logic       store_state_r, store_state_w;
       
    logic [4:0] avm_address_r, avm_address_w;
    logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;
    
    logic [1:0] bytes_counter_r, bytes_counter_w;
    logic [31:0] store_counter_r, store_counter_w;
    logic [31:0] cycle; // cycle is determined by memory chunk (2^32 cycles for testing)
    logic [31:0] address_w, address_r;
    logic [31:0] header_w, header_r;
    logic [31:0] data_w, data_r;
    assign cycle = header_r;

    assign avm_address = avm_address_r;
    assign avm_read = avm_read_r;
    assign avm_write = avm_write_r;
    assign avm_writedata = writedata;

    // sdram
    output  logic [22:0] n_sdram_addr;
    output  logic n_sdram_read;
    output  logic n_sdram_write;
    output  logic [31:0] n_sdram_writedata;

    task Wait;
        begin
            avm_read_w = 0;
            avm_write_w = 0;
        end
    endtask
    task StartRead;
        input [4:0] addr;
        begin
            avm_read_w = 1;
            avm_write_w = 0;
            avm_address_w = addr;
        end
    endtask
    task StartWrite;
        input [4:0] addr;
        begin
            avm_read_w = 0;
            avm_write_w = 1;
            avm_address_w = addr;
        end
    endtask

    always @(*) begin
        avm_address_w = avm_address_r;
        avm_read_w = avm_read_r;
        avm_write_w = avm_write_r;
        state_w = state_r;
        data_state_w = data_state_r;
        store_state_w = store_state_r;
        bytes_counter_w = bytes_counter_r;
        store_counter_w = store_counter_r;
        address_w = address_r;
        header_w = header_r;
        data_w = data_r;
        n_sdram_addr = sdram_addr;
        n_sdram_read = sdram_read;
        n_sdram_write = sdram_write;
        n_sdram_writedata = sdram_writedata;
		case(state_r)		
			QUERY_RX: begin
                if(!avm_waitrequest && avm_read_r) begin
                    if(avm_readdata[RX_OK_BIT]) begin
                        StartRead(RX_BASE);
                        state_w = READ;
                    end
                end 
                else begin
                    StartRead(STATUS_BASE);
                    state_w = QUERY_RX;
                end
			end		
			READ: begin
			    if(!avm_waitrequest && avm_read_r) begin
                    Wait();
                    bytes_counter_w = bytes_counter_r + 1;
                    state_w = QUERY_RX;				
					case(data_state_r)
                        READ_ADDRESS: begin
                            address_w = address_r << 8;
                            address_w[7:0] = avm_readdata[7:0];
                            if (bytes_counter_r == 3) begin
                                data_state_w = READ_HEADER;
                                bytes_counter_w = 0;
                            end
                        end
                        READ_HEADER: begin
                            header_w = header_r << 8;
                            header_w[7:0] = avm_readdata[7:0];
                            if (bytes_counter_r == 3) begin
                                data_state_w = READ_DATA;
                                bytes_counter_w = 0;
                                state_w = STORE;
                            end   
                        end
						READ_DATA: begin
							data_w = data_r << 8;
						    data_w[7:0] = avm_readdata[7:0];
                            if (bytes_counter_r == 3) begin
                                bytes_counter_w = 0;
                                state_w = STORE;					
			                end                            							
						end
					endcase
                end
			end						
			STORE: begin
				n_sdram_write = 1'b1;
                n_sdram_addr = address_r[22:0];
                case (store_state_r) 
                    STORE_HEADER: begin
                        n_sdram_writedata = header_r;
                        if (sdram_finished) begin
                            state_w = QUERY_RX;
                            store_state_w = STORE_DATA;
                            address_w = address_r + 1;
                            n_sdram_write = 1'b0;
                        end
                    end
                    STORE_DATA: begin
                        n_sdram_writedata = data_r;
                        store_counter_w = store_counter_r + 1;
                        if (sdram_finished) begin
                            if (store_counter_r == cycle) begin
                                avm_address_r <= STATUS_BASE;
                                avm_read_r <= 1;
                                avm_write_r <= 0;
                                state_r <= QUERY_RX;
                                data_state_r <= READ_HEADER;
                                store_state_r <= STORE_HEADER;
                                bytes_counter_r <= 0;
                                store_counter_r <= 0;
                                address_r <= 32'd0;
                                header_r <= 32'd0;
                                data_r <= 32'd0;
                                sdram_addr <= 23'd0;
                                sdram_read <= 0;
                                sdram_write <= 0;
                                sdram_writedata <= 32'd0;
                            end
                            else begin
                                state_w = QUERY_RX;
                                address_w = address_r + 1;
                                n_sdram_write = 1'b0;
                            end
                        end
                    end
                endcase
			end
            /*	
			QUERY_TX: begin				
				if(!avm_waitrequest && avm_read_r) begin
                    if(avm_readdata[TX_OK_BIT]) begin
					    StartWrite(TX_BASE);
                        state_w = WRITE;
                    end
				end 
                else begin
					StartRead(STATUS_BASE);
                    state_w = QUERY_TX;
				end			
			end
			WRITE: begin
				if(!avm_waitrequest && avm_write_r) begin
                    Wait();
                    if (bytes_counter_r == cycle-1) begin
                        bytes_counter_w = 0;
                        state_w = QUERY_RX;
                        dec_w = 0;
                        if (enc_counter_r == enc_cycle) begin // same as reset
                            n_w = 0;
                            e_w = 0;
                            enc_w = 0;
                            dec_w = 0;
                            avm_address_w <= STATUS_BASE;
                            avm_read_w <= 1;
                            avm_write_w <= 0;
                            state_w <= QUERY_RX;
                            data_state_w <= READ_HEADER;
                            bytes_counter_w <= 0;
                            rsa_start_w <= 0;
                            enc_counter_w <= 0;
                            header_w <= 8'b01111111;
                        end
                        else begin 
                            data_state_w = READ_DATA;
                            enc_counter_w = enc_counter_r + 1;
                        end
                    end
                    else begin
                        bytes_counter_w = bytes_counter_r + 1;
                        state_w = QUERY_TX;
                        dec_w = dec_r << 8;
                    end                   	
				end 
			end
            */	
		endcase
    end

    always_ff @(posedge avm_clk or posedge avm_rst) begin
		if (avm_rst) begin
            avm_address_r <= STATUS_BASE;
            avm_read_r <= 1;
            avm_write_r <= 0;
            state_r <= QUERY_RX;
            data_state_r <= READ_HEADER;
            store_state_r <= STORE_HEADER;
            bytes_counter_r <= 0;
            store_counter_r <= 0;
            address_r <= 32'd0;
            header_r <= 32'd0;
            data_r <= 32'd0;
            sdram_addr <= 23'd0;
            sdram_read <= 0;
            sdram_write <= 0;
            sdram_writedata <= 32'd0;
        end else begin
            avm_address_r <= avm_address_w;
            avm_read_r <= avm_read_w;
            avm_write_r <= avm_write_w;
            state_r <= state_w;
            data_state_r <= data_state_w;
            store_state_r <= store_state_w;
            bytes_counter_r <= bytes_counter_w;
            store_counter_r <= store_counter_w;
            address_r <= address_w;
            header_r <= header_w;
            data_r <= data_w;
            sdram_addr <= n_sdram_addr;
            sdram_read <= n_sdram_read;
            sdram_write <= n_sdram_write;
            sdram_writedata <= n_sdram_writedata;
        end
    end

endmodule