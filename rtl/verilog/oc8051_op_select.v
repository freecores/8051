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
// ver: 1
//


// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_op_select (clk, rst, int, rd, ea, ea_int, int_v, op1_i, op2_i, op3_i, op1_x, op2_x, op3_x, op1_out, op2_out, op2_direct, op3_out, ack);
//
// clk          (in)  clock
// int          (in)  interrupt [pin]
// int_v        (in)  interrupt vector (low byte) [pin]
// op1_i, op2_i, op3_i (in)  input from interanal rom (instruction bytes) [pin]
// op1_x, op2_x, op3_x (in)  input from exteranl rom (instruction bytes) [pin]
// rd           (in)  read from rom [oc8051_decoder.rd]
// op1_out      (out) byte 1 output [oc8051_pc.op1, oc8051_decoder.op_in]
// op2_out      (out) byte 2 output [oc8051_pc.op2, oc8051_immediate_sel.op2, oc8051_comp.op2 -r]
// op2_direct   (out) byte 2 output (used for direct addressing) [oc8051_ram_rd_sel.imm, oc8051_ram_wr_sel.imm -r]
// op3_out      (out) byte 3 output [oc8051_pc.op3, oc8051_ram_wr_sel.imm2, oc8051_immediate_sel.op3
//


input clk, int, rd, ea, ea_int, rst;
input [7:0] op1_i, op2_i, op3_i, op1_x, op2_x, op3_x, int_v;
output ack;
output [7:0] op1_out, op3_out, op2_out, op2_direct;

reg int_ack, ack, int_ack_buff;
reg [7:0] op2_direct, int_vec_buff;
reg [7:0] op1_buff, op2_buff, op3_buff;
reg [7:0] op1_o, op2_o, op3_o;

wire [7:0] op1, op2, op3;
wire select, int;

assign select = ea & ea_int;

assign op1 = select ? op1_i: op1_x;
assign op2 = select ? op2_i: op2_x;
assign op3 = select ? op3_i: op3_x;

//
// assigning outputs
// case rd = 1'b0 don't change output

//assign op1_out = rd ? op1_o : op1_buff;
assign op1_out = op1_o;

assign op3_out = rd ? op3_o : op3_buff;
//assign op2_tmp = rd ? op2_o : op2_buff;
assign op2_out = rd ? op2_o : op2_buff;

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
always @(posedge clk)
begin
  op1_buff <= #1 op1_o;
  op2_buff <= #1 op2_o;
  op3_buff <= #1 op3_o;
end

//
// remember interrupt
// we don't want to interrupt instruction in the middle of execution
always @(posedge clk)
 if (rst) begin
   int_ack <= #1 1'b0;
   int_vec_buff <= #1 8'h00;
 end else if (int) begin
   int_ack <= #1 1'b1;
   int_vec_buff <= #1 int_v;
 end else if (rd) int_ack <= #1 1'b0;

always @(posedge clk)
  int_ack_buff <= #1 int_ack;

always @(posedge clk)
  if ((int_ack_buff) & !(int_ack))
    ack <= #1 1'b1;
  else ack <= #1 1'b0;


//
// some instructions write to known addresses
always @(op1_out or op2_out)
begin
  if ((op1_out==`OC8051_MOV_DP) | (op1_out==`OC8051_INC_DP) | (op1_out==`OC8051_JMP) | (op1_out==`OC8051_MOVC_DP))
    op2_direct  = `OC8051_SFR_DPTR_LO;
  else if ((op1_out==`OC8051_MUL) | (op1_out == `OC8051_DIV))
    op2_direct  = `OC8051_SFR_B;
  else op2_direct  = op2_out;
end


endmodule
