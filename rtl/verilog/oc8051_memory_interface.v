//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 memory interface                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   comunication betwen cpu and memory                         ////
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
// Revision 1.7  2003/05/06 09:39:34  simont
// cahnge assigment to pc_wait (remove istb_o)
//
// Revision 1.6  2003/05/05 15:46:37  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.5  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.4  2003/04/16 10:04:09  simont
// chance idat_ir to 24 bit wide
//
// Revision 1.3  2003/04/11 10:05:08  simont
// Change pc add value from 23'h to 16'h
//
// Revision 1.2  2003/04/09 16:24:03  simont
// change wr_sft to 2 bit wire.
//
// Revision 1.1  2003/01/13 14:13:12  simont
// initial import
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_memory_interface (clk, rst,
//decoder
  wr_i, wr_bit_i, rd_sel, wr_sel,
  pc_wr_sel, pc_wr, pc, rd,
  mem_wait, mem_act, istb,
//internal ram
  wr_o, wr_bit_o, rd_addr, wr_addr, rd_ind, wr_ind, wr_dat,

  bit_in, in_ram, sfr, sfr_bit, bit_out, iram_out,

//program rom
  iadr_o, ea, ea_int,
  op1_out, op2_out, op3_out,
//internal
  op1_i, op2_i, op3_i,
//external
  iack_i, istb_o, idat_i,

//external data ram
  dadr_o, dwe_o, dstb_o, dack_i, ddat_i, ddat_o,
//interrupt interface
  intr, int_v, int_ack,

//alu
  des_acc, des1, des2,

//sfr's
  dptr, ri, sp,  sp_w, rn, acc, reti);

input bit_in, sfr_bit, dack_i;
input [2:0] mem_act;
input [7:0] in_ram, sfr, acc, sp_w;
input [31:0] idat_i;

output bit_out, mem_wait, reti;
output [7:0] iram_out, wr_dat;

reg bit_out, reti;
reg [7:0] iram_out, sp_r;
reg       rd_addr_r;
input clk, rst, wr_i, wr_bit_i;
output wr_o, wr_bit_o;

//????
reg dack_ir;
reg [7:0] ddat_ir;
reg [23:0] idat_ir;

/////////////////////////////
//
//  rom_addr_sel
//
/////////////////////////////
input iack_i;
input [7:0] des_acc, des1, des2;
output [15:0] iadr_o;

wire ea_rom_sel;

/////////////////////////////
//
// ext_addr_sel
//
/////////////////////////////
input [7:0] ri, ddat_i;
input [15:0] dptr;

output dstb_o, dwe_o;
output [7:0] ddat_o;
output [15:0] dadr_o;

/////////////////////////////
//
// ram_adr_sel
//
/////////////////////////////

input [2:0] rd_sel, wr_sel;
input [4:0] rn;
input [7:0] sp;

output rd_ind, wr_ind;
output [7:0] wr_addr, rd_addr;
reg rd_ind, wr_ind;
reg [7:0] wr_addr, rd_addr;

reg [4:0] rn_r;
reg [7:0] ri_r, imm_r, imm2_r, op1_r;
wire [7:0] imm, imm2;

/////////////////////////////
//
// op_select
//
/////////////////////////////

input intr, rd, ea, ea_int, istb;
input [7:0] op1_i, op2_i, op3_i, int_v;
output int_ack, istb_o;
output [7:0] op1_out, op3_out, op2_out;

reg int_ack_t, int_ack, int_ack_buff;
reg [7:0] int_vec_buff;
reg [7:0] op1_out, op2_buff, op3_buff;
reg [7:0] op1_o, op2_o, op3_o;
reg [7:0] op1_xt, op2_xt, op3_xt;

wire [7:0] op1, op2, op3, op2_direct;
//wire op_sel;

/////////////////////////////
//
//  pc
//
/////////////////////////////
input [2:0] pc_wr_sel;

input pc_wr;
output [15:0] pc;


reg [15:0] pc;

//
//pc            program counter register, save current value
reg [15:0] pc_buf;
wire [15:0] alu;

//
// wr_lo        write low: used in reti instruction, write only low byte of pc
// ini_buff     interrupt buffer: used to prevent interrupting in the middle of executin instructions
reg int_buff, int_buff1;


