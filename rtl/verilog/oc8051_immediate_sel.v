//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 immediate data select                                  ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select immediate data           ////
////   (byte 2, byte 3, program counter high or low)              ////
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


module oc8051_immediate_sel (sel, op1, op2, op3, pch, pcl, out1, out2);
//
// sel          (in)  select (from decoder) [oc8051_decoder.imm_sel]
// op1          (in)  byte 1 [oc8051_op_select.op1_out]
// op2          (in)  byte 2 [oc8051_op_select.op2_out]
// op3          (in)  byte 3 [oc8051_op_select.op3_out]
// pch          (in)  pc high [oc8051_pc.pc_out[15:8] -r]
// pcl          (in)  pc low [oc8051_pc.pc_out[7:0] ]
// out1         (out) output to alu source select 1 [oc8051_alu_src1_sel.immediate]
// out2         (out) output to alu source select 2 [oc8051_alu_src2_sel.immediate]
//


input [2:0] sel; input [7:0] op1, op2, op3, pch, pcl;
output [7:0] out1, out2;
reg [7:0] out1, out2;

always @(sel or op1 or op2 or op3 or pch or pcl)
begin
  case (sel)
    `OC8051_IDS_OP3: begin
      out1= op3;
      out2= op3;
    end
    `OC8051_IDS_PCH: begin
      out1= pch;
      out2= pch;
    end
    `OC8051_IDS_PCL: begin
      out1= pcl;
      out2= pcl;
    end
    `OC8051_IDS_OP3_PCL: begin
      out1= op3;
      out2= pcl;
    end
    `OC8051_IDS_OP3_OP2: begin
      out1= op3;
      out2= op2;
    end
    `OC8051_IDS_OP2_PCL: begin
      out1= op2;
      out2= pcl;
    end
    `OC8051_IDS_OP1: begin
      out1= op1;
      out2= op1;
    end
    default: begin
      out1= op2;
      out2= op2;
    end
  endcase
end

endmodule