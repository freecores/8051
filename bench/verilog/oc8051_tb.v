//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 top level test bench                                   ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   top level test bench.                                      ////
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
// Revision 1.5  2002/10/17 19:00:50  simont
// add external rom
//
// Revision 1.4  2002/09/30 17:33:58  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_tb;

reg rst, clk;
reg [15:0] pc_in;
reg [7:0] p0_in, p1_in, p2_in;
wire [31:0] idat_i;
wire [15:0] ext_addr, iadr_o;
wire  write, write_xram, write_uart, txd, rxd, int_uart, int0, int1, t0, t1, bit_out, stb_o, ack_i, ack_xram, ack_uart, cyc_o, iack_i, istb_o, icyc_o;
wire [7:0] data_in, data_out, p0_out, p1_out, p2_out, p3_out, data_out_uart, data_out_xram, p3_in;

///
/// buffer for test vectors
///
//
// buffer
reg [23:0] buff [255:0];
reg ea [1:0];

integer num;


//
// oc8051 controller
//
oc8051_top oc8051_top_1(.rst(rst), .clk(clk), .int0(int0), .int1(int1),
         .dat_i(data_in), .dat_o(data_out),
         .adr_o(ext_addr), .iadr_o(iadr_o), .istb_o(istb_o), .iack_i(iack_i),
         .icyc_o(icyc_o), .we_o(write), .p0_in(p0_in),
         .ack_i(ack_i), .stb_o(stb_o), .cyc_o(cyc_o),
	 .p1_in(p1_in), .p2_in(p2_in), .p3_in(p3_in), .p0_out(p0_out), .p1_out(p1_out),
	 .p2_out(p2_out), .p3_out(p3_out), .idat_i(idat_i), .ea(ea[0]),
	 .rxd(rxd), .txd(txd), .t0(t0), .t1(t1));


//
// external data ram
//
oc8051_xram oc8051_xram1 (.clk(clk), .rst(rst), .wr(write_xram), .addr(ext_addr), .data_in(data_out), .data_out(data_out_xram), .ack(ack_xram), .stb(stb_o));


defparam oc8051_xram1.DELAY = 2;

//
// external uart
//
oc8051_uart_test oc8051_uart_test1(.clk(clk), .rst(rst), .addr(ext_addr[7:0]), .wr(write_uart),
                  .wr_bit(p3_out[0]), .data_in(data_out), .data_out(data_out_uart), .bit_out(bit_out), .rxd(txd),
		  .txd(rxd), .ow(p3_out[1]), .intr(int_uart), .stb(stb_o), .ack(ack_uart));

//
// exteranl program rom
//
//    cache
//
//

`ifdef OC8051_CACHE

wire istb_i, icyc_i, iack_o;
wire [15:0] iadr_i;
wire [31:0] idat_o;

oc8051_icache oc8051_icache1(.rst(rst), .clk(clk),
// oc8051
        .adr_i(iadr_o), .dat_o(idat_i), .stb_i(istb_o), .ack_o(iack_i),
        .cyc_i(icyc_o),
// external rom
        .dat_i(idat_o), .stb_o(istb_i), .adr_o(iadr_i), .ack_i(iack_o),
        .cyc_o(icyc_i));

oc8051_xrom oc8051_xrom1(.rst(rst), .clk(clk), .addr(iadr_i), .data(idat_o),
             .stb_i(istb_i), .cyc_i(icyc_i), .ack_o(iack_o));

defparam oc8051_icache1.ADR_WIDTH = 6;  // cache address wihth
defparam oc8051_icache1.LINE_WIDTH = 3; // line address width (2 => 4x32)
defparam oc8051_icache1.BL_NUM = 7; // number of blocks (2^BL_WIDTH-1); BL_WIDTH = ADR_WIDTH - LINE_WIDTH
defparam oc8051_icache1.CACHE_RAM = 64; // cache ram x 32 (2^ADR_WIDTH)


//
//    no cache
//
`else

oc8051_xrom oc8051_xrom1(.rst(rst), .clk(clk), .addr(iadr_o), .data(idat_i),
             .stb_i(istb_o), .cyc_i(icyc_o), .ack_o(iack_i));

`endif
//
//
//

defparam oc8051_xrom1.DELAY = 5;



assign write_xram = p3_out[7] & write;
assign write_uart = !p3_out[7] & write;
assign data_in = p3_out[7] ? data_out_xram : data_out_uart;
assign ack_i = p3_out[7] ? ack_xram : ack_uart;
assign p3_in = {7'b000000, bit_out, int_uart};
assign t0 = p3_out[5];
assign t1 = p3_out[6];

assign int0 = p3_out[3];
assign int1 = p3_out[4];


initial begin
  clk= 1'b0;
  rst= 1'b1;
  pc_in = 16'h0000;
  p0_in = 8'h00;
  p1_in = 8'h00;
  p2_in = 8'h00;
#22
  rst = 1'b0;
//#444000

#7000000
  $display("time ",$time, "\n faulire: end of time\n \n");
  $finish;
end


always clk = #5 ~clk;



initial
  $readmemh("../../../asm/vec/oc8051_test.vec", buff);

initial
  $readmemb("../oc8051_ea.in", ea);


initial num= 0;

always @(p0_out or p1_out or p2_out)
begin
  if ({p0_out, p1_out, p2_out} != buff[num])
  begin
    $display("time ",$time, " faulire: mismatch on ports in step %d", num);
    $display(" p0_out %h", p0_out, " p1_out %h", p1_out, " p2_out %h", p2_out);
    $display(" testvecp %h", buff[num]);
    $display(" p_out   %h%h%h", p0_out, p1_out, p2_out);
#22
    $finish;
  end
  else begin
    $display("time ",$time, " step %d", num, ": pass");
    num =  num+1;
    if (buff[num]===24'hxxxxxx)
    begin
      $display("");
      $display(" Done!");
      $finish;
    end
  end
end


initial $dumpvars;


//initial $monitor("time ",$time," acc %h", data_out, " dptr %h", ext_addr, " write ", write, " p0_out %h", p0_out, " p1_out %h", p1_out);

//initial $monitor("time ",$time, " p0_out ", p0_out);

//initial $monitor("time ",$time," write ", write, " p0_out %h", p0_out, " p1_out %h", p1_out, " p2_out %h", p2_out, " p3_out %h", p3_out);

endmodule
