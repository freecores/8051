//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores acccumulator                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   accumulaor register for 8051 core                          ////
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


module oc8051_acc (clk, rst, bit_in, data_in, data2_in, wr, wr_bit, wad2, wr_addr, rd_addr,
		data_out, bit_out, p);
// clk          (in)  clock
// rst          (in)  reset
// bit_in       (in)  bit input - used in case of writing bits to acc (bit adddressable memory space - alu carry) [oc8051_alu.desCy]
// data_in      (in)  data input - used to write to acc (from alu destiantion 1) [oc8051_alu.des1]
// data2_in     (in)  data 2 input - write to acc, from alu detination 2 - instuctions mul and div [oc8051_alu.des2]
// wr           (in)  write - actine high [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable - actine high [oc8051_decoder.bit_addr -r]
// wad2         (in)  write data 2 [oc8051_decoder.wad2 -r]
// wr_addr      (in)  write address (if is addres of acc and white high must be written to acc) [oc8051_ram_wr_sel.out]
// data_out     (out) data output [oc8051_alu_src1_sel.acc oc8051_alu_src2_sel.acc oc8051_comp.acc oc8051_ram_sel.acc]
// p            (out) parity [oc8051_psw.p]


input clk, rst, wr, wr_bit, wad2, bit_in;
input [2:0] rd_addr;
input [7:0] wr_addr, data_in, data2_in;

output p, bit_out;
output [7:0] data_out;

reg [7:0] data_out;
reg bit_out;

//
//calculates parity
assign p = ^data_out;

//
//writing to acc
//must check if write high and correct address
always @(posedge clk or posedge rst)
begin
  if (rst)
    data_out <= #1 `OC8051_RST_ACC;
  else if (wad2)
    data_out <= #1 data2_in;
  else
    case ({wr, wr_bit})
      2'b10: begin
        if (wr_addr==`OC8051_SFR_ACC)
          data_out <= #1 data_in;
      end
      2'b11: begin
        if (wr_addr[7:3]==`OC8051_SFR_B_ACC)
          data_out[wr_addr[2:0]] <= #1 bit_in;
      end
    endcase
end

always  @(posedge clk)
begin
  bit_out <= #1 data_out[rd_addr];
end



endmodule

