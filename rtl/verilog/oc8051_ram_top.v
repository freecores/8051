//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data ram                                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   data ram                                                   ////
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


module oc8051_ram_top (clk, rst, rd_addr, rd_data, wr_addr, bit_addr, wr_data, wr, bit_data_in, bit_data_out);
//
// clk          (in)  clock
// rd_addr      (in)  read addres [oc8051_ram_rd_sel.out]
// rd_data      (out) read data [oc8051_ram_sel.in_ram]
// wr_addr      (in)  write addres [oc8051_ram_wr_sel.out]
// bit_addr     (in)  bit addresable instruction [oc8051_decoder.bit_addr -r]
// wr_data      (in)  write data [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// bit_data_in  (in)  bit data input [oc8051_alu.desCy]
// bit_data_out (out)  bit data output [oc8051_ram_sel.bit_in]
//

input clk, wr, bit_addr, bit_data_in, rst;
input [7:0] rd_addr, wr_addr, wr_data;
output bit_data_out;
output [7:0] rd_data;


// rd_addr_m    read address modified
// wr_addr_m    write address modified
// wr_data_m    write data modified
reg [7:0] rd_addr_m, wr_addr_m, wr_data_m;

// bit_addr_r   bit addresable instruction (registerd)
reg bit_addr_r;
reg [2:0] bit_select;

assign bit_data_out = rd_data[bit_select];



oc8051_ram oc8051_ram1(.clk(clk), .rd_addr(rd_addr_m), .rd_data(rd_data), .wr_addr(wr_addr_m),
         .wr_data(wr_data_m), .wr(wr));


always @(posedge clk)
  bit_addr_r <= #1 bit_addr;

always @(rd_addr or bit_addr)
begin
  case ({bit_addr, rd_addr[7]})
    2'b10: rd_addr_m = {4'b0010, rd_addr[6:3]};
    2'b11: rd_addr_m = {1'b1, rd_addr[6:3], 3'b000};
    default: rd_addr_m = rd_addr;
  endcase
end

always @(posedge clk)
  bit_select <= #1 rd_addr[2:0];

always @(wr_addr or bit_addr_r)
begin
  casex ({bit_addr_r, wr_addr[7]})
    2'b10: wr_addr_m = {4'b0010, wr_addr[6:3]};
    2'b11: wr_addr_m = {1'b1, wr_addr[6:3], 3'b000};
    default: wr_addr_m = wr_addr;
  endcase
end

always @(rd_data or bit_select or bit_data_in or wr_data or bit_addr_r)
begin
  if (bit_addr_r) begin
    case (bit_select)
      3'b000: wr_data_m = {rd_data[7:1], bit_data_in};
      3'b001: wr_data_m = {rd_data[7:2], bit_data_in, rd_data[0]};
      3'b010: wr_data_m = {rd_data[7:3], bit_data_in, rd_data[1:0]};
      3'b011: wr_data_m = {rd_data[7:4], bit_data_in, rd_data[2:0]};
      3'b100: wr_data_m = {rd_data[7:5], bit_data_in, rd_data[3:0]};
      3'b101: wr_data_m = {rd_data[7:6], bit_data_in, rd_data[4:0]};
      3'b110: wr_data_m = {rd_data[7], bit_data_in, rd_data[5:0]};
      default: wr_data_m = {bit_data_in, rd_data[6:0]};
    endcase
  end else
    wr_data_m = wr_data;
end





endmodule
