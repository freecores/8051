//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 external address select                                ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we define external address         ////
////   (dptr or Ri)                                               ////
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

`include "oc8051_defines.v"


module oc8051_ext_addr_sel (clk, select, write, dptr_hi, dptr_lo, ri, addr_out);
//
// clk  clock
// select       (in)  select sourses [oc8051_decoder.ext_addr_sel -r]
// write        (in)  write to external ram [oc8051_decoder.write_x]
// dptr_hi      (in)  data pointer high bits [oc8051_dptr.data_hi]
// dptr_lo      (in)  data pointer low bits [oc8051_dptr.data_lo]
// ri           (in)  indirect addressing [oc8051_indi_addr.data_out]
// addr_out     (out) external addres [pin]
//


input select, write, clk;
input [7:0] dptr_hi, dptr_lo, ri;

output [15:0] addr_out;

reg state;
reg [15:0] buff;
wire [15:0] tmp;

assign tmp = select ? {8'h00, ri} : {dptr_hi, dptr_lo};
assign addr_out = state ? buff : tmp;

always @(posedge clk)
  if (select)
    buff <= #1 {8'h00, ri};
  else buff <= #1 {dptr_hi, dptr_lo};

always @(posedge clk)
  if (write)
    state <= #1 1'b1;
  else state <= #1 1'b0;


endmodule
