//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 ram write select                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we define ram write address        ////
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


module oc8051_ram_wr_sel (sel, sp, rn, imm, ri, imm2, out);
//
// sel          (in)  select (look defines) [oc8051_decoder.ram_wr_sel -r]
// sp           (in)  stack ponter [oc8051_sp.data_out]
// ri           (in)  indirect addressing [oc8051_indi_addr.data_out -r]
// rn           (in)  registers [{oc8051_psw.data_out[4:3], oc8051_op_select.op1_out[2:0]} -r]
// imm          (in)  immediate, byte 2 (direct addresing) [oc8051_op_select.op2_direct -r]
// imm2         (in)  immediate, byte 3 (direct addresing) [oc8051_op_select.op3_out]
// out          (out) output [oc8051_ram_top.wr_addr, oc8051_acc.wr_addr, oc8051_b_register.wr_addr, oc8051_sp.wr_addr, oc8051_dptr.addr, oc8051_psw.addr, oc8051_indi_addr.addr, oc8051_ports.wr_addr]
//

input [2:0] sel;
input [4:0] rn;
input [7:0] sp, imm, ri, imm2;

output [7:0] out;
reg [7:0] out;

//
//
always @(sel or sp or rn or imm or ri or imm2)
begin
  case (sel)
    `OC8051_RWS_RN : out = {3'b000, rn};
    `OC8051_RWS_I : out = ri;
    `OC8051_RWS_D : out = imm;
    `OC8051_RWS_SP : out = sp;
    `OC8051_RWS_ACC : out = `OC8051_SFR_ACC;
    `OC8051_RWS_D3 : out = imm2;
    `OC8051_RWS_DPTR : out = `OC8051_SFR_DPTR_LO;
    `OC8051_RWS_B : out = `OC8051_SFR_B;
    default : out = 2'bxx;
  endcase

end

endmodule
