//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program counter                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program counter                                            ////
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


module oc8051_pc (rst, clk, pc_out, alu, pc_wr_sel, op1, op2, op3, wr, rd, int);
//
// rst          (in)  reset
// clk          (in)  clock
// pc_out       (out) output, connected to rom_addr_sel1, it's current rom addres [oc8051_rom_addr_sel.pc]
// alu          (in)  input from alu, used in case of jumps (next addres is calculated in alu and written to pc) [{oc8051_alu.des1,oc8051_alu.des2}]
// pc_wr_sel    (in)  input indicates whitch input will be written to pc in case of writting [oc8051_decoder.pc_sel]
// op1          (in)  instruction (byte 1) used to calculate next addres [oc8051_op_select.op1_out]
// op2          (in)  instruction (byte 2) used in jumps [oc8051_op_select.op2_out]
// op3          (in)  instruction (byte 3) used in jumps [oc8051_op_select.op3_out]
// wr           (in)  write (active high) [oc8051_decoder.pc_wr]
// rd           (in)  read: if high calculate next addres else hold current [oc8051_decoder.rd]
// int          (in)  interrupt (if high don't change outputs -- write to stack) [pin]
//


input [1:0] pc_wr_sel;
input [15:0] alu;
input [7:0] op1, op2, op3;

input rst, clk, int, wr, rd;
output [15:0] pc_out;

reg [15:0] pc_out;

//
//pc            program counter register, save current value
reg [15:0] pc;

//
// wr_lo        write low: used in reti instruction, write only low byte of pc
// ini_buff     interrupt buffer: used to prevent interrupting in the middle of executin instructions
reg wr_lo, int_buff, int_buff1;

always @(pc or op1 or rst or rd or int_buff or int_buff1)
begin
  if (rst) begin
//
// in case of reset read value from buffer
    pc_out= pc;
  end else begin
    if (int_buff | int_buff1)
//
//in case of interrupt hold valut, to be written to stack
       pc_out= pc;
    else if (rd) begin
//
// normal execution calculate next value and send it immediate to outputs
        casex (op1)
              `OC8051_ACALL : pc_out= pc+2;
              `OC8051_AJMP : pc_out= pc+2;

        //op_code [7:3]
              `OC8051_CJNE_R : pc_out= pc+3;
              `OC8051_DJNZ_R : pc_out= pc+2;
              `OC8051_MOV_DR : pc_out= pc+2;
              `OC8051_MOV_CR : pc_out= pc+2;
              `OC8051_MOV_RD : pc_out= pc+2;

        //op_code [7:1]
              `OC8051_CJNE_I : pc_out= pc+3;
              `OC8051_MOV_ID : pc_out= pc+2;
              `OC8051_MOV_DI : pc_out= pc+2;
              `OC8051_MOV_CI : pc_out= pc+2;

        //op_code [7:0]
              `OC8051_ADD_D : pc_out= pc+2;
              `OC8051_ADD_C : pc_out= pc+2;
              `OC8051_ADDC_D : pc_out= pc+2;
              `OC8051_ADDC_C : pc_out= pc+2;
              `OC8051_ANL_D : pc_out= pc+2;
              `OC8051_ANL_C : pc_out= pc+2;
              `OC8051_ANL_DD : pc_out= pc+2;
              `OC8051_ANL_DC : pc_out= pc+3;
              `OC8051_ANL_B : pc_out= pc+2;
              `OC8051_ANL_NB : pc_out= pc+2;
              `OC8051_CJNE_D : pc_out= pc+3;
              `OC8051_CJNE_C : pc_out= pc+3;
              `OC8051_CLR_B : pc_out= pc+2;
              `OC8051_CPL_B : pc_out= pc+2;
              `OC8051_DEC_D : pc_out= pc+2;
              `OC8051_DJNZ_D : pc_out= pc+3;
              `OC8051_INC_D : pc_out= pc+2;
              `OC8051_JB : pc_out= pc+3;
              `OC8051_JBC : pc_out= pc+3;
              `OC8051_JC : pc_out= pc+2;
              `OC8051_JNB : pc_out= pc+3;
              `OC8051_JNC : pc_out= pc+2;
              `OC8051_JNZ : pc_out= pc+2;
              `OC8051_JZ : pc_out= pc+2;
              `OC8051_LCALL :pc_out= pc+3;
              `OC8051_LJMP : pc_out= pc+3;
              `OC8051_MOV_D : pc_out= pc+2;
              `OC8051_MOV_C : pc_out= pc+2;
              `OC8051_MOV_DA : pc_out= pc+2;
              `OC8051_MOV_DD : pc_out= pc+3;
              `OC8051_MOV_CD : pc_out= pc+3;
              `OC8051_MOV_BC : pc_out= pc+2;
              `OC8051_MOV_CB : pc_out= pc+2;
              `OC8051_MOV_DP : pc_out= pc+3;
              `OC8051_ORL_D : pc_out= pc+2;
              `OC8051_ORL_C : pc_out= pc+2;
              `OC8051_ORL_AD : pc_out= pc+2;
              `OC8051_ORL_CD : pc_out= pc+3;
              `OC8051_ORL_B : pc_out= pc+2;
              `OC8051_ORL_NB : pc_out= pc+2;
              `OC8051_POP : pc_out= pc+2;
              `OC8051_PUSH : pc_out= pc+2;
              `OC8051_SETB_B : pc_out= pc+2;
              `OC8051_SJMP : pc_out= pc+2;
              `OC8051_SUBB_D : pc_out= pc+2;
              `OC8051_SUBB_C : pc_out= pc+2;
              `OC8051_XCH_D : pc_out= pc+2;
              `OC8051_XRL_D : pc_out= pc+2;
              `OC8051_XRL_C : pc_out= pc+2;
              `OC8051_XRL_AD : pc_out= pc+2;
              `OC8051_XRL_CD : pc_out= pc+3;
              default: pc_out= pc+1;
            endcase
//
//in case of instructions that use more than one clock hold current pc
       end else pc_out= pc;
  end
end


//
//interrupt buffer
always @(posedge clk or posedge rst)
  if (rst)
    int_buff <= #1 1'b0;
  else
    int_buff <= #1 int;

always @(posedge clk or posedge rst)
    int_buff1 <= #1 int_buff;


always @(posedge clk)
begin
  if (rst)
    pc <= #1 `OC8051_RST_PC;
  else if (wr_lo) begin
    pc[7:0] <= #1 alu[15:8];
    wr_lo <= #1 1'b0;
  end else begin
    if (wr) begin
//
//case of writing new value to pc (jupms)
      case (pc_wr_sel)
        `OC8051_PIS_SP: begin
          pc[15:8] <= #1 alu[15:8];
          wr_lo <= #1 1'b1;
        end
        `OC8051_PIS_ALU: pc <= #1 alu;
        `OC8051_PIS_I11: pc[10:0] <= #1 {op1[7:5], op2};
        `OC8051_PIS_I16: pc <= #1 {op2, op3};
      endcase
    end else
//
//or just remember current
      pc <= #1 pc_out;
  end
end

endmodule

