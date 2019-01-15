`ifndef _ACAPPELLA_DEFINE_SV_
`define _ACAPPELLA_DEFINE_SV_

// TODO
// Divide the SDRAM into reasonable chunks



parameter bit [22:0] CHUNK [4:0] = '{23'h100000, 23'h0C0000, 23'h080000, 23'h040000, 23'h000000};

parameter control_IDLE  = 4'd0;
parameter control_REC   = 4'd1;
parameter control_PLAY  = 4'd2;
parameter control_MIX   = 4'd3;
parameter control_PITCH = 4'd4;

`endif