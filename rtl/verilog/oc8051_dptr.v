//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data pointer                                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function register: data pointer               ////
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


module oc8051_dptr(clk, rst, addr, data_in, data2_in, wr, wd2, wr_bit, data_hi, data_lo);
//
// clk          (in)  clock
// rst          (in)  reset
// addr         (in)  write address input [oc8051_ram_wr_sel.out]
// data_in      (in)  destination 1 from alu [oc8051_alu.des1]
// data2_in     (in)  destination 2 from alu [oc8051_alu.des2]
// wr           (in)  write to ram [oc8051_decoder.wr -r]
// wd2          (in)  write from destination 2 [oc8051_decoder.ram_wr_sel -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// data_hi      (out) output (high bits) [oc8051_alu_src3_sel.dptr, oc8051_ext_addr_sel.dptr_hi, oc8051_ram_sel.dptr_hi]
// data_lo      (out) output (low bits) [oc8051_ext_addr_sel.dptr_lo]
//


input clk, rst, wr, wr_bit;
input [2:0] wd2;
input [7:0] addr, data_in, data2_in;

output [7:0] data_hi, data_lo;

reg [7:0] data_hi, data_lo;

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    data_hi <= #1 `OC8051_RST_DPH;
    data_lo <= #1 `OC8051_RST_DPL;
  end else if (wd2==`OC8051_RWS_DPTR) begin
//
//write from destination 2 and 1
    data_hi <= #1 data2_in;
    data_lo <= #1 data_in;
  end else if ((addr==`OC8051_SFR_DPTR_HI) & (wr) & !(wr_bit))
//
//case of writing to dptr
    data_hi <= #1 data_in;
  else if ((addr==`OC8051_SFR_DPTR_LO) & (wr) & !(wr_bit))
    data_lo <= #1 data_in;
end

endmodule

