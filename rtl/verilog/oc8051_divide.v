//////////////////////////////////////////////////////////////////////
//// 								  ////
//// divide for 8051 Core 				  	  ////
//// 								  ////
//// This file is part of the 8051 cores project 		  ////
//// http://www.opencores.org/cores/8051/ 			  ////
//// 								  ////
//// Description 						  ////
//// Two cycle implementation of division used in alu.v	          ////
//// 								  ////
//// To Do: 							  ////
////  check if compiler does proper optimizations of the code     ////
//// 								  ////
//// Author(s): 						  ////
//// - Simon Teran, simont@opencores.org 			  ////
//// - Marko Mlinar, markom@opencores.org 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//// 								  ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG 		  ////
//// 								  ////
//// This source file may be used and distributed without 	  ////
//// restriction provided that this copyright statement is not 	  ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
//// 								  ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version. 						  ////
//// 								  ////
//// This source is distributed in the hope that it will be 	  ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	  ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details. 							  ////
//// 								  ////
//// You should have received a copy of the GNU Lesser General 	  ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//
// ver: 2 markom
// changed nonsynthesizable version to two cycle divison

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_divide (clk, rst, enable, src1, src2, des1, des2, desOv);
//
// this module is part of alu
// clk          (in)
// rst          (in)
// enable       (in)  starts divison
// src1         (in)  first operand
// src2         (in)  second operand
// des1         (out) first result
// des2         (out) second result
// desOv        (out) Overflow output
//

input clk, rst, enable;
input [7:0] src1, src2;
output desOv;
output [7:0] des1, des2;

// wires
reg desOv;
reg div0, div1, div2, div3;
reg [7:0] rem1, rem2, rem3;
reg [15:0] cmp0, cmp1, cmp2, cmp3;
reg [7:0] div_out, rem_out;
wire [7:0] div, rem;

// real registers
reg cycle;
reg [3:0] tmp_div;
reg [7:0] tmp_rem;

assign rem = cycle ? tmp_rem : src1;

//
// in clock cycle 0 we first calculate four MSB bits,
// and four LSB in cycle 1
always @(src2 or tmp_div or rem or cycle)
begin
  if (src2 == 8'b0000_0000) begin
    desOv <= 1'b1;
    div_out <= 8'hxxxx_xxxx;
    rem_out <= 8'hxxxx_xxxx;
  end else begin
    desOv <= 1'b0;

    /* This logic is very much redundant, but it should be optimized by
       synthesizer */
    cmp3 <= src2 << (cycle ? 3'h7 : 3'h3);
    cmp2 <= src2 << (cycle ? 3'h6 : 3'h2);
    cmp1 <= src2 << (cycle ? 3'h5 : 3'h1);
    cmp0 <= src2 << (cycle ? 3'h4 : 3'h0);
    div3 <= cmp3 <= rem;
    div2 <= cmp2 <= rem3;
    div1 <= cmp1 <= rem2;
    div0 <= cmp0 <= rem1;
    rem3 <= rem - (div3 ? cmp3 : 8'h0);
    rem2 <= rem3 - (div2 ? cmp2 : 8'h0);
    rem1 <= rem2 - (div1 ? cmp1 : 8'h0);
    rem_out <= rem1 - (div0 ? cmp0 : 8'h0);
    div_out <= {tmp_div, div3, div2, div1, div0};
  end
end

//
// divider works in two clock cycles -- 0 and 1
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    cycle <= #1 1'b0;
    tmp_div <= #1 4'h0;
    tmp_rem <= #1 8'h0;
  end else begin
    if (enable && !cycle) cycle <= #1 1'b1;
    else cycle <= #1 1'b0;
    tmp_div <= #1 div_out[3:0];
    tmp_rem <= #1 rem_out;
  end
end

//
// assign outputs
assign des1 = rem_out;
assign des2 = div_out;

endmodule