//
//
////////////////////////////
reg istb_t, imem_wait, dstb_o, dwe_o;
//reg [3:0] mem_act_r;
reg [7:0] ddat_o;
reg [15:0] iadr_t, dadr_ot;
reg dmem_wait;
wire pc_wait;
wire [1:0] bank;
//wire pis_l;
wire [15:0] iadr_ot;
wire [7:0] isr_call;

assign bank = rn[4:3];
assign imm = op2_out;
assign imm2 = op3_out;
assign alu = {des2, des_acc};
assign ea_rom_sel = ea && ea_int;
assign wr_o = wr_i;
assign wr_bit_o = wr_bit_i;

assign mem_wait = dmem_wait || imem_wait;
assign istb_o = (istb || (istb_t & !iack_i)) && !dstb_o && !ea_rom_sel;

assign pc_wait = rd && (ea_rom_sel || (!istb_t && iack_i));

assign wr_dat = des1;


/////////////////////////////
//
//  ram_select
//
/////////////////////////////
always @(rd_addr_r or in_ram or sfr or bit_in or sfr_bit or rd_ind)
begin
  if (rd_addr_r && !rd_ind) begin
    iram_out = sfr;
    bit_out = sfr_bit;
  end else begin
    iram_out = in_ram;
    bit_out = bit_in;
  end
end

/////////////////////////////
//
// ram_adr_sel
//
/////////////////////////////

always @(rd_sel or sp or ri or rn or imm or dadr_o[15:0] or bank)
begin
  case (rd_sel)
    `OC8051_RRS_RN   : rd_addr = {3'h0, rn};
    `OC8051_RRS_I    : rd_addr = ri;
    `OC8051_RRS_D    : rd_addr = imm;
    `OC8051_RRS_SP   : rd_addr = sp;

    `OC8051_RRS_B    : rd_addr = `OC8051_SFR_B;
    `OC8051_RRS_DPTR : rd_addr = `OC8051_SFR_DPTR_LO;
    `OC8051_RRS_PSW  : rd_addr = `OC8051_SFR_PSW;
    `OC8051_RRS_ACC  : rd_addr = `OC8051_SFR_ACC;
    default          : rd_addr = 2'bxx;
  endcase

end


//
//
always @(wr_sel or sp_w or rn_r or imm_r or ri_r or imm2_r or op1_r or dadr_o[15:0])
begin
  case (wr_sel)
    `OC8051_RWS_RN : wr_addr = {3'h0, rn_r};
    `OC8051_RWS_I  : wr_addr = ri_r;
    `OC8051_RWS_D  : wr_addr = imm_r;
    `OC8051_RWS_SP : wr_addr = sp_w;
    `OC8051_RWS_D3 : wr_addr = imm2_r;
    `OC8051_RWS_B  : wr_addr = `OC8051_SFR_B;
    default        : wr_addr = 2'bxx;
  endcase
end

always @(posedge clk or posedge rst)
  if (rst)
    rd_ind <= #1 1'b0;
  else if ((rd_sel==`OC8051_RRS_I) || (rd_sel==`OC8051_RRS_SP))
    rd_ind <= #1 1'b1;
  else
    rd_ind <= #1 1'b0;

always @(wr_sel)
  if ((wr_sel==`OC8051_RWS_I) || (wr_sel==`OC8051_RWS_SP))
    wr_ind = 1'b1;
  else
    wr_ind = 1'b0;


/////////////////////////////
//
//  rom_addr_sel
//
/////////////////////////////
//
// output address is alu destination
// (instructions MOVC)

assign iadr_ot = (istb_t & !iack_i) ? iadr_t : pc;
assign iadr_o = iadr_ot;


always @(posedge clk or posedge rst)
begin
  if (rst) begin
    iadr_t <= #1 23'h0;
    istb_t <= #1 1'b0;
    imem_wait <= #1 1'b0;
    idat_ir <= #1 24'h0;
  end else if (iack_i) begin
    istb_t <= #1 1'b0;
    imem_wait <= #1 1'b0;
    idat_ir <= #1 idat_i [23:0];
  end else if (ea_rom_sel && imem_wait) begin
    imem_wait <= #1 1'b0;
  end else if (ea_rom_sel && !imem_wait && istb_t) begin
    istb_t <= #1 1'b0;
  end else if (mem_act==`OC8051_MAS_CODE) begin
    iadr_t <= #1 alu;
    istb_t <= #1 1'b1;
    imem_wait <= #1 1'b1;
  end
