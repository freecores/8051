//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cache ram                                              ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   64x32 dual port ram for instruction cache                  ////
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


module oc8051_cache_ram (clk, rst, addr0, data0, addr1, data1_i, data1_o, wr1);
//
// this module is part of oc8051_icache
// it's tehnology dependent
//
// clk          (in)  clock
// addr0        (in)  addres port 0
// data0        (out) data output port 0
// addr1        (in)  address port 1
// data1_i      (in)  data input port 1
// data1_o      (out) data output port 1
// wr1          (in)  write port 1
//


input clk, wr1, rst;
input [5:0] addr0, addr1;
input [31:0] data1_i;
output [31:0] data0, data1_o;

reg [31:0] data0, data1_o;
reg [8:0] count;

//
// buffer
reg [31:0] buff [63:0];

/*
initial
begin
  for (count = 0; count < 64; count = count + 1)
  begin
    buff[count] <= 32'h00000000;
  end
end*/

//
// port 1
//
always @(posedge clk or posedge rst)
begin
  if (rst)
    data1_o <= #1 32'h0;
  else if (wr1) begin
    buff[addr1] <= #1 data1_i;
    data1_o <= #1 data1_i;
  end else 
    data1_o <= #1 buff[addr1];
end

//
// port 0
//
always @(posedge clk or posedge rst)
begin
  if (rst)
    data0 <= #1 32'h0;
  else if ((addr0==addr1) & wr1)
    data0 <= #1 data1_i;
  else
    data0 <= #1 buff[addr0];
end


endmodule
