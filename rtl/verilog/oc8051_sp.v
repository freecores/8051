//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 stack pointer                                          ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function register: stack pointer.             ////
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



module oc8051_sp (clk, rst, ram_rd_sel, ram_wr_sel, wr_addr, wr, wr_bit, data_in, data_out);
//
// clk          (in)  clock
// rst          (in)  reset
// ram_rd_sel   (in)  ram read select, used tu calculate next value [oc8051_decoder.ram_rd_sel]
// ram_wr_sel   (in)  ram write select, used tu calculate next value [oc8051_decoder.ram_wr_sel -r]
// wr           (in)  write [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// data_in      (in)  data input [oc8051_alu.des1]
// wr_addr      (in)  write address (if is addres of sp and white high must be written to sp)  [oc8051_ram_wr_sel.out]
// data_out     (out) data output [oc8051_ram_rd_sel.sp, oc8051_ram_rd_sel oc8051_ram_wr_sel1.sp, oc8051_ram_sel.sp]
//


input clk, rst, wr, wr_bit;
input [1:0] ram_rd_sel;
input [2:0] ram_wr_sel;
input [7:0] data_in, wr_addr;
output [7:0] data_out;

reg [7:0] data_out;
reg [7:0] temp;
reg pop, write;
wire [7:0] temp1;

assign temp1 = write ? data_in : temp;

always @(wr_addr or wr or wr_bit)
begin
  if ((wr_addr==`OC8051_SFR_SP) & (wr) & !(wr_bit))
    write = 1'b1;
  else
    write = 1'b0;
end

always @(posedge clk or posedge rst)
begin
  if (rst)
    temp <= #1 `OC8051_RST_SP;
  else
    temp <= #1 data_out;
end

always @(temp1 or ram_wr_sel or pop or write)
begin
//
// push
  if (ram_wr_sel==`OC8051_RWS_SP) data_out = temp1+8'h01;
  else if (write)
    data_out = temp1;
  else data_out = temp1 - pop;

end

always @(posedge clk or posedge rst)
begin
  if (rst)
    pop <= #1 1'b0;
  else if (ram_rd_sel==`OC8051_RRS_SP) pop <= #1 1'b1;
  else pop <= #1 1'b0;
end


endmodule