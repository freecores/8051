//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores acccumulator                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   accumulaor register for 8051 core                          ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
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
// Revision 1.9  2003/01/13 14:14:40  simont
// replace some modules
//
// Revision 1.8  2002/11/05 17:23:54  simont
// add module oc8051_sfr, 256 bytes internal ram
//
// Revision 1.7  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_acc (clk, rst, 
                 bit_in, data_in, data2_in, 
		 data_out,
		 wr, wr_bit, wr_addr,
		 p, wr_sfr);


input clk, rst, wr, wr_bit, bit_in;
input [2:0] wr_sfr;
input [7:0] wr_addr, data_in, data2_in;

output p;
output [7:0] data_out;

reg [7:0] data_out;

//
//calculates parity
assign p = ^data_out;

//
//writing to acc
//must check if write high and correct address
always @(posedge clk or posedge rst)
begin
  if (rst)
    data_out <= #1 `OC8051_RST_ACC;
  else if ((wr_sfr==`OC8051_WRS_ACC2) || (wr_sfr==`OC8051_WRS_BA))
    data_out <= #1 data2_in;
  else if ((wr_sfr==`OC8051_WRS_ACC1))
    data_out <= #1 data_in;
  else if (wr) begin
    if (!wr_bit) begin
      if (wr_addr==`OC8051_SFR_ACC)
        data_out <= #1 data_in;
    end else begin
      if (wr_addr[7:3]==`OC8051_SFR_B_ACC)
        data_out[wr_addr[2:0]] <= #1 bit_in;
    end
  end
end

endmodule

