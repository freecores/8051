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
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_ext_addr_sel (clk, rst, sel, dptr_hi, dptr_lo, ri, addr_out, wr);
//
// clk  clock
// sel          (in)  select sourses [oc8051_decoder.ext_addr_sel -r]
// write        (in)  write to external ram [oc8051_decoder.write_x]
// dptr_hi      (in)  data pointer high bits [oc8051_dptr.data_hi]
// dptr_lo      (in)  data pointer low bits [oc8051_dptr.data_lo]
// ri           (in)  indirect addressing [oc8051_indi_addr.data_out]
// addr_out     (out) external address [pin]
//


input sel, clk, rst, wr;
input [7:0] dptr_hi, dptr_lo, ri;

output [15:0] addr_out;
reg [15:0] addr_out_dr, addr_out_ri;
wire [15:0] addr_out_d;
reg wr_r, sel_r;

assign addr_out_d = wr_r ? {dptr_hi, dptr_lo} : addr_out_d;
//assign addr_in = sel_r ? {8'h00, ri} : {dptr_hi, dptr_lo};

assign addr_out = sel_r ? addr_out_ri : addr_out_d;

always @(posedge clk or posedge rst)
  if (rst)
    addr_out_dr <= #1 16'h0000;
  else if (wr_r)
    addr_out_dr <= #1 {dptr_hi, dptr_lo};


always @(posedge clk or posedge rst)
  if (rst) begin
    addr_out_ri <= #1 16'h0000;
    sel_r <= #1 1'b0;
  end else if (wr) begin
    addr_out_ri <= #1 {8'h00, ri};
    sel_r <= #1 sel;
  end


always @(posedge clk or posedge rst)
  if (rst) begin
    wr_r <= #1 1'b0;
  end else begin
    wr_r <= #1 wr;
  end


endmodule
