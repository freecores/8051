//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 alu source 2 select module                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select data on alu source 2     ////
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


module oc8051_alu_src2_sel (sel, immediate, acc, ram, des);
//
// sel          (in)  select signals (from decoder, delayd one clock) [oc8051_decoder.src_sel2 -r]
// immediate    (in)  immediate data [oc8051_immediate_sel.out2]
// acc          (in)  accomulator [oc8051_acc.data_out]
// ram          (in)  ram input [oc8051_ram_sel.out_data]
// des          (out) output (alu sorce 2) [oc8051_alu.src2]
//

input [1:0] sel; input [7:0] acc, ram, immediate;
output [7:0] des;
reg [7:0] des;

always @(sel or immediate or acc or ram)
begin
  case (sel)
    `OC8051_ASS_ACC: des= acc;
    `OC8051_ASS_ZERO: des= 8'h00;
    `OC8051_ASS_IMM: des= immediate;
    default: des= ram;
  endcase
end

endmodule

