//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 core decoder                                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Main 8051 core module. decodes instruction and creates     ////
////   control sigals.                                            ////
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



module oc8051_decoder (clk, rst, op_in, eq, ram_rd_sel, ram_wr_sel, bit_addr,
wr, src_sel1, src_sel2, src_sel3, alu_op, psw_set, cy_sel, imm_sel, pc_wr,
pc_sel, comp_sel, rom_addr_sel, ext_addr_sel, wad2, rd, write_x, reti,
rmw);
//
// clk          (in)  clock
// rst          (in)  reset
// op_in        (in)  operation code [oc8051_op_select.op1]
// eq           (in)  compare result [oc8051_comp.eq]
// ram_rd_sel   (out) select, whitch address will be send to ram for read [oc8051_ram_rd_sel.sel, oc8051_sp.ram_rd_sel]
// ram_wr_sel   (out) select, whitch address will be send to ram for write [oc8051_ram_wr_sel.sel -r, oc8051_sp.ram_wr_sel -r]
// wr           (out) write - if 1 then we will write to ram [oc8051_ram_top.wr -r, oc8051_acc.wr -r, oc8051_b_register.wr -r, oc8051_sp.wr-r, oc8051_dptr.wr -r, oc8051_psw.wr -r, oc8051_indi_addr.wr -r, oc8051_ports.wr -r]
// src_sel1     (out) select alu source 1 [oc8051_alu_src1_sel.sel -r]
// src_sel2     (out) select alu source 2 [oc8051_alu_src2_sel.sel -r]
// src_sel3     (out) select alu source 3 [oc8051_alu_src3_sel.sel -r]
// alu_op       (out) alu operation [oc8051_alu.op_code -r]
// psw_set      (out) will we remember cy, ac, ov from alu [oc8051_psw.set -r]
// cy_sel       (out) carry in alu select [oc8051_cy_select.cy_sel -r]
// comp_sel     (out) compare source select [oc8051_comp.sel]
// bit_addr     (out) if instruction is bit addresable [oc8051_ram_top.bit_addr -r, oc8051_acc.wr_bit -r, oc8051_b_register.wr_bit-r, oc8051_sp.wr_bit -r, oc8051_dptr.wr_bit -r, oc8051_psw.wr_bit -r, oc8051_indi_addr.wr_bit -r, oc8051_ports.wr_bit -r]
// wad2         (out) write acc from destination 2 [oc8051_acc.wad2 -r]
// imm_sel      (out) immediate select [oc8051_immediate_sel.sel -r]
// pc_wr        (out) pc write [oc8051_pc.wr]
// pc_sel       (out) pc select [oc8051_pc.pc_wr_sel]
// rom_addr_sel (out) rom address select (alu destination or pc) [oc8051_rom_addr_sel.select]
// ext_addr_sel (out) external address select (dptr or Ri) [oc8051_ext_addr_sel.select]
// rd           (out) read from rom [oc8051_pc.rd, oc8051_op_select.rd]
// write_x      (out) write to external rom [pin]
// reti         (out) return from interrupt [pin]
// rmw          (out) read modify write feature [oc8051_ports.rmw]
//

input clk, rst, eq;
input [7:0] op_in;

output wr, reti, write_x, bit_addr, src_sel3, rom_addr_sel, ext_addr_sel,
pc_wr, wad2, rmw;
output [1:0] ram_rd_sel, src_sel1, src_sel2, psw_set, cy_sel, pc_sel;
output [2:0] ram_wr_sel, comp_sel, imm_sel;
output [3:0] alu_op;
output rd;

reg reti, write_x, rmw;
reg wr,  bit_addr, src_sel3, rom_addr_sel, ext_addr_sel, pc_wr, wad2;
reg [1:0] psw_set, ram_rd_sel, src_sel1, src_sel2, pc_sel, cy_sel;
reg [3:0] alu_op;
reg [2:0] comp_sel, ram_wr_sel, imm_sel;