end

/////////////////////////////
//
// ext_addr_sel
//
/////////////////////////////

assign dadr_o = dadr_ot;

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    dwe_o <= #1 1'b0;
    dmem_wait <= #1 1'b0;
    dstb_o <= #1 1'b0;
    ddat_o <= #1 8'h00;
    dadr_ot <= #1 23'h0;
  end else if (dack_i) begin
    dwe_o <= #1 1'b0;
    dstb_o <= #1 1'b0;
    dmem_wait <= #1 1'b0;
  end else begin
    case (mem_act)
      `OC8051_MAS_DPTR_R: begin  // read from external rom: acc=(dptr)
        dwe_o <= #1 1'b0;
        dstb_o <= #1 1'b1;
        ddat_o <= #1 8'h00;
        dadr_ot <= #1 {7'h0, dptr};
        dmem_wait <= #1 1'b1;
      end
      `OC8051_MAS_DPTR_W: begin  // write to external rom: (dptr)=acc
        dwe_o <= #1 1'b1;
        dstb_o <= #1 1'b1;
        ddat_o <= #1 acc;
        dadr_ot <= #1 {7'h0, dptr};
        dmem_wait <= #1 1'b1;
      end
      `OC8051_MAS_RI_R:   begin  // read from external rom: acc=(Ri)
        dwe_o <= #1 1'b0;
        dstb_o <= #1 1'b1;
        ddat_o <= #1 8'h00;
        dadr_ot <= #1 {15'h0, ri};
        dmem_wait <= #1 1'b1;
      end
      `OC8051_MAS_RI_W: begin    // write to external rom: (Ri)=acc
        dwe_o <= #1 1'b1;
        dstb_o <= #1 1'b1;
        ddat_o <= #1 acc;
        dadr_ot <= #1 {15'h0, ri};
        dmem_wait <= #1 1'b1;
      end
    endcase
  end
end

/////////////////////////////
//
// op_select
//
/////////////////////////////


assign op1 = ea_rom_sel ? op1_i: op1_xt;
assign op2 = ea_rom_sel ? op2_i: op2_xt;
assign op3 = ea_rom_sel ? op3_i: op3_xt;


always @(dack_ir or ddat_ir or op1_o or iram_out)
  if (dack_ir)
    op1_out = ddat_ir;
  else
    op1_out = op1_o;

assign op3_out = (rd) ? op3_o : op3_buff;
assign op2_out = (rd) ? op2_o : op2_buff;

always @(idat_i or iack_i or idat_ir or rd)
begin
  if (iack_i) begin
    op1_xt = idat_i[7:0];
    op2_xt = idat_i[15:8];
    op3_xt = idat_i[23:16];
  end else if (!rd) begin
    op1_xt = idat_ir[7:0];
    op2_xt = idat_ir[15:8];
    op3_xt = idat_ir[23:16];
  end else begin
    op1_xt = 8'h00;
    op2_xt = 8'h00;
    op3_xt = 8'h00;
  end
end


