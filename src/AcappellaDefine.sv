`ifndef _ACAPPELLA_DEFINE_SV_
`define _ACAPPELLA_DEFINE_SV_

// TODO
// Divide the SDRAM into reasonable chunks


// Half is 23'h400000
parameter bit [22:0] CHUNK [15:0] = '{23'h5C0000, 23'h380000, 23'h340000, 23'h300000, 23'h2C0000, 23'h280000, 23'h240000, 23'h200000, 23'h1C0000, 23'h180000, 23'h140000, 23'h100000, 23'h0C0000, 23'h080000, 23'h040000, 23'h000000};
/*
mapping to control panel:
0:    00000000
1:    00200000
2:    00400000
3:    00600000
4:    00800000
5:    00A00000
6:    00C00000
7:    00E00000
8:    01000000
9:    01200000
10:   01400000
11:   01600000
12:   01800000
13:   01A00000
14:   01C00000
15:   02E00000
end:  04000000 
*/
parameter control_IDLE  = 4'd0;
parameter control_REC   = 4'd1;
parameter control_PLAY  = 4'd2;
parameter control_MIX   = 4'd3;
parameter control_PITCH = 4'd4;

`endif