//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 fpga top module                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   fpga top module                                            ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_fpga_top (clk, rst, int1, int2, dispout, p0_out, p1_out, p2_out, p3_out, data_out, ext_addr, rom_addr, 
                      rxd, txd, t0, t1);

input clk, rst, int1, int2, rxd, t0, t1;
output txd;
output [13:0] dispout;
output [7:0] p0_out, p1_out, p2_out, p3_out, data_out;
output [15:0] ext_addr, rom_addr;



wire write, stb_o, cyc_o;
wire [7:0] data_out, op1, op2, op3;
wire nrst;

assign nrst = ~rst;

assign op1 = 8'h00;
assign op2 = 8'h00;
assign op3 = 8'h00;

oc8051_top oc8051_top_1(.rst(nrst), .clk(clk), .int0(int1), .int1(int2), .ea(1'b1), .rom_addr(rom_addr), .dat_i(8'h00), .dat_o(data_out),
         .op1(op1), .op2(op2), .op3(op3), .adr_o(ext_addr), .we_o(write), .ack_i(1'b1), .stb_o(stb_o), .cyc_o(cyc_o),
         .p0_in(8'hb0), .p1_in(8'hb1), .p2_in(8'hb2), .p3_in(8'hb3), .p0_out(p0_out),
         .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out), .rxd(rxd), .txd(txd), .t0(t0), .t1(t1));


  disp disp1(.in(p0_out), .out(dispout));

endmodule
