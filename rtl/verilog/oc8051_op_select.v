//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 instruction select                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   module that stops current program and insert long call     ////
////   in case of interrupt                                       ////
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

`include "oc8051_defines.v"


module oc8051_op_select (clk, rst, intr, rd, ea, ea_int, int_v, op1_i, op2_i, op3_i, op1_x, op2_x, op3_x, op1_out, op2_out, op2_direct, op3_out, ack);
//
// clk          (in)  clock
// intr          (in)  interrupt [pin]
// int_v        (in)  interrupt vector (low byte) [pin]
// op1_i, op2_i, op3_i (in)  input from interanal rom (instruction bytes) [pin]
// op1_x, op2_x, op3_x (in)  input from exteranl rom (instruction bytes) [pin]
// rd           (in)  read from rom [oc8051_decoder.rd]
// op1_out      (out) byte 1 output [oc8051_pc.op1, oc8051_decoder.op_in]
// op2_out      (out) byte 2 output [oc8051_pc.op2, oc8051_immediate_sel.op2, oc8051_comp.op2 -r]
// op2_direct   (out) byte 2 output (used for direct addressing) [oc8051_ram_rd_sel.imm, oc8051_ram_wr_sel.imm -r]
// op3_out      (out) byte 3 output [oc8051_pc.op3, oc8051_ram_wr_sel.imm2, oc8051_immediate_sel.op3
//


input clk, intr, rd, ea, ea_int, rst;
input [7:0] op1_i, op2_i, op3_i, op1_x, op2_x, op3_x, int_v;
output ack;
output [7:0] op1_out, op3_out, op2_out, op2_direct;

reg int_ack, ack, int_ack_buff;
reg [7:0] op2_direct_in, int_vec_buff, op2_direct_buff;
reg [7:0] op2_buff, op3_buff;
reg [7:0] op1_o, op2_o, op3_o;

wire [7:0] op1, op2, op3;
wire sel;

assign sel = ea & ea_int;

assign op1 = sel ? op1_i: op1_x;
assign op2 = sel ? op2_i: op2_x;
assign op3 = sel ? op3_i: op3_x;

//
// assigning outputs
// case rd = 1'b0 don't change output

assign op1_out = op1_o;

assign op3_out = rd ? op3_o : op3_buff;
//assign op2_tmp = rd ? op2_o : op2_buff;
assign op2_out = rd ? op2_o : op2_buff;
assign op2_direct = rd ? op2_direct_in : op2_direct_buff;

//
// in case of interrupts
always @(op1 or op2 or op3 or int_ack or int_vec_buff) begin
  if (int_ack) begin
    op1_o = `OC8051_LCALL;
    op2_o = 8'h00;
    op3_o = int_vec_buff;
  end else begin
    op1_o = op1;
    op2_o = op2;
    op3_o = op3;
  end
end

//
// remember inputs
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    op2_buff <= #1 8'h0;
    op3_buff <= #1 8'h0;
    op2_direct_buff <= #1 8'h0;
  end else if (rd) begin
    op2_buff <= #1 op2_o;
    op3_buff <= #1 op3_o;
    op2_direct_buff <= #1 op2_direct_in;
  end
end

//
// remember interrupt
// we don't want to interrupt instruction in the middle of execution
always @(posedge clk or posedge rst)
 if (rst) begin
   int_ack <= #1 1'b0;
   int_vec_buff <= #1 8'h00;
 end else if (intr) begin
   int_ack <= #1 1'b1;
   int_vec_buff <= #1 int_v;
 end else if (rd) int_ack <= #1 1'b0;

always @(posedge clk or posedge rst)
  if (rst) int_ack_buff <= #1 1'b0;
  else int_ack_buff <= #1 int_ack;

always @(posedge clk or posedge rst)
  if (rst) ack <= #1 1'b0;
  else begin
    if ((int_ack_buff) & !(int_ack))
      ack <= #1 1'b1;
    else ack <= #1 1'b0;
  end

//
// some instructions write to known addresses
always @(op1_out or op2_out)
begin
  if ((op1_out==`OC8051_MOV_DP) | (op1_out==`OC8051_INC_DP) | (op1_out==`OC8051_JMP) | (op1_out==`OC8051_MOVC_DP))
    op2_direct_in  = `OC8051_SFR_DPTR_LO;
  else if ((op1_out==`OC8051_MUL) | (op1_out == `OC8051_DIV))
    op2_direct_in  = `OC8051_SFR_B;
  else op2_direct_in  = op2_out;
end


endmodule
