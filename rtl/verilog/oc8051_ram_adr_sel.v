//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 internal ram address select                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Two multiplexers wiht whitch we define                     ////
////      ram read and write address                              ////
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

`include "oc8051_defines.v"

module oc8051_ram_adr_sel (clk, rst, rd_sel, wr_sel, sp, ri, rn, imm, imm2, rd_addr, wr_addr, rd_ind, wr_ind);
//
// sel          (in)  select (look defines) [oc8051_decoder.ram_rd_sel]
// sp           (in)  stack ponter [oc8051_sp.data_out]
// ri           (in)  indirect addresing [oc8051_indi_addr.data_out]
// rn           (in)  registers [{oc8051_psw.data_out[4:3], oc8051_op_select.op1_out[2:0]}]
// imm          (in)  immediate (direct addresing) [oc8051_op_select.op2_direct]
// addr_out     (out) output [oc8051_ram_top.rd_addr, oc8051_ram_sel.addr -r, oc8051_ports.rd_addr]
// rd_ind       (out) read indiect
// wr_ind       (out) write indirect
//

input clk, rst;
input [1:0] rd_sel;
input [2:0] wr_sel;
input [4:0] rn;
input [7:0] sp, ri, imm, imm2;

output rd_ind, wr_ind;
output [7:0] wr_addr, rd_addr;
reg rd_ind, wr_ind;
reg [7:0] wr_addr, rd_addr;

reg [2:0] wr_sel_r;
reg [4:0] rn_r;
reg [7:0] sp_r, ri_r, imm_r, imm2_r;

//
//
always @(rd_sel or sp or ri or rn or imm)
begin
  case (rd_sel)
    `OC8051_RRS_RN : rd_addr = {3'b000, rn};
    `OC8051_RRS_I : rd_addr = ri;
    `OC8051_RRS_D : rd_addr = imm;
    `OC8051_RRS_SP : rd_addr = sp;
    default : rd_addr = 2'bxx;
  endcase

end


always @(posedge clk or posedge rst)
  if (rst) begin
    sp_r <= #1 8'h00;
    rn_r <= #1 5'd0;
    ri_r <= #1 8'h00;
    imm_r <= #1 8'h00;
    imm2_r <= #1 8'h00;
    wr_sel_r <= #1 3'b000;
  end else begin
    sp_r <= #1 sp;
    rn_r <= #1 rn;
    ri_r <= #1 ri;
    imm_r <= #1 imm;
    imm2_r <= #1 imm2;
    wr_sel_r <= #1 wr_sel;
  end

//
//
always @(wr_sel_r or sp_r or rn_r or imm_r or ri_r or imm2_r)
begin
  case (wr_sel_r)
    `OC8051_RWS_RN : wr_addr = {3'b000, rn_r};
    `OC8051_RWS_I : wr_addr = ri_r;
    `OC8051_RWS_D : wr_addr = imm_r;
    `OC8051_RWS_SP : wr_addr = sp_r;
    `OC8051_RWS_ACC : wr_addr = `OC8051_SFR_ACC;
    `OC8051_RWS_D3 : wr_addr = imm2_r;
    `OC8051_RWS_DPTR : wr_addr = `OC8051_SFR_DPTR_LO;
    `OC8051_RWS_B : wr_addr = `OC8051_SFR_B;
    default : wr_addr = 2'bxx;
  endcase
end

always @(posedge clk or posedge rst)
  if (rst)
    rd_ind <= #1 1'b0;
  else if ((rd_sel==`OC8051_RRS_I) && (rd_sel==`OC8051_RRS_SP))
    rd_ind <= #1 1'b1;
  else
    rd_ind <= #1 1'b0;

always @(posedge clk or posedge rst)
  if (rst)
    wr_ind <= #1 1'b0;
  else if ((wr_sel==`OC8051_RWS_I) && (wr_sel==`OC8051_RWS_SP))
    wr_ind <= #1 1'b1;
  else
    wr_ind <= #1 1'b0;

endmodule
