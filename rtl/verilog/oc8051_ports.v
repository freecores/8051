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
// ver: 1
//


// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_ports (clk, rst, bit_in, data_in, wr, wr_bit, wr_addr, rd_addr, rmw, data_out, bit_out, p0_out, p1_out, p2_out, p3_out,
                     p0_in, p1_in, p2_in, p3_in);
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
input [7:0] wr_addr, rd_addr, data_in, p0_in, p1_in, p2_in, p3_in;

output bit_out;
output [7:0] data_out, p0_out, p1_out, p2_out, p3_out;

reg bit_out;
reg [7:0] data_out, p0_out, p1_out, p2_out, p3_out;

//
// case of writing to port
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    p0_out <= #1 `OC8051_RST_P0;
    p1_out <= #1 `OC8051_RST_P1;
    p2_out <= #1 `OC8051_RST_P2;
    p3_out <= #1 `OC8051_RST_P3;
  end else
    case ({wr, wr_bit})
      2'b10: begin
        case (wr_addr)
//
// byte addresable
          `OC8051_SFR_P0: p0_out <= #1 data_in;
          `OC8051_SFR_P1: p1_out <= #1 data_in;
          `OC8051_SFR_P2: p2_out <= #1 data_in;
          `OC8051_SFR_P3: p3_out <= #1 data_in;
        endcase
      end
      2'b11: begin
        case (wr_addr[7:3])
//
// bit addressable
          `OC8051_SFR_B_P0: p0_out[wr_addr[2:0]] <= #1 bit_in;
          `OC8051_SFR_B_P1: p1_out[wr_addr[2:0]] <= #1 bit_in;
          `OC8051_SFR_B_P2: p2_out[wr_addr[2:0]] <= #1 bit_in;
          `OC8051_SFR_B_P3: p3_out[wr_addr[2:0]] <= #1 bit_in;
        endcase
      end
    endcase
end

always @(p0_out or p0_in or p1_out or p1_in or p2_out or p2_in or p3_out or p3_in)
begin
  if (rmw) begin
    case (rd_addr[5:4])
      2'b00: data_out = p0_out;
      2'b01: data_out = p1_out;
      2'b10: data_out = p2_out;
      2'b11: data_out = p3_out;
    endcase
  end else
    case (rd_addr[5:4])
      2'b00: data_out = p0_in;
      2'b01: data_out = p1_in;
      2'b10: data_out = p2_in;
      2'b11: data_out = p3_in;
    endcase
end

always  @(rmw or rd_addr or p0_out or p1_out or p2_out or p3_out or p0_in or p1_in or p2_in or p3_in)
begin
  if (rmw) begin
    case (rd_addr[7:3])
      `OC8051_SFR_B_P0: bit_out = p0_out[rd_addr[2:0]];
      `OC8051_SFR_B_P1: bit_out = p1_out[rd_addr[2:0]];
      `OC8051_SFR_B_P2: bit_out = p2_out[rd_addr[2:0]];
      default: bit_out = p3_out[rd_addr[2:0]];
    endcase
  end else begin
    case (rd_addr[7:3])
      `OC8051_SFR_B_P0: bit_out = p0_in[rd_addr[2:0]];
      `OC8051_SFR_B_P1: bit_out = p1_in[rd_addr[2:0]];
      `OC8051_SFR_B_P2: bit_out = p2_in[rd_addr[2:0]];
      default: bit_out = p3_in[rd_addr[2:0]];
    endcase
  end
end

endmodule

