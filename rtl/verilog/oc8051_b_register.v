//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores b register                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   b register for 8051 core                                   ////
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
// ver: 1
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_b_register (clk, rst, bit_in, bit_out, data_in, wr, wr_bit, wr_addr, rd_addr, data_out);
//
// clk          (in)  clock
// rst          (in)  reset
// bit_in       (in)  bit input - used in case of writing bits to b register (bit adddressable memory space - alu carry) [oc8051_alu.desCy]
// data_in      (in)  data input - used to write to b register [oc8051_alu.des1]
// wr           (in)  write - actine high [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable - actine high [oc8051_decoder.bit_addr -r]
// wr_addr      (in)  write address [oc8051_ram_wr_sel.out]
// data_out     (out) data output [oc8051_ram_sel.b_reg]
//


input clk, rst, wr, wr_bit, bit_in;
input [2:0] rd_addr;
input [7:0] wr_addr, data_in;

output bit_out;
output [7:0] data_out;

reg bit_out;
reg [7:0] data_out;

//
//writing to b
//must check if write high and correct address
always @(posedge clk or posedge rst)
begin
  if (rst)
    data_out <= #1 `OC8051_RST_B;
  else
    case ({wr, wr_bit})
      2'b10: begin
        if (wr_addr==`OC8051_SFR_B)
          data_out <= #1 data_in;
      end
      2'b11: begin
        if (wr_addr[7:3]==`OC8051_SFR_B_B)
          data_out[wr_addr[2:0]] <= #1 bit_in;
      end
    endcase
end

always  @(posedge clk)
begin
  bit_out <= #1 data_out[rd_addr];
end

endmodule
