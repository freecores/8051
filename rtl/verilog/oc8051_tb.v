//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 top level test bench                                   ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   top level test bench.                                      ////
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

module oc8051_tb;

reg rst, clk, int; reg [15:0] pc_in; reg [7:0] data_in, int_v, p0_in, p1_in, p2_in, p3_in;
wire [15:0] rom_addr, ext_addr; wire  reti, write; wire [7:0] data_out, p0_out, p1_out, p2_out, p3_out;

oc8051_top oc8051_top_1(.rst(rst), .clk(clk), .rom_addr(rom_addr), .int(int), .int_v(int_v), .reti(reti), .data_in(data_in), .data_out(data_out),
         .ext_addr(ext_addr), .write(write), .p0_in(p0_in), .p1_in(p1_in), .p2_in(p2_in), .p3_in(p3_in), .p0_out(p0_out),
         .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out));


initial begin
  clk= 1'b0;
  rst= 1'b1;
  int= 1'b0;
  int_v= 8'h00;
  pc_in = 16'h0000;
  data_in = 8'h33;
  p0_in = 8'h00;
  p1_in = 8'h00;
  p2_in = 8'h00;
  p3_in = 8'h00;
#22
  rst = 1'b0;
#1400
  $finish;
end

initial begin
#222
  int= 1'b1;
  int_v= 8'h50;
#20
  int= 1'b0;
end

always clk = #5 ~clk;

always @(posedge clk)
  data_in <= #1 ext_addr [7:0];

initial $dumpvars;


initial $monitor("time ",$time," rom_addr %h", rom_addr, " acc %h", data_out, " dptr %h", ext_addr, " write ", write, " p0_out %h", p0_out, " p1_out %h", p1_out);

endmodule