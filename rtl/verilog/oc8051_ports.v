//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 port output                                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function registers: port 0:3 - output         ////
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
// Revision 1.7  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.6  2002/09/30 17:33:59  simont
// prepared header
//
//


// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_ports (clk, rst, 
                    bit_in, data_in, 
		    wr, wr_bit, 
		    wr_addr, rmw, 
		    p0_out, p1_out, p2_out, p3_out,
                    p0_in, p1_in, p2_in, p3_in,
		    p0_data, p1_data, p2_data, p3_data);
//
// clk          (in)  clock
// rst          (in)  reset
// bit_in       (in)  bit input [oc8051_alu.desCy]
// data_in      (in)  data input (from alu destiantion 1) [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// wr_addr      (in)  write address [oc8051_ram_wr_sel.out]
// rd_addr      (in)  read address [oc8051_ram_rd_sel.out]
// rmw          (in)  read modify write feature [oc8051_decoder.rmw]
// data_out     (out) data output [oc8051_ram_sel.ports_in]
// p0_out, p1_out, p2_out, p3_out       (out) port outputs [pin]
// p0_in, p1_in, p2_in, p3_in           (in)  port inputs [pin]
//


input clk, rst, wr, wr_bit, bit_in, rmw;
input [7:0] wr_addr, data_in, p0_in, p1_in, p2_in, p3_in;

output [7:0] p0_out, p1_out, p2_out, p3_out;
output [7:0] p0_data, p1_data, p2_data, p3_data;

reg [7:0] p0_out, p1_out, p2_out, p3_out;

assign p0_data = rmw ? p0_out : p0_in;
assign p1_data = rmw ? p1_out : p1_in;
assign p2_data = rmw ? p2_out : p2_in;
assign p3_data = rmw ? p3_out : p3_in;

//
// case of writing to port
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    p0_out <= #1 `OC8051_RST_P0;
    p1_out <= #1 `OC8051_RST_P1;
    p2_out <= #1 `OC8051_RST_P2;
    p3_out <= #1 `OC8051_RST_P3;
  end else if (wr) begin
    if (!wr_bit) begin
      case (wr_addr)
//
// bytaddresable
        `OC8051_SFR_P0: p0_out <= #1 data_in;
        `OC8051_SFR_P1: p1_out <= #1 data_in;
        `OC8051_SFR_P2: p2_out <= #1 data_in;
        `OC8051_SFR_P3: p3_out <= #1 data_in;
      endcase
    end else begin
      case (wr_addr[7:3])

//
// bit addressable
        `OC8051_SFR_B_P0: p0_out[wr_addr[2:0]] <= #1 bit_in;
        `OC8051_SFR_B_P1: p1_out[wr_addr[2:0]] <= #1 bit_in;
        `OC8051_SFR_B_P2: p2_out[wr_addr[2:0]] <= #1 bit_in;
        `OC8051_SFR_B_P3: p3_out[wr_addr[2:0]] <= #1 bit_in;
      endcase
    end
  end
end


endmodule