//
// state        if 2'b00 then normal execution, sle instructin that need more than one clock
// op           instruction buffer
reg [1:0] state;
reg [7:0] op;

//
// if state = 2'b00 then read nex instruction
assign rd = !state[0] & !state[1];

//
// main block
// case of instruction set control signals
always @(rst or op_in or eq or state or op)
begin
  if (rst) begin
    ram_rd_sel = `OC8051_RRS_DC;
    ram_wr_sel = `OC8051_RWS_DC;
    src_sel1 = `OC8051_ASS_DC;
    src_sel2 = `OC8051_ASS_DC;
    alu_op = `OC8051_ALU_NOP;
    imm_sel = `OC8051_IDS_DC;
    wr = 1'b0;
    psw_set = `OC8051_PS_NOT;
    cy_sel = `OC8051_CY_0;
    pc_wr = `OC8051_PCW_N;
    pc_sel = `OC8051_PIS_DC;
    comp_sel = `OC8051_CSS_DC;
    rmw = `OC8051_RMW_N;
    bit_addr = 1'b0;
    src_sel3 = `OC8051_AS3_DC;
    rom_addr_sel = `OC8051_RAS_PC;
    ext_addr_sel = `OC8051_EAS_DC;
    wad2 = `OC8051_WAD_N;
    
  end else begin
    case (state)
      2'b01: begin
    casex (op)
      `OC8051_ACALL :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_SP;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_PCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          comp_sel = `OC8051_CSS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;
          bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_AJMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_DC;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          comp_sel = `OC8051_CSS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;
          bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_LCALL :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_SP;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_PCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          comp_sel = `OC8051_CSS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;
          bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_MOVC_DP :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP1;
          src_sel3 = `OC8051_AS3_DP;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_MOVC_PC :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP1;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      default begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
      end
    endcase
    end
    2'b10:
    casex (op)
      `OC8051_CJNE_R : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_CJNE_I : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_CJNE_D : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_CJNE_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_DJNZ_R : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_DJNZ_D : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DES;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_JB : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_JBC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_CY;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JNB : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JNC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_CY;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JNZ : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = !eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_AZ;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
          
        end
      `OC8051_JZ : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = eq;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_AZ;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_MOVC_DP :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DP;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_DES;
          ext_addr_sel = `OC8051_EAS_DC;

        end
      `OC8051_MOVC_PC :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_DES;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SJMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_ALU;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      default begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
      end
    endcase

    2'b11:
    casex (op)
      `OC8051_CJNE_R : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_I : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_D : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DJNZ_R : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DJNZ_D : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RET : begin
          ram_rd_sel = `OC8051_RRS_SP;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_SP;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RETI : begin
          ram_rd_sel = `OC8051_RRS_SP;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_SP;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      default begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
      end
    endcase
    default: begin
    casex (op_in)
      `OC8051_ACALL :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_SP;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_PCL;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_I11;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_AJMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_DC;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_I11;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end


      `OC8051_ADD_R : begin
	  ram_rd_sel = `OC8051_RRS_RN;
	  ram_wr_sel = `OC8051_RWS_ACC;
	  src_sel1 = `OC8051_ASS_ACC;
	  src_sel2 = `OC8051_ASS_RAM;
	  alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
	  psw_set = `OC8051_PS_AC;
	  cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ADDC_R : begin
	  ram_rd_sel = `OC8051_RRS_RN;
	  ram_wr_sel = `OC8051_RWS_ACC;
	  src_sel1 = `OC8051_ASS_ACC;
	  src_sel2 = `OC8051_ASS_RAM;
	  alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
	  psw_set = `OC8051_PS_AC;
	  cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DEC_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DJNZ_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_INC_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end

      `OC8051_MOV_AR : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_DR : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_CR : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_RD : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SUBB_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XCH_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_RN;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_R : begin
          ram_rd_sel = `OC8051_RRS_RN;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end

