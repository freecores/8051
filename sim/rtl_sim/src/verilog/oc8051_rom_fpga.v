//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program rom                                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program rom for simulation                                 ////
////                  fpga version                                ////
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
module oc8051_rom (rst, clk, addr, data1, data2, data3);

input rst, clk;
input [15:0] addr;
output [7:0] data1, data2, data3;
reg [7:0] data1, data2, data3;
reg [7:0] buff [65535:0];

initial
begin
    buff [16'h00_00] = 8'h00;
    buff [16'h00_01] = 8'h00;
    buff [16'h00_02] = 8'h75;
    buff [16'h00_03] = 8'h90;
    buff [16'h00_04] = 8'hAA;
    buff [16'h00_05] = 8'h78;
    buff [16'h00_06] = 8'h01;
    buff [16'h00_07] = 8'h7D;
    buff [16'h00_08] = 8'h00;
    buff [16'h00_09] = 8'h75;
    buff [16'h00_0a] = 8'h80;
    buff [16'h00_0b] = 8'h0F;
    buff [16'h00_0c] = 8'h00;
    buff [16'h00_0d] = 8'h00;
    buff [16'h00_0e] = 8'h00;
    buff [16'h00_0f] = 8'h60;
    buff [16'h00_10] = 8'hFB;
    buff [16'h00_11] = 8'h7C;
    buff [16'h00_12] = 8'h01;
    buff [16'h00_13] = 8'h75;
    buff [16'h00_14] = 8'h80;
    buff [16'h00_15] = 8'h00;
    buff [16'h00_16] = 8'h8C;
    buff [16'h00_17] = 8'h90;
    buff [16'h00_18] = 8'h00;
    buff [16'h00_19] = 8'h11;
    buff [16'h00_1a] = 8'h2F;
    buff [16'h00_1b] = 8'h88;
    buff [16'h00_1c] = 8'h80;
    buff [16'h00_1d] = 8'hED;
    buff [16'h00_1e] = 8'h00;
    buff [16'h00_1f] = 8'h00;
    buff [16'h00_20] = 8'h60;
    buff [16'h00_21] = 8'h03;
    buff [16'h00_22] = 8'h08;
    buff [16'h00_23] = 8'h01;
    buff [16'h00_24] = 8'h26;
    buff [16'h00_25] = 8'h18;
    buff [16'h00_26] = 8'hEC;
    buff [16'h00_27] = 8'h03;
    buff [16'h00_28] = 8'hFC;
    buff [16'h00_29] = 8'h00;
    buff [16'h00_2a] = 8'h01;
    buff [16'h00_2b] = 8'h16;
    buff [16'h00_2c] = 8'h75;
    buff [16'h00_2d] = 8'h80;
    buff [16'h00_2e] = 8'h11;
    buff [16'h00_2f] = 8'h79;
    buff [16'h00_30] = 8'h05;
    buff [16'h00_31] = 8'h7A;
    buff [16'h00_32] = 8'h05;
    buff [16'h00_33] = 8'h74;
    buff [16'h00_34] = 8'h05;
    buff [16'h00_35] = 8'hF9;
    buff [16'h00_36] = 8'hEA;
    buff [16'h00_37] = 8'h24;
    buff [16'h00_38] = 8'h02;
    buff [16'h00_39] = 8'hE9;
    buff [16'h00_3a] = 8'h14;
    buff [16'h00_3b] = 8'h00;
    buff [16'h00_3c] = 8'h00;
    buff [16'h00_3d] = 8'h00;
    buff [16'h00_3e] = 8'h00;
    buff [16'h00_3f] = 8'h00;
    buff [16'h00_40] = 8'h00;
    buff [16'h00_41] = 8'h00;
    buff [16'h00_42] = 8'h00;
    buff [16'h00_43] = 8'h70;
    buff [16'h00_44] = 8'hF0;
    buff [16'h00_45] = 8'h1A;
    buff [16'h00_46] = 8'hEA;
    buff [16'h00_47] = 8'h70;
    buff [16'h00_48] = 8'hEA;
    buff [16'h00_49] = 8'h22;
    buff [16'h00_4a] = 8'h00;
    buff [16'h00_4b] = 8'h00;
    buff [16'h00_4c] = 8'h00;
    buff [16'h00_4d] = 8'h00;
    buff [16'h00_4e] = 8'h00;
    buff [16'h00_4f] = 8'h00;
    buff [16'h00_50] = 8'h00;
    buff [16'h00_51] = 8'h74;
    buff [16'h00_52] = 8'h01;
    buff [16'h00_53] = 8'h7D;
    buff [16'h00_54] = 8'h00;
    buff [16'h00_55] = 8'h00;
    buff [16'h00_56] = 8'h00;
    buff [16'h00_57] = 8'h32;
    buff [16'h00_58] = 8'h00;
    buff [16'h00_59] = 8'h00;
    buff [16'h00_5a] = 8'h00;
    buff [16'h00_5b] = 8'h00;
    buff [16'h00_5c] = 8'h00;
    buff [16'h00_5d] = 8'h00;
    buff [16'h00_5e] = 8'h00;
    buff [16'h00_5f] = 8'h00;
    buff [16'h00_60] = 8'h00;
    buff [16'h00_61] = 8'h00;
    buff [16'h00_62] = 8'h00;
    buff [16'h00_63] = 8'h00;
    buff [16'h00_64] = 8'h00;
    buff [16'h00_65] = 8'h00;
    buff [16'h00_66] = 8'h7D;
    buff [16'h00_67] = 8'h0F;
    buff [16'h00_68] = 8'h74;
    buff [16'h00_69] = 8'h01;
    buff [16'h00_6a] = 8'h00;
    buff [16'h00_6b] = 8'h00;
    buff [16'h00_6c] = 8'h32;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
