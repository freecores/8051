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
// ver: 1
//
// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_tb;

reg rst, clk, ea;
reg [15:0] pc_in;
reg [7:0] p0_in, p1_in, p2_in, op1, op2, op3;
wire [15:0] ext_addr, rom_addr;
wire  write, write_xram, write_uart, txd, rxd, int_uart, int0, int1, t0, t1, bit_out;
wire [7:0] data_in, data_out, p0_out, p1_out, p2_out, p3_out, data_out_uart, data_out_xram, p3_in;

///
/// buffer for test vectors
///
//
// buffer
reg [23:0] buff [255:0];

integer num;


oc8051_top oc8051_top_1(.rst(rst), .clk(clk), .int0(int0), .int1(int1),
         .data_in(data_in), .data_out(data_out),
         .ext_addr(ext_addr), .rom_addr(rom_addr), .write(write), .p0_in(p0_in),
	 .p1_in(p1_in), .p2_in(p2_in), .p3_in(p3_in), .p0_out(p0_out), .p1_out(p1_out),
	 .p2_out(p2_out), .p3_out(p3_out), .op1(op1), .op2(op2), .op3(op3), .ea(ea),
	 .rxd(rxd), .txd(txd), .t0(t0), .t1(t1));


oc8051_xram oc8051_xram1 (.clk(clk), .wr(write_xram), .addr(ext_addr), .data_in(data_out), .data_out(data_out_xram));

oc8051_uart_test oc8051_uart_test1(.clk(clk), .rst(rst), .addr(ext_addr[7:0]), .wr(write_uart),
                  .wr_bit(p3_out[0]), .data_in(data_out), .data_out(data_out_uart), .bit_out(bit_out), .rxd(txd),
		  .txd(rxd), .ow(p3_out[1]), .int(int_uart));


assign write_xram = p3_out[7] & write;
assign write_uart = !p3_out[7] & write;
assign data_in = p3_out[7] ? data_out_xram : data_out_uart;
assign p3_in = {7'b000000, bit_out, int_uart};
assign t0 = p3_out[5];
assign t1 = p3_out[6];

assign int0 = p3_out[3];
assign int1 = p3_out[4];


initial begin
  clk= 1'b0;
  rst= 1'b1;
//  int0= 1'b1;
//  int1= 1'b1;
  pc_in = 16'h0000;
  p0_in = 8'h00;
  p1_in = 8'h00;
  p2_in = 8'h00;
  op1 = 8'h00;
  op2 = 8'h00;
  op3 = 8'h00;
  ea =1'b1;
#22
  rst = 1'b0;
#2000000
//#500000
  $display("time ",$time, "\n faulire: end of time\n \n");
  $finish;
end

/*initial begin
#222
  int= 1'b1;
  int_v= 8'h50;
#20
  int= 1'b0;
end*/

always clk = #5 ~clk;



initial
  $readmemh("../src/oc8051_test.vec", buff);

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

//initial $monitor("time ",$time," write ", write, " p0_out ", p0_out, " p1_out ", p1_out, " p2_out ", p2_out, " p3_out ", p3_out);

//initial $monitor("time ",$time," write ", write, " p0_out %h", p0_out, " p1_out %h", p1_out, " p2_out %h", p2_out, " p3_out %h", p3_out);

endmodule