//
// in case of interrupts
always @(op1 or op2 or op3 or int_ack_t or int_vec_buff or iack_i or ea_rom_sel)
begin
  if (int_ack_t && (iack_i || ea_rom_sel)) begin
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
//in case of reti
always @(posedge clk or posedge rst)
  if (rst) reti <= #1 1'b0;
  else if ((op1_o==`OC8051_RETI) & rd) reti <= #1 1'b1;
  else reti <= #1 1'b0;

//
// remember inputs
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    op2_buff <= #1 8'h0;
    op3_buff <= #1 8'h0;
  end else if (rd) begin
    op2_buff <= #1 op2_o;
    op3_buff <= #1 op3_o;
  end
end

//
// remember interrupt
// we don't want to interrupt instruction in the middle of execution
always @(posedge clk or posedge rst)
 if (rst) begin
   int_ack_t <= #1 1'b0;
   int_vec_buff <= #1 8'h00;
 end else if (intr) begin
   int_ack_t <= #1 1'b1;
   int_vec_buff <= #1 int_v;
 end else if (rd && (ea_rom_sel || iack_i)) int_ack_t <= #1 1'b0;

always @(posedge clk or posedge rst)
  if (rst) int_ack_buff <= #1 1'b0;
  else int_ack_buff <= #1 int_ack_t;

always @(posedge clk or posedge rst)
  if (rst) int_ack <= #1 1'b0;
  else begin
    if ((int_ack_buff) & !(int_ack_t))
      int_ack <= #1 1'b1;
    else int_ack <= #1 1'b0;
  end


/////////////////////////////
//
//  pc
//
/////////////////////////////

always @(pc_buf or op1_out or pc_wait or int_buff or int_buff1 or ea_rom_sel or iack_i)
begin
    if (int_buff || int_buff1) begin
//
//in case of interrupt hold valut, to be written to stack
      pc= pc_buf;
//    end else if (pis_l) begin
//      pc = {pc_buf[22:8], alu[7:0]};
    end else if (pc_wait) begin
        casex (op1_out)
          `OC8051_ACALL :  pc= pc_buf + 16'h2;
          `OC8051_AJMP :   pc= pc_buf + 16'h2;

        //op_code [7:3]
          `OC8051_CJNE_R : pc= pc_buf + 16'h3;
          `OC8051_DJNZ_R : pc= pc_buf + 16'h2;
          `OC8051_MOV_DR : pc= pc_buf + 16'h2;
          `OC8051_MOV_CR : pc= pc_buf + 16'h2;
          `OC8051_MOV_RD : pc= pc_buf + 16'h2;

        //op_code [7:1]
          `OC8051_CJNE_I : pc= pc_buf + 16'h3;
          `OC8051_MOV_ID : pc= pc_buf + 16'h2;
          `OC8051_MOV_DI : pc= pc_buf + 16'h2;
          `OC8051_MOV_CI : pc= pc_buf + 16'h2;

        //op_code [7:0]
          `OC8051_ADD_D :  pc= pc_buf + 16'h2;
          `OC8051_ADD_C :  pc= pc_buf + 16'h2;
          `OC8051_ADDC_D : pc= pc_buf + 16'h2;
          `OC8051_ADDC_C : pc= pc_buf + 16'h2;
          `OC8051_ANL_D :  pc= pc_buf + 16'h2;
          `OC8051_ANL_C :  pc= pc_buf + 16'h2;
          `OC8051_ANL_DD : pc= pc_buf + 16'h2;
          `OC8051_ANL_DC : pc= pc_buf + 16'h3;
          `OC8051_ANL_B :  pc= pc_buf + 16'h2;
          `OC8051_ANL_NB : pc= pc_buf + 16'h2;
          `OC8051_CJNE_D : pc= pc_buf + 16'h3;
          `OC8051_CJNE_C : pc= pc_buf + 16'h3;
          `OC8051_CLR_B :  pc= pc_buf + 16'h2;
          `OC8051_CPL_B :  pc= pc_buf + 16'h2;
          `OC8051_DEC_D :  pc= pc_buf + 16'h2;
          `OC8051_DJNZ_D : pc= pc_buf + 16'h3;
          `OC8051_INC_D :  pc= pc_buf + 16'h2;
          `OC8051_JB :     pc= pc_buf + 16'h3;
          `OC8051_JBC :    pc= pc_buf + 16'h3;
          `OC8051_JC :     pc= pc_buf + 16'h2;
          `OC8051_JNB :    pc= pc_buf + 16'h3;
          `OC8051_JNC :    pc= pc_buf + 16'h2;
          `OC8051_JNZ :    pc= pc_buf + 16'h2;
          `OC8051_JZ :     pc= pc_buf + 16'h2;
          `OC8051_LCALL :  pc= pc_buf + 16'h3;
          `OC8051_LJMP :   pc= pc_buf + 16'h3;
          `OC8051_MOV_D :  pc= pc_buf + 16'h2;
          `OC8051_MOV_C :  pc= pc_buf + 16'h2;
          `OC8051_MOV_DA : pc= pc_buf + 16'h2;
          `OC8051_MOV_DD : pc= pc_buf + 16'h3;
          `OC8051_MOV_CD : pc= pc_buf + 16'h3;
          `OC8051_MOV_BC : pc= pc_buf + 16'h2;
          `OC8051_MOV_CB : pc= pc_buf + 16'h2;
          `OC8051_MOV_DP : pc= pc_buf + 16'h3;
          `OC8051_ORL_D :  pc= pc_buf + 16'h2;
          `OC8051_ORL_C :  pc= pc_buf + 16'h2;
          `OC8051_ORL_AD : pc= pc_buf + 16'h2;
          `OC8051_ORL_CD : pc= pc_buf + 16'h3;
          `OC8051_ORL_B :  pc= pc_buf + 16'h2;
          `OC8051_ORL_NB : pc= pc_buf + 16'h2;
          `OC8051_POP :    pc= pc_buf + 16'h2;
          `OC8051_PUSH :   pc= pc_buf + 16'h2;
          `OC8051_SETB_B : pc= pc_buf + 16'h2;
          `OC8051_SJMP :   pc= pc_buf + 16'h2;
          `OC8051_SUBB_D : pc= pc_buf + 16'h2;
          `OC8051_SUBB_C : pc= pc_buf + 16'h2;
          `OC8051_XCH_D :  pc= pc_buf + 16'h2;
          `OC8051_XRL_D :  pc= pc_buf + 16'h2;
          `OC8051_XRL_C :  pc= pc_buf + 16'h2;
          `OC8051_XRL_AD : pc= pc_buf + 16'h2;
          `OC8051_XRL_CD : pc= pc_buf + 16'h3;
          default:         pc= pc_buf + 16'h1;
        endcase
//
//in case of instructions that use more than one clock hold current pc
    end else begin
      pc= pc_buf;
   end
end


//
//interrupt buffer
always @(posedge clk or posedge rst)
  if (rst) begin
    int_buff1 <= #1 1'b0;
  end else begin
    int_buff1 <= #1 int_buff;
  end

always @(posedge clk or posedge rst)
  if (rst) begin
    int_buff <= #1 1'b0;
  end else if (intr) begin
    int_buff <= #1 1'b1;
  end else if (pc_wait)
    int_buff <= #1 1'b0;

wire [7:0]  pcs_source;
reg  [15:0] pcs_result;
reg         pcs_cy;

assign pcs_source = pc_wr_sel[0] ? op3_out : op2_out;

always @(pcs_source or pc or pcs_cy)
begin
  if (pcs_source[7]) begin
    {pcs_cy, pcs_result[7:0]} = {1'b0, pc[7:0]} + {1'b0, pcs_source};
    pcs_result[15:8] = pc[15:8] - {7'h0, !pcs_cy};
  end else pcs_result = pc + {8'h00, pcs_source};
end


always @(posedge clk or posedge rst)
begin
  if (rst) begin
    pc_buf <= #1 `OC8051_RST_PC;
  end else begin
    if (pc_wr) begin
//
//case of writing new value to pc (jupms)
      case (pc_wr_sel)
        `OC8051_PIS_ALU: pc_buf        <= #1 alu;
        `OC8051_PIS_AL:  pc_buf[7:0]   <= #1 alu[7:0];
        `OC8051_PIS_AH:  pc_buf[15:8]  <= #1 alu[7:0];
        `OC8051_PIS_I11: pc_buf[10:0]  <= #1 {op1_out[7:5], op2_out};
        `OC8051_PIS_I16: pc_buf        <= #1 {op2_out, op3_out};
        `OC8051_PIS_SO1: pc_buf        <= #1 pcs_result;
        `OC8051_PIS_SO2: pc_buf        <= #1 pcs_result;
      endcase
    end else
//
//or just remember current
      pc_buf <= #1 pc;
  end
end


always @(posedge clk or posedge rst)
  if (rst)
    ddat_ir <= #1 8'h00;
  else if (dack_i)
    ddat_ir <= #1 ddat_i;

////////////////////////
always @(posedge clk or posedge rst)
  if (rst) begin
    rn_r <= #1 5'd0;
    ri_r <= #1 8'h00;
    imm_r <= #1 8'h00;
    imm2_r <= #1 8'h00;
    rd_addr_r <= #1 1'b0;
    op1_r <= #1 8'h0;
    dack_ir <= #1 1'b0;
    sp_r <= #1 1'b0;
  end else begin
    rn_r <= #1 rn;
    ri_r <= #1 ri;
    imm_r <= #1 imm;
    imm2_r <= #1 imm2;
    rd_addr_r <= #1 rd_addr[7];
    op1_r <= #1 op1_out;
    dack_ir <= #1 dack_i;
    sp_r <= #1 sp;
  end


endmodule