//op_code [7:1]
      `OC8051_ADD_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ADDC_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DEC_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_INC_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_ID : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_AI : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_DI : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_CI : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOVX_IA : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_XRAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_RI;
        end
      `OC8051_MOVX_AI :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_RI;
        end
      `OC8051_ORL_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SUBB_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XCH_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XCHD :begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_I;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_I : begin
          ram_rd_sel = `OC8051_RRS_I;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end

//op_code [7:0]
      `OC8051_ADD_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ADD_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ADDC_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ADDC_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_DD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_DC : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_B : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_AND;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ANL_NB : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RR;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CJNE_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CLR_A : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CLR_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CLR_B : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CPL_A : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOT;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;   ///****
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CPL_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOT;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;  ///*****
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_CPL_B : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOT;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_RAM;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;  ///***
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DA : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_DA;
          wr = 1'b1;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DEC_A : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DEC_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DIV : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_B;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_DIV;
          wr = 1'b1;
          psw_set = `OC8051_PS_OV;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_DJNZ_D : begin
	  ram_rd_sel = `OC8051_RRS_D;
	  ram_wr_sel = `OC8051_RWS_D;
	  src_sel1 = `OC8051_ASS_RAM;
	  src_sel2 = `OC8051_ASS_ZERO;
	  alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
	  psw_set = `OC8051_PS_NOT;
	  cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_INC_A : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_INC_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ZERO;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_INC_DP : begin
	  ram_rd_sel = `OC8051_RRS_D;
	  ram_wr_sel = `OC8051_RWS_DPTR;
	  src_sel1 = `OC8051_ASS_RAM;
	  src_sel2 = `OC8051_ASS_ZERO;
	  alu_op = `OC8051_ALU_ADD;
          wr = 1'b1;
	  psw_set = `OC8051_PS_NOT;
	  cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DP;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JB : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JBC :begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_CY;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JMP : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DP;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JNB : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_BIT;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JNC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_CY;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JNZ :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_AZ;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_JZ : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_AZ;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_LCALL :begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_SP;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_PCL;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_I16;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_LJMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_DC;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_Y;
          pc_sel = `OC8051_PIS_I16;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end

      `OC8051_MOV_DA : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_DD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D3;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_CD : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_BC : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_RAM;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_CB : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOV_DP : begin  ///***
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DPTR;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOVC_DP :begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DP;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOVC_PC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_ADD;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_MOVX_PA : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_XRAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DPTR;
        end
      `OC8051_MOVX_AP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_XRAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DPTR;
        end
      `OC8051_MUL : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_B;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_MUL;
          wr = 1'b1;
          psw_set = `OC8051_PS_OV;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_AD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_CD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_B : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_OR;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_ORL_NB : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RL;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_POP : begin
          ram_rd_sel = `OC8051_RRS_SP;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_PUSH : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_SP;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RET : begin
          ram_rd_sel = `OC8051_RRS_SP;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RETI : begin
          ram_rd_sel = `OC8051_RRS_SP;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RL : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RL;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RLC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RLC;
          wr = 1'b1;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RR : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_RRC : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RRC;
          wr = 1'b1;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SETB_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b0;
          psw_set = `OC8051_PS_CY;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SETB_B : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b1;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SJMP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_PCS;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2_PCL;
          src_sel3 = `OC8051_AS3_PC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SUBB_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SUBB_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_IMM;
          alu_op = `OC8051_ALU_SUB;
          wr = 1'b1;
          psw_set = `OC8051_PS_AC;
          cy_sel = `OC8051_CY_PSW;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_SWAP : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_ACC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_RLC;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XCH_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XCH;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_1;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_Y;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_D : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_C : begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_ACC;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP2;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_AD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_RAM;
          src_sel2 = `OC8051_ASS_ACC;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      `OC8051_XRL_CD : begin
          ram_rd_sel = `OC8051_RRS_D;
          ram_wr_sel = `OC8051_RWS_D;
          src_sel1 = `OC8051_ASS_IMM;
          src_sel2 = `OC8051_ASS_RAM;
          alu_op = `OC8051_ALU_XOR;
          wr = 1'b1;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          imm_sel = `OC8051_IDS_OP3;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_Y;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
        end
      default: begin
          ram_rd_sel = `OC8051_RRS_DC;
          ram_wr_sel = `OC8051_RWS_DC;
          src_sel1 = `OC8051_ASS_DC;
          src_sel2 = `OC8051_ASS_DC;
          alu_op = `OC8051_ALU_NOP;
          imm_sel = `OC8051_IDS_DC;
          wr = 1'b0;
          psw_set = `OC8051_PS_NOT;
          cy_sel = `OC8051_CY_0;
          pc_wr = `OC8051_PCW_N;
          pc_sel = `OC8051_PIS_DC;
          src_sel3 = `OC8051_AS3_DC;
          comp_sel = `OC8051_CSS_DC;
          rmw = `OC8051_RMW_N;        bit_addr = 1'b0;
          wad2 = `OC8051_WAD_N;
          rom_addr_sel = `OC8051_RAS_PC;
          ext_addr_sel = `OC8051_EAS_DC;
       end

    endcase
    end
    endcase
  end
