//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 indirect address                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Contains ragister 0 and register 1. used for indirrect     ////
////   addressing.                                                ////
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
// Revision 1.4  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_indi_addr (clk, rst, rd_addr, wr_addr, data_in, wr, wr_bit, rn_out, ri_out, sel, bank);
//
// clk          (in)  clock
// rst          (in)  reset
// addr         (in)  write address [oc8051_ram_wr_sel.out]
// data_in      (in)  data input (alu destination1) [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// data_out     (out) data output [oc8051_ram_rd_sel.ri, oc8051_ram_wr_sel.ri -r]
// sel          (in)  select register [oc8051_op_select.op1_out[0] ]
// bank         (in)  select register bank: [oc8051_psw.data_out[4:3] ]
//


input clk, rst, wr, wr_bit;
input [1:0] bank;
input [2:0] sel;
input [7:0] data_in;
input [7:0] rd_addr, wr_addr;

output [7:0] rn_out, ri_out;

reg [7:0] rn_out;

reg [7:0] buff [31:0];
reg wr_bit_r;
wire rd_ram, rd_ind;


wire tmp;
assign tmp = ~|wr_addr[7:5];
//
//write to buffer
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    buff[0] <= #1 8'h00;
    buff[1] <= #1 8'h00;
    buff[2] <= #1 8'h00;
    buff[3] <= #1 8'h00;
    buff[4] <= #1 8'h00;
    buff[5] <= #1 8'h00;
    buff[6] <= #1 8'h00;
    buff[7] <= #1 8'h00;
    buff[8] <= #1 8'h00;
    buff[9] <= #1 8'h00;
    buff[10] <= #1 8'h00;
    buff[11] <= #1 8'h00;
    buff[12] <= #1 8'h00;
    buff[13] <= #1 8'h00;
    buff[14] <= #1 8'h00;
    buff[15] <= #1 8'h00;
    buff[16] <= #1 8'h00;
    buff[17] <= #1 8'h00;
    buff[18] <= #1 8'h00;
    buff[19] <= #1 8'h00;
    buff[20] <= #1 8'h00;
    buff[21] <= #1 8'h00;
    buff[22] <= #1 8'h00;
    buff[23] <= #1 8'h00;
    buff[24] <= #1 8'h00;
    buff[25] <= #1 8'h00;
    buff[26] <= #1 8'h00;
    buff[27] <= #1 8'h00;
    buff[28] <= #1 8'h00;
    buff[29] <= #1 8'h00;
    buff[30] <= #1 8'h00;
    buff[31] <= #1 8'h00;
  end else if ((wr) && !(wr_bit_r) && (tmp)) begin
    buff[wr_addr[4:0]] <= #1 data_in;
  end
end

//
//read from buffer
assign rd_ram = (rd_addr== wr_addr);
assign rd_ind = ({3'h0, bank,  2'b00, sel[0]}==wr_addr);
assign ri_out = ( rd_ind & (wr) & !wr_bit) ? data_in : buff[{bank, 2'b00, sel[0]}];

always @(posedge clk or posedge rst)
  if (rst) begin
    rn_out <= #1 8'h00;
  end else if ( rd_ram & (wr) & !wr_bit) begin
    rn_out <= #1 data_in;
  end else begin
    rn_out <= #1 buff[rd_addr[4:0]];
  end


always @(posedge clk or posedge rst)
  if (rst) begin
    wr_bit_r <= #1 1'b0;
  end else begin
    wr_bit_r <= #1 wr_bit;
  end

endmodule
