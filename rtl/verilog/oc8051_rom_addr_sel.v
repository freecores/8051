//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 rom address select                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select rom address              ////
////   (program counter or alu destination)                       ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
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
// ver: 1
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_rom_addr_sel (clk, rst, select, des1, des2, pc, out_addr);
//
// clk          (in)  clock
// rst          (in)  reset
// select       (in)  output select [oc8051_decoder.rom_addr_sel]
// des1, des2   (in)  alu destination input [{oc8051_alu.des1,oc8051_alu.des2}]
// pc           (in)  pc input [oc8051_pc.pc_out]
// out_addr     (out) output address (to program rom) [oc8051_rom.addr]
//


input clk, rst, select;
input [7:0] des1, des2;
input [15:0] pc;
output [15:0] out_addr;


//
// output address is alu destination
// (instructions MOVC)
assign out_addr = select ? {des2, des1} : pc;

endmodule