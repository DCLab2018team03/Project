// DE2_115_TOP
// Revision History :
// --------------------------------------------------------------------
// Shiva Rajagopal, Cornell University, Dec 2015
// --------------------------------------------------------------------

module DE2_115 (
    // Clock Inputs
    input         CLOCK_50,    // 50MHz Input 1
    input         CLOCK2_50,   // 50MHz Input 2
    input         CLOCK3_50,   // 50MHz Input 3
    output        SMA_CLKOUT,  // External Clock Output
    input         SMA_CLKIN,   // External Clock Input

    // Push Button
    input  [3:0]  KEY,         // Pushbutton[3:0]

    // DPDT Switch
    input  [17:0] SW,          // Toggle Switch[17:0]

    // 7-SEG Display
    output logic [6:0]  HEX0,        // Seven Segment Digit 0
    output logic [6:0]  HEX1,        // Seven Segment Digit 1
    output logic [6:0]  HEX2,        // Seven Segment Digit 2
    output logic [6:0]  HEX3,        // Seven Segment Digit 3
    output logic [6:0]  HEX4,        // Seven Segment Digit 4
    output logic [6:0]  HEX5,        // Seven Segment Digit 5
    output logic [6:0]  HEX6,        // Seven Segment Digit 6
    output logic [6:0]  HEX7,        // Seven Segment Digit 7

    // LED
    output [8:0]  LEDG,        // LED Green[8:0]
    output [17:0] LEDR,        // LED Red[17:0]

    // UART
    output        UART_TXD,    // UART Transmitter
    input         UART_RXD,    // UART Receiver
    output        UART_CTS,    // UART Clear to Send
    input         UART_RTS,    // UART Request to Send

    // IRDA
    input         IRDA_RXD,    // IRDA Receiver

    // SDRAM Interface
    inout  [31:0] DRAM_DQ,     // SDRAM Data bus 32 Bits
    output [12:0] DRAM_ADDR,   // SDRAM Address bus 13 Bits
    output [1:0]  DRAM_BA,     // SDRAM Bank Address
    output [3:0]  DRAM_DQM,    // SDRAM Byte Data Mask 
    output        DRAM_RAS_N,  // SDRAM Row Address Strobe
    output        DRAM_CAS_N,  // SDRAM Column Address Strobe
    output        DRAM_CKE,    // SDRAM Clock Enable
    output        DRAM_CLK,    // SDRAM Clock
    output        DRAM_WE_N,   // SDRAM Write Enable
    output        DRAM_CS_N,   // SDRAM Chip Select

    // Flash Interface
    inout  [7:0]  FL_DQ,       // FLASH Data bus 8 Bits
    output [22:0] FL_ADDR,     // FLASH Address bus 23 Bits
    output        FL_WE_N,     // FLASH Write Enable
    output        FL_WP_N,     // FLASH Write Protect / Programming Acceleration
    output        FL_RST_N,    // FLASH Reset
    output        FL_OE_N,     // FLASH Output Enable
    output        FL_CE_N,     // FLASH Chip Enable
    input         FL_RY,       // FLASH Ready/Busy output

    // SRAM Interface
    inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
    output [19:0] SRAM_ADDR,   // SRAM Address bus 20 Bits
    output        SRAM_OE_N,   // SRAM Output Enable
    output        SRAM_WE_N,   // SRAM Write Enable
    output        SRAM_CE_N,   // SRAM Chip Enable
    output        SRAM_UB_N,   // SRAM High-byte Data Mask 
    output        SRAM_LB_N,   // SRAM Low-byte Data Mask 

    // ISP1362 Interface
    inout  [15:0] OTG_DATA,    // ISP1362 Data bus 16 Bits
    output [1:0]  OTG_ADDR,    // ISP1362 Address 2 Bits
    output        OTG_CS_N,    // ISP1362 Chip Select
    output        OTG_RD_N,    // ISP1362 Write
    output        OTG_WR_N,    // ISP1362 Read
    output        OTG_RST_N,   // ISP1362 Reset
    input         OTG_INT,     // ISP1362 Interrupts
    inout         OTG_FSPEED,  // USB Full Speed, 0 = Enable, Z = Disable
    inout         OTG_LSPEED,  // USB Low Speed,  0 = Enable, Z = Disable
    input  [1:0]  OTG_DREQ,    // ISP1362 DMA Request
    output [1:0]  OTG_DACK_N,  // ISP1362 DMA Acknowledge

    // LCD Module 16X2
    inout  [7:0]  LCD_DATA,    // LCD Data bus 8 bits
    output        LCD_ON,      // LCD Power ON/OFF
    output        LCD_BLON,    // LCD Back Light ON/OFF
    output        LCD_RW,      // LCD Read/Write Select, 0 = Write, 1 = Read
    output        LCD_EN,      // LCD Enable
    output        LCD_RS,      // LCD Command/Data Select, 0 = Command, 1 = Data

    // SD Card Interface
    inout  [3:0]  SD_DAT,      // SD Card Data
    inout         SD_CMD,      // SD Card Command Line
    output        SD_CLK,      // SD Card Clock
    input         SD_WP_N,     // SD Write Protect

    // EEPROM Interface
    output        EEP_I2C_SCLK, // EEPROM Clock
    inout         EEP_I2C_SDAT, // EEPROM Data

    // PS2
    inout         PS2_DAT,     // PS2 Data
    inout         PS2_CLK,     // PS2 Clock
    inout         PS2_DAT2,    // PS2 Data 2 (use for 2 devices and y-cable)
    inout         PS2_CLK2,    // PS2 Clock 2 (use for 2 devices and y-cable)

    // I2C  
    inout         I2C_SDAT,    // I2C Data
    output        I2C_SCLK,    // I2C Clock

    // Audio CODEC
    inout         AUD_ADCLRCK, // Audio CODEC ADC LR Clock
    input         AUD_ADCDAT,  // Audio CODEC ADC Data
    inout         AUD_DACLRCK, // Audio CODEC DAC LR Clock
    output        AUD_DACDAT,  // Audio CODEC DAC Data
    inout         AUD_BCLK,    // Audio CODEC Bit-Stream Clock
    output        AUD_XCK,     // Audio CODEC Chip Clock

    // Ethernet Interface (88E1111)
    input         ENETCLK_25,    // Ethernet clock source

    output        ENET0_GTX_CLK, // GMII Transmit Clock 1
    input         ENET0_INT_N,   // Interrupt open drain output 1
    input         ENET0_LINK100, // Parallel LED output of 100BASE-TX link 1
    output        ENET0_MDC,     // Management data clock ref 1
    inout         ENET0_MDIO,    // Management data 1
    output        ENET0_RST_N,   // Hardware Reset Signal 1
    input         ENET0_RX_CLK,  // GMII and MII receive clock 1
    input         ENET0_RX_COL,  // GMII and MII collision 1
    input         ENET0_RX_CRS,  // GMII and MII carrier sense 1
    input   [3:0] ENET0_RX_DATA, // GMII and MII receive data 1
    input         ENET0_RX_DV,   // GMII and MII receive data valid 1
    input         ENET0_RX_ER,   // GMII and MII receive error 1
    input         ENET0_TX_CLK,  // MII Transmit clock 1
    output  [3:0] ENET0_TX_DATA, // MII Transmit data 1
    output        ENET0_TX_EN,   // GMII and MII transmit enable 1
    output        ENET0_TX_ER,   // GMII and MII transmit error 1

    output        ENET1_GTX_CLK, // GMII Transmit Clock 1
    input         ENET1_INT_N,   // Interrupt open drain output 1
    input         ENET1_LINK100, // Parallel LED output of 100BASE-TX link 1
    output        ENET1_MDC,     // Management data clock ref 1
    inout         ENET1_MDIO,    // Management data 1
    output        ENET1_RST_N,   // Hardware Reset Signal 1
    input         ENET1_RX_CLK,  // GMII and MII receive clock 1
    input         ENET1_RX_COL,  // GMII and MII collision 1
    input         ENET1_RX_CRS,  // GMII and MII carrier sense 1
    input   [3:0] ENET1_RX_DATA, // GMII and MII receive data 1
    input         ENET1_RX_DV,   // GMII and MII receive data valid 1
    input         ENET1_RX_ER,   // GMII and MII receive error 1
    input         ENET1_TX_CLK,  // MII Transmit clock 1
    output  [3:0] ENET1_TX_DATA, // MII Transmit data 1
    output        ENET1_TX_EN,   // GMII and MII transmit enable 1
    output        ENET1_TX_ER,   // GMII and MII transmit error 1

    // Expansion Header
    inout   [6:0] EX_IO,       // 14-pin GPIO Header
    inout  [35:0] GPIO,        // 40-pin Expansion header

    // TV Decoder
    input  [8:0]  TD_DATA,     // TV Decoder Data
    input         TD_CLK27,    // TV Decoder Clock Input
    input         TD_HS,       // TV Decoder H_SYNC
    input         TD_VS,       // TV Decoder V_SYNC
    output        TD_RESET_N,  // TV Decoder Reset

    // VGA
    output        VGA_CLK,     // VGA Clock
    output        VGA_HS,      // VGA H_SYNC
    output        VGA_VS,      // VGA V_SYNC
    output        VGA_BLANK_N, // VGA BLANK
    output        VGA_SYNC_N,  // VGA SYNC
    output [7:0]  VGA_R,       // VGA Red[9:0]
    output [7:0]  VGA_G,       // VGA Green[9:0]
    output [7:0]  VGA_B       // VGA Blue[9:0]
);
    /*assign SRAM_CE_N = 1'b0;
    assign SRAM_OE_N = 1'b0;
    assign SRAM_LB_N = 1'b0;
    assign SRAM_UB_N = 1'b0;
    assign HEX0 = 7'h7F;
    assign HEX1 = 7'h7F;
    assign HEX2 = 7'h7F;
    assign HEX3 = 7'h7F;
    assign HEX4 = 7'h7F;
    assign HEX5 = 7'h7F;
    assign HEX6 = 7'h7F;
    assign HEX7 = 7'h7F;
    */
    ///////////////////////////////////////
    // Main program
    ///////////////////////////////////////

     // Main Module
    wire rst_main;
    assign rst_main = SW[17];
    wire            w_mem_read;
    wire            w_mem_write;
    wire    [31:0]  w_mem_addr;
    wire    [15:0]  w_mem_data;
    wire            w_mem_done;
	// wire between I2S and AudioCore
	wire            w_adc_left_ready;
	wire    [15:0]  w_adc_left_data;
	wire            w_adc_left_valid;
	wire            w_dac_left_ready;
	wire    [15:0]  w_dac_left_data;
	wire            w_dac_left_valid;
	wire            w_adc_right_ready;
	wire    [15:0]  w_adc_right_data;
	wire            w_adc_right_valid;
	wire            w_dac_right_ready;
	wire    [15:0]  w_dac_right_data;
	wire            w_dac_right_valid;
	wire    [15:0]  w_input_event;
    logic           w_stop_signal, n_stop_signal;

    wire    [22:0]  new_sdram_controller_0_s1_address;
    wire    [3:0]   new_sdram_controller_0_s1_byteenable_n;
    wire            new_sdram_controller_0_s1_chipselect;
    wire    [31:0]  new_sdram_controller_0_s1_writedata;
    wire            new_sdram_controller_0_s1_read_n;
    wire            new_sdram_controller_0_s1_write_n;
    wire    [31:0]  new_sdram_controller_0_s1_readdata;
    wire            new_sdram_controller_0_s1_readdatavalid;
    wire            new_sdram_controller_0_s1_waitrequest;
    logic [3:0] KEY_debounced;

    logic [11:0] button_pushed;

    Total total(
        .audio_0_external_interface_ADCDAT(AUD_ADCDAT),   // audio_0_external_interface.ADCDAT
		.audio_0_external_interface_ADCLRCK(AUD_ADCLRCK), //                           .ADCLRCK
		.audio_0_external_interface_BCLK(AUD_BCLK),       //                           .BCLK
		.audio_0_external_interface_DACDAT(AUD_DACDAT),   //                           .DACDAT
		.audio_0_external_interface_DACLRCK(AUD_DACLRCK), //                           .DACLRCK
        .audio_and_video_config_0_external_interface_SDAT(I2C_SDAT), // audio_and_video_config_0_external_interface.SDAT
		.audio_and_video_config_0_external_interface_SCLK(I2C_SCLK), //                                            .SCLK
		.clk_clk(CLOCK_50),                                          //                                          clk.clk
		.reset_reset_n(~rst_main),                                   //                                    reset.reset_n
        .audio_0_avalon_left_channel_sink_data  (w_dac_left_data),                                   //  avalon_left_channel_source.ready
		.audio_0_avalon_left_channel_sink_valid   (w_dac_left_valid),                                   //                            .data
		.audio_0_avalon_left_channel_sink_ready  (w_dac_left_ready),                                   //                            .valid
		.audio_0_avalon_left_channel_source_ready (w_adc_left_ready),                                   // avalon_right_channel_source.ready
		.audio_0_avalon_left_channel_source_data  (w_adc_left_data),                                   //                            .data
		.audio_0_avalon_left_channel_source_valid (w_adc_left_valid),                                   //                            .valid
		.audio_0_avalon_right_channel_sink_data     (w_dac_right_data),                                   //    avalon_left_channel_sink.data
		.audio_0_avalon_right_channel_sink_valid    (w_dac_right_valid),                                   //                            .valid
		.audio_0_avalon_right_channel_sink_ready    (w_dac_right_ready),                                   //                            .ready
		.audio_0_avalon_right_channel_source_ready    (w_adc_right_ready),                                   //   avalon_right_channel_sink.data
		.audio_0_avalon_right_channel_source_data   (w_adc_right_data),                                   //                            .valid
		.audio_0_avalon_right_channel_source_valid   (w_adc_right_valid),                                 //                            .ready
        .audio_pll_0_audio_clk_clk      (AUD_XCK),
        .new_sdram_controller_0_s1_address         (new_sdram_controller_0_s1_address),
        .new_sdram_controller_0_s1_byteenable_n    (new_sdram_controller_0_s1_byteenable_n),
        .new_sdram_controller_0_s1_chipselect      (new_sdram_controller_0_s1_chipselect),
        .new_sdram_controller_0_s1_writedata       (new_sdram_controller_0_s1_writedata),
        .new_sdram_controller_0_s1_read_n          (new_sdram_controller_0_s1_read_n),
        .new_sdram_controller_0_s1_write_n         (new_sdram_controller_0_s1_write_n),
        .new_sdram_controller_0_s1_readdata        (new_sdram_controller_0_s1_readdata),
        .new_sdram_controller_0_s1_readdatavalid   (new_sdram_controller_0_s1_readdatavalid),
        .new_sdram_controller_0_s1_waitrequest     (new_sdram_controller_0_s1_waitrequest),
        .new_sdram_controller_0_wire_addr          (DRAM_ADDR),
        .new_sdram_controller_0_wire_ba            (DRAM_BA),
        .new_sdram_controller_0_wire_cas_n         (DRAM_CAS_N),
        .new_sdram_controller_0_wire_cke           (DRAM_CKE),
        .new_sdram_controller_0_wire_cs_n          (DRAM_CS_N),
        .new_sdram_controller_0_wire_dq            (DRAM_DQ),
        .new_sdram_controller_0_wire_dqm           (DRAM_DQM),
        .new_sdram_controller_0_wire_ras_n         (DRAM_RAS_N),
        .new_sdram_controller_0_wire_we_n          (DRAM_WE_N),
        .sys_sdram_pll_0_sdram_clk_clk             (DRAM_CLK)
    );

	AcappellaCore acappellacore(
		.i_clk(CLOCK_50),
		.i_rst(rst_main),
		// Input
		.KEY(KEY_debounced),
        .SW(SW),
        .LEDG(LEDG),
        // avalon_audio_slave
        // avalon_left_channel_source
		.from_adc_left_channel_ready(w_adc_left_ready),
        .from_adc_left_channel_data(w_adc_left_data),
        .from_adc_left_channel_valid(w_adc_left_valid),
        // avalon_right_channel_source
        .from_adc_right_channel_ready(w_adc_right_ready),
        .from_adc_right_channel_data(w_adc_right_data),
        .from_adc_right_channel_valid(w_adc_right_valid),
        // avalon_left_channel_sink
        .to_dac_left_channel_data(w_dac_left_data),
        .to_dac_left_channel_valid(w_dac_left_valid),
        .to_dac_left_channel_ready(w_dac_left_ready),
        // avalon_left_channel_sink
        .to_dac_right_channel_data(w_dac_right_data),
        .to_dac_right_channel_valid(w_dac_right_valid),
        .to_dac_right_channel_ready(w_dac_right_ready),
        // SDRAM
        .new_sdram_controller_0_s1_address         (new_sdram_controller_0_s1_address),
        .new_sdram_controller_0_s1_byteenable_n    (new_sdram_controller_0_s1_byteenable_n),
        .new_sdram_controller_0_s1_chipselect      (new_sdram_controller_0_s1_chipselect),
        .new_sdram_controller_0_s1_writedata       (new_sdram_controller_0_s1_writedata),
        .new_sdram_controller_0_s1_read_n          (new_sdram_controller_0_s1_read_n),
        .new_sdram_controller_0_s1_write_n         (new_sdram_controller_0_s1_write_n),
        .new_sdram_controller_0_s1_readdata        (new_sdram_controller_0_s1_readdata),
        .new_sdram_controller_0_s1_readdatavalid   (new_sdram_controller_0_s1_readdatavalid),
        .new_sdram_controller_0_s1_waitrequest     (new_sdram_controller_0_s1_waitrequest),
        // SRAM
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_OE_N(SRAM_OE_N),
        .SRAM_LB_N(SRAM_LB_N),
        .SRAM_UB_N(SRAM_UB_N),
        // GPIO
        .button_pushed(button_pushed)
	);
	/*
    GPIO gpio(
		.i_clk(CLOCK_50),
		.i_rst(rst_main),
		.gpio(GPIO[19:0]),
		.button_pushed(button_pushed)
	);*/
	//assign GPIO[11:0] = rst_main ? 12'b0 : 12'bz;
	assign LEDR[17:0] = ~GPIO[17:0];
    Debounce deb12(.i_in(KEY[0]), .i_clk(CLOCK_50), .o_neg(KEY_debounced[0]));
    Debounce deb13(.i_in(KEY[1]), .i_clk(CLOCK_50), .o_neg(KEY_debounced[1]));
    Debounce deb14(.i_in(KEY[2]), .i_clk(CLOCK_50), .o_neg(KEY_debounced[2]));
    Debounce deb15(.i_in(KEY[3]), .i_clk(CLOCK_50), .o_neg(KEY_debounced[3]));
    
	Debounce deb0(.i_in(GPIO[0]), .i_clk(CLOCK_50), .o_neg(button_pushed[0]));
    Debounce deb1(.i_in(GPIO[1]), .i_clk(CLOCK_50), .o_neg(button_pushed[1]));
    Debounce deb2(.i_in(GPIO[2]), .i_clk(CLOCK_50), .o_neg(button_pushed[2]));
    Debounce deb3(.i_in(GPIO[3]), .i_clk(CLOCK_50), .o_neg(button_pushed[3]));
    Debounce deb4(.i_in(GPIO[4]), .i_clk(CLOCK_50), .o_neg(button_pushed[4]));
    Debounce deb5(.i_in(GPIO[5]), .i_clk(CLOCK_50), .o_neg(button_pushed[5]));
    Debounce deb6(.i_in(GPIO[6]), .i_clk(CLOCK_50), .o_neg(button_pushed[6]));
    Debounce deb7(.i_in(GPIO[7]), .i_clk(CLOCK_50), .o_neg(button_pushed[7]));
    Debounce deb8(.i_in(GPIO[8]), .i_clk(CLOCK_50), .o_neg(button_pushed[8]));
    Debounce deb9(.i_in(GPIO[9]), .i_clk(CLOCK_50), .o_neg(button_pushed[9]));
    Debounce deb10(.i_in(GPIO[10]), .i_clk(CLOCK_50), .o_neg(button_pushed[10]));
    Debounce deb11(.i_in(GPIO[11]), .i_clk(CLOCK_50), .o_neg(button_pushed[11]));
	 
endmodule
