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


module oc8051_ram (clk, rd_addr, rd_data, wr_addr, wr_data, wr);
//
// this module is part of oc8051_ram_top
// it's tehnology dependent
//
// clk          (in)  clock
// rd_addr      (in)  read addres
// rd_data      (out) read data
// wr_addr      (in)  write addres
// wr_data      (in)  write data
// wr           (in)  write
//


input clk, wr;
input [7:0] rd_addr, wr_addr, wr_data;
output [7:0] rd_data;

reg [7:0] rd_data;
reg [8:0] count;

//
// buffer
reg [7:0] buff [255:0];


initial
begin

  for (count = 0; count < 256; count = count + 1)
  begin
    buff[count] <= 8'h00;
  end
end

//
// writing to ram
always @(posedge clk)
begin
  if (wr)
    buff[wr_addr] <= #1 wr_data;
end

//
// reading from ram
always @(posedge clk)
begin
  if ((wr_addr==rd_addr) & wr)
    rd_data <= #1 wr_data;
  else
    rd_data <= #1 buff[rd_addr];
end


endmodule