end

//
// remember current instruction
always @(posedge clk)
  if (state==2'b00)
    op <= #1 op_in;

//
// in case of instructions that needs more than one clock set state
always @(posedge clk or posedge rst)
begin
  if (rst)
    state <= #1 2'b00;
  else begin
    case (state)
      2'b10: state <= #1 2'b01;
      2'b11: state <= #1 2'b10;
      2'b00:
        casex (op_in)
          `OC8051_ACALL :state <= #1 2'b01;
          `OC8051_AJMP : state <= #1 2'b01;
          `OC8051_CJNE_R :state <= #1 2'b11;
          `OC8051_CJNE_I :state <= #1 2'b11;
          `OC8051_CJNE_D : state <= #1 2'b11;
          `OC8051_CJNE_C : state <= #1 2'b11;
          `OC8051_LJMP : state <= #1 2'b01;
          `OC8051_DJNZ_R :state <= #1 2'b11;
          `OC8051_DJNZ_D :state <= #1 2'b11;
          `OC8051_LCALL :state <= #1 2'b01;
          `OC8051_MOVC_DP :state <= #1 2'b10;
          `OC8051_MOVC_PC :state <= #1 2'b10;
          `OC8051_RET : state <= #1 2'b11;
          `OC8051_RETI : state <= #1 2'b11;
          `OC8051_SJMP : state <= #1 2'b10;
          `OC8051_JB : state <= #1 2'b10;
          `OC8051_JBC : state <= #1 2'b10;
          `OC8051_JC : state <= #1 2'b10;
          `OC8051_JMP : state <= #1 2'b10;
          `OC8051_JNC : state <= #1 2'b10;
          `OC8051_JNB : state <= #1 2'b10;
          `OC8051_JNZ : state <= #1 2'b10;
          `OC8051_JZ : state <= #1 2'b10;
          default: state <= #1 2'b00;
        endcase
      default: state <= #1 2'b00;
    endcase
  end
end

//
//in case of reti
always @(posedge clk)
  if (op==`OC8051_RETI) reti <= #1 1'b1;
  else reti <= #1 1'b0;

//
//in case of writing to external ram
always @(op_in or rst or rd)
begin
  if (rst)
    write_x = 1'b0;
  else if (rd)
  begin
    casex (op_in)
      `OC8051_MOVX_AI : write_x = 1'b1;
      `OC8051_MOVX_AP : write_x = 1'b1;
      default : write_x = 1'b0;
    endcase
  end else write_x = 1'b0;
end


endmodule


