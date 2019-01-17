	component Total is
		port (
			audio_0_avalon_left_channel_sink_data            : in    std_logic_vector(15 downto 0) := (others => 'X'); -- data
			audio_0_avalon_left_channel_sink_valid           : in    std_logic                     := 'X';             -- valid
			audio_0_avalon_left_channel_sink_ready           : out   std_logic;                                        -- ready
			audio_0_avalon_left_channel_source_ready         : in    std_logic                     := 'X';             -- ready
			audio_0_avalon_left_channel_source_data          : out   std_logic_vector(15 downto 0);                    -- data
			audio_0_avalon_left_channel_source_valid         : out   std_logic;                                        -- valid
			audio_0_avalon_right_channel_sink_data           : in    std_logic_vector(15 downto 0) := (others => 'X'); -- data
			audio_0_avalon_right_channel_sink_valid          : in    std_logic                     := 'X';             -- valid
			audio_0_avalon_right_channel_sink_ready          : out   std_logic;                                        -- ready
			audio_0_avalon_right_channel_source_ready        : in    std_logic                     := 'X';             -- ready
			audio_0_avalon_right_channel_source_data         : out   std_logic_vector(15 downto 0);                    -- data
			audio_0_avalon_right_channel_source_valid        : out   std_logic;                                        -- valid
			audio_0_external_interface_ADCDAT                : in    std_logic                     := 'X';             -- ADCDAT
			audio_0_external_interface_ADCLRCK               : in    std_logic                     := 'X';             -- ADCLRCK
			audio_0_external_interface_BCLK                  : in    std_logic                     := 'X';             -- BCLK
			audio_0_external_interface_DACDAT                : out   std_logic;                                        -- DACDAT
			audio_0_external_interface_DACLRCK               : in    std_logic                     := 'X';             -- DACLRCK
			audio_and_video_config_0_external_interface_SDAT : inout std_logic                     := 'X';             -- SDAT
			audio_and_video_config_0_external_interface_SCLK : out   std_logic;                                        -- SCLK
			audio_pll_0_audio_clk_clk                        : out   std_logic;                                        -- clk
			clk_clk                                          : in    std_logic                     := 'X';             -- clk
			new_sdram_controller_0_s1_address                : in    std_logic_vector(22 downto 0) := (others => 'X'); -- address
			new_sdram_controller_0_s1_byteenable_n           : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable_n
			new_sdram_controller_0_s1_chipselect             : in    std_logic                     := 'X';             -- chipselect
			new_sdram_controller_0_s1_writedata              : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			new_sdram_controller_0_s1_read_n                 : in    std_logic                     := 'X';             -- read_n
			new_sdram_controller_0_s1_write_n                : in    std_logic                     := 'X';             -- write_n
			new_sdram_controller_0_s1_readdata               : out   std_logic_vector(31 downto 0);                    -- readdata
			new_sdram_controller_0_s1_readdatavalid          : out   std_logic;                                        -- readdatavalid
			new_sdram_controller_0_s1_waitrequest            : out   std_logic;                                        -- waitrequest
			new_sdram_controller_0_wire_addr                 : out   std_logic_vector(12 downto 0);                    -- addr
			new_sdram_controller_0_wire_ba                   : out   std_logic_vector(1 downto 0);                     -- ba
			new_sdram_controller_0_wire_cas_n                : out   std_logic;                                        -- cas_n
			new_sdram_controller_0_wire_cke                  : out   std_logic;                                        -- cke
			new_sdram_controller_0_wire_cs_n                 : out   std_logic;                                        -- cs_n
			new_sdram_controller_0_wire_dq                   : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			new_sdram_controller_0_wire_dqm                  : out   std_logic_vector(3 downto 0);                     -- dqm
			new_sdram_controller_0_wire_ras_n                : out   std_logic;                                        -- ras_n
			new_sdram_controller_0_wire_we_n                 : out   std_logic;                                        -- we_n
			reset_reset_n                                    : in    std_logic                     := 'X';             -- reset_n
			sys_sdram_pll_0_sdram_clk_clk                    : out   std_logic                                         -- clk
		);
	end component Total;

	u0 : component Total
		port map (
			audio_0_avalon_left_channel_sink_data            => CONNECTED_TO_audio_0_avalon_left_channel_sink_data,            --            audio_0_avalon_left_channel_sink.data
			audio_0_avalon_left_channel_sink_valid           => CONNECTED_TO_audio_0_avalon_left_channel_sink_valid,           --                                            .valid
			audio_0_avalon_left_channel_sink_ready           => CONNECTED_TO_audio_0_avalon_left_channel_sink_ready,           --                                            .ready
			audio_0_avalon_left_channel_source_ready         => CONNECTED_TO_audio_0_avalon_left_channel_source_ready,         --          audio_0_avalon_left_channel_source.ready
			audio_0_avalon_left_channel_source_data          => CONNECTED_TO_audio_0_avalon_left_channel_source_data,          --                                            .data
			audio_0_avalon_left_channel_source_valid         => CONNECTED_TO_audio_0_avalon_left_channel_source_valid,         --                                            .valid
			audio_0_avalon_right_channel_sink_data           => CONNECTED_TO_audio_0_avalon_right_channel_sink_data,           --           audio_0_avalon_right_channel_sink.data
			audio_0_avalon_right_channel_sink_valid          => CONNECTED_TO_audio_0_avalon_right_channel_sink_valid,          --                                            .valid
			audio_0_avalon_right_channel_sink_ready          => CONNECTED_TO_audio_0_avalon_right_channel_sink_ready,          --                                            .ready
			audio_0_avalon_right_channel_source_ready        => CONNECTED_TO_audio_0_avalon_right_channel_source_ready,        --         audio_0_avalon_right_channel_source.ready
			audio_0_avalon_right_channel_source_data         => CONNECTED_TO_audio_0_avalon_right_channel_source_data,         --                                            .data
			audio_0_avalon_right_channel_source_valid        => CONNECTED_TO_audio_0_avalon_right_channel_source_valid,        --                                            .valid
			audio_0_external_interface_ADCDAT                => CONNECTED_TO_audio_0_external_interface_ADCDAT,                --                  audio_0_external_interface.ADCDAT
			audio_0_external_interface_ADCLRCK               => CONNECTED_TO_audio_0_external_interface_ADCLRCK,               --                                            .ADCLRCK
			audio_0_external_interface_BCLK                  => CONNECTED_TO_audio_0_external_interface_BCLK,                  --                                            .BCLK
			audio_0_external_interface_DACDAT                => CONNECTED_TO_audio_0_external_interface_DACDAT,                --                                            .DACDAT
			audio_0_external_interface_DACLRCK               => CONNECTED_TO_audio_0_external_interface_DACLRCK,               --                                            .DACLRCK
			audio_and_video_config_0_external_interface_SDAT => CONNECTED_TO_audio_and_video_config_0_external_interface_SDAT, -- audio_and_video_config_0_external_interface.SDAT
			audio_and_video_config_0_external_interface_SCLK => CONNECTED_TO_audio_and_video_config_0_external_interface_SCLK, --                                            .SCLK
			audio_pll_0_audio_clk_clk                        => CONNECTED_TO_audio_pll_0_audio_clk_clk,                        --                       audio_pll_0_audio_clk.clk
			clk_clk                                          => CONNECTED_TO_clk_clk,                                          --                                         clk.clk
			new_sdram_controller_0_s1_address                => CONNECTED_TO_new_sdram_controller_0_s1_address,                --                   new_sdram_controller_0_s1.address
			new_sdram_controller_0_s1_byteenable_n           => CONNECTED_TO_new_sdram_controller_0_s1_byteenable_n,           --                                            .byteenable_n
			new_sdram_controller_0_s1_chipselect             => CONNECTED_TO_new_sdram_controller_0_s1_chipselect,             --                                            .chipselect
			new_sdram_controller_0_s1_writedata              => CONNECTED_TO_new_sdram_controller_0_s1_writedata,              --                                            .writedata
			new_sdram_controller_0_s1_read_n                 => CONNECTED_TO_new_sdram_controller_0_s1_read_n,                 --                                            .read_n
			new_sdram_controller_0_s1_write_n                => CONNECTED_TO_new_sdram_controller_0_s1_write_n,                --                                            .write_n
			new_sdram_controller_0_s1_readdata               => CONNECTED_TO_new_sdram_controller_0_s1_readdata,               --                                            .readdata
			new_sdram_controller_0_s1_readdatavalid          => CONNECTED_TO_new_sdram_controller_0_s1_readdatavalid,          --                                            .readdatavalid
			new_sdram_controller_0_s1_waitrequest            => CONNECTED_TO_new_sdram_controller_0_s1_waitrequest,            --                                            .waitrequest
			new_sdram_controller_0_wire_addr                 => CONNECTED_TO_new_sdram_controller_0_wire_addr,                 --                 new_sdram_controller_0_wire.addr
			new_sdram_controller_0_wire_ba                   => CONNECTED_TO_new_sdram_controller_0_wire_ba,                   --                                            .ba
			new_sdram_controller_0_wire_cas_n                => CONNECTED_TO_new_sdram_controller_0_wire_cas_n,                --                                            .cas_n
			new_sdram_controller_0_wire_cke                  => CONNECTED_TO_new_sdram_controller_0_wire_cke,                  --                                            .cke
			new_sdram_controller_0_wire_cs_n                 => CONNECTED_TO_new_sdram_controller_0_wire_cs_n,                 --                                            .cs_n
			new_sdram_controller_0_wire_dq                   => CONNECTED_TO_new_sdram_controller_0_wire_dq,                   --                                            .dq
			new_sdram_controller_0_wire_dqm                  => CONNECTED_TO_new_sdram_controller_0_wire_dqm,                  --                                            .dqm
			new_sdram_controller_0_wire_ras_n                => CONNECTED_TO_new_sdram_controller_0_wire_ras_n,                --                                            .ras_n
			new_sdram_controller_0_wire_we_n                 => CONNECTED_TO_new_sdram_controller_0_wire_we_n,                 --                                            .we_n
			reset_reset_n                                    => CONNECTED_TO_reset_reset_n,                                    --                                       reset.reset_n
			sys_sdram_pll_0_sdram_clk_clk                    => CONNECTED_TO_sys_sdram_pll_0_sdram_clk_clk                     --                   sys_sdram_pll_0_sdram_clk.clk
		);

