//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores sfr top level module                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   special function registers for oc8051                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
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
// Revision 1.3  2003/01/21 13:51:30  simont
// add include oc8051_defines.v
//
// Revision 1.2  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.1  2002/11/05 17:22:27  simont
// initial import
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_sfr (rst, clk, adr0, adr1, dat0, dat1, dat2, we, bit_in, bit_out, wr_bit,
       wr_sfr, acc, ram_wr_sel, ram_rd_sel, sp, sp_w, bank_sel, desAc, desOv, psw_set, srcAc, cy, rmw,
       p0_out, p1_out, p2_out, p3_out, p0_in, p1_in, p2_in, p3_in, rxd, txd, int_ack, intr, int0,
       int1, reti, int_src, t0, t1, dptr_hi, dptr_lo, t2, t2ex);
//
// rst           (in)  reset - pin
// clk           (in)  clock - pin
// adr0, adr1    (in)  address input
// dat0          (out) data output
// dat1          (in)  data input
// dat2
// we            (in)  write enable
// bit_in
// bit_out
// wr_bit
// ram_rd_sel
// ram_wr_sel
// wr_sfr
//////////
//
//  acc:
// acc
//////////
//
//  sp:
// sp
//////////
//
//  psw:
// bank_sel
// desAc
// desOv
// psw_set
// srcAc
// cy
//////////
//
//  ports:
// rmw
// px_out
// px_in
//////////
//
//  serial interface:
// rxd
// txd
//////////
//
//  interrupt interface:
// int_ack
// intr
// int0, int1
// reti
// int_src
//////////
//
//  timers/counters:
// t0
// t1
// t2
// t2ex
//
//////////
//
//  dptr:
// dptr_hi
// dptr_lo
//
//////////
//




input rst, clk, we, bit_in, desAc, desOv, rmw, rxd, t2, t2ex;
input int_ack, int0, int1, reti, wr_bit, t0, t1;
input [1:0] psw_set;
input [2:0] ram_rd_sel, ram_wr_sel, wr_sfr;
input [7:0] adr0, adr1, dat1, dat2, p0_in, p1_in, p2_in, p3_in;

output bit_out, txd, intr, srcAc, cy;
output [1:0] bank_sel;
output [7:0] dat0, p0_out, p1_out, p2_out, p3_out, int_src, dptr_hi, dptr_lo, acc;
output [7:0] sp, sp_w;


reg bit_out;
reg [7:0] dat0, adr0_r;

reg wr_bit_r;
reg [2:0] ram_wr_sel_r;
wire acc_bit, b_bit, psw_bit, port_bit, uart_bit, int_bit, tc2_bit, pca_bit;
wire p, int_uart, tf0, tf1, tr0, tr1;
wire dps, rclk, tclk, brate2, tc2_int;
wire [7:0] b_reg, psw, ports, uart, int_out, tc_out, tc2, sp_out;


assign cy = psw[7];
assign srcAc = psw [6];



//
// accumulator
// ACC
oc8051_acc oc8051_acc1(.clk(clk), .rst(rst), .bit_in(bit_in), .data_in(dat1),
           .data2_in(dat2), .wr(we), .wr_bit(wr_bit_r), .wr_sfr(wr_sfr),
	   .wr_addr(adr1), .rd_addr(adr0[2:0]), .data_out(acc), .bit_out(acc_bit), .p(p));


//
// b register
// B
oc8051_b_register oc8051_b_register (.clk(clk), .rst(rst), .bit_in(bit_in), .bit_out(b_bit),
           .data_in(dat1), .wr(we), .wr_bit(wr_bit_r), .wr_addr(adr1), .rd_addr(adr0[2:0]),
           .data_out(b_reg), .wr_sfr(wr_sfr));

//
//stack pointer
// SP
oc8051_sp oc8051_sp1(.clk(clk), .rst(rst), .ram_rd_sel(ram_rd_sel), .ram_wr_sel(ram_wr_sel),
		 .wr_addr(adr1), .wr(we), .wr_bit(wr_bit_r), .data_in(dat1),
		 .data_out(sp_out), .sp_out(sp), .sp_w(sp_w));

//
//data pointer
// DPTR, DPH, DPL
oc8051_dptr oc8051_dptr1(.clk(clk), .rst(rst), .addr(adr1), .data_in(dat1),
		.data2_in(dat2), .wr(we), .wr_bit(wr_bit_r),
		.data_hi(dptr_hi), .data_lo(dptr_lo), .wr_sfr(wr_sfr));


//
//program status word
// PSW
oc8051_psw oc8051_psw1 (.clk(clk), .rst(rst), .wr_addr(adr1), .rd_addr(adr0[2:0]), .data_in(dat1),
                .wr(we), .wr_bit(wr_bit_r), .data_out(psw), .bit_out(psw_bit), .p(p), .cy_in(bit_in),
                .ac_in(desAc), .ov_in(desOv), .set(psw_set), .bank_sel(bank_sel));

//
// ports
// P0, P1, P2, P3
oc8051_ports oc8051_ports1(.clk(clk), .rst(rst), .bit_in(bit_in), .data_in(dat1), .wr(we),
		 .wr_bit(wr_bit_r), .wr_addr(adr1), .rd_addr(adr0), .rmw(rmw),
		 .data_out(ports), .bit_out(port_bit), .p0_out(p0_out), .p1_out(p1_out),
		 .p2_out(p2_out), .p3_out(p3_out), .p0_in(p0_in), .p1_in(p1_in), .p2_in(p2_in),
		 .p3_in(p3_in));

//
// serial interface
// SCON, SBUF
oc8051_uart oc8051_uatr1 (.clk(clk), .rst(rst), .bit_in(bit_in), .rd_addr(adr0),
		.data_in(dat1), .wr(we), .wr_bit(wr_bit_r), .wr_addr(adr1),
		.data_out(uart), .bit_out(uart_bit), .rxd(rxd), .txd(txd), .intr(uart_int),
		.t1_ow(tf1));

//
// interrupt control
// IP, IE, TCON
oc8051_int oc8051_int1 (.clk(clk), .rst(rst), .wr_addr(adr1), .rd_addr(adr0), .bit_in(bit_in),
                .ack(int_ack), .data_in(dat1), .data_out(int_out), .bit_out(int_bit),
		.wr(we), .wr_bit(wr_bit_r),
		.tf0(tf0), .tf1(tf1), .t2_int(tc2_int), .tr0(tr0), .tr1(tr1),
		.ie0(int0), .ie1(int1),
		.uart_int(uart_int),
		.reti(reti), .intr(intr), .int_vec(int_src));


//
// timer/counter control
// TH0, TH1, TL0, TH1, TMOD
oc8051_tc oc8051_tc1(.clk(clk), .rst(rst), .wr_addr(adr1), .rd_addr(adr0),
		.data_in(dat1), .wr(we), .wr_bit(wr_bit_r), .ie0(int0), .ie1(int1), .tr0(tr0),
		.tr1(tr1), .t0(t0), .t1(t1), .data_out(tc_out), .tf0(tf0), .tf1(tf1));

//
// timer/counter 2
// TH2, TH2, RCAPL2L, RCAPL2H, T2CON, T2MOD
oc8051_tc2 oc8051_tc21(.clk(clk), .rst(rst), .wr_addr(adr1), .rd_addr(adr0_r), .data_in(dat1), .wr(we),
           .wr_bit(wr_bit_r), .bit_in(bit_in), .t2(t2), .t2ex(t2ex), .data_out(tc2), .bit_out(tc2_bit),
           .rclk(rclk), .tclk(tclk), .brate2(brate2), .tc2_int(tc2_int));



always @(posedge clk or posedge rst)
  if (rst) begin
    adr0_r <= #1 8'h00;
    ram_wr_sel_r <= #1 3'b000;
    wr_bit_r <= #1 1'b0;
  end else begin
    adr0_r <= #1 adr0;
    ram_wr_sel_r <= #1 ram_wr_sel;
    wr_bit_r <= #1 wr_bit;
  end

//
//set output in case of address (byte)
always @(adr0_r or psw or acc or dptr_hi or ports or sp_out or b_reg or uart or
         tc_out or tc2 or int_out or dptr_lo)
begin
    case (adr0_r)
      `OC8051_SFR_ACC: dat0 = acc;
      `OC8051_SFR_PSW: dat0 = psw;
      `OC8051_SFR_P0: dat0 = ports;
      `OC8051_SFR_P1: dat0 = ports;
      `OC8051_SFR_P2: dat0 = ports;
      `OC8051_SFR_P3: dat0 = ports;
      `OC8051_SFR_SP: dat0 = sp_out;
      `OC8051_SFR_B: dat0 = b_reg;
      `OC8051_SFR_DPTR_HI: dat0 = dptr_hi;
      `OC8051_SFR_DPTR_LO: dat0 = dptr_lo;
      `OC8051_SFR_SCON: dat0 = uart;
      `OC8051_SFR_SBUF: dat0 = uart;
      `OC8051_SFR_PCON: dat0 = uart;
      `OC8051_SFR_TH0: dat0 = tc_out;
      `OC8051_SFR_TH1: dat0 = tc_out;
      `OC8051_SFR_TL0: dat0 = tc_out;
      `OC8051_SFR_TL1: dat0 = tc_out;
      `OC8051_SFR_TMOD: dat0 = tc_out;
      `OC8051_SFR_IP: dat0 = int_out;
      `OC8051_SFR_IE: dat0 = int_out;
      `OC8051_SFR_TCON: dat0 = int_out;
      `OC8051_SFR_RCAP2H: dat0 = tc2;
      `OC8051_SFR_RCAP2L: dat0 = tc2;
      `OC8051_SFR_TH2:    dat0 = tc2;
      `OC8051_SFR_TL2:    dat0 = tc2;
      `OC8051_SFR_T2MOD:  dat0 = tc2;
      `OC8051_SFR_T2CON:  dat0 = tc2;

      default: dat0 = 8'h00;
    endcase
end


//
//set output in case of address (bit)
always @(adr0_r or b_bit or acc_bit or psw_bit or int_bit or port_bit or uart_bit or tc2_bit)
begin
    case (adr0_r[7:3])
      `OC8051_SFR_B_ACC: bit_out = acc_bit;
      `OC8051_SFR_B_PSW: bit_out = psw_bit;
      `OC8051_SFR_B_P0: bit_out = port_bit;
      `OC8051_SFR_B_P1: bit_out = port_bit;
      `OC8051_SFR_B_P2: bit_out = port_bit;
      `OC8051_SFR_B_P3: bit_out = port_bit;
      `OC8051_SFR_B_B: bit_out = b_bit;
      `OC8051_SFR_B_IP: bit_out = int_bit;
      `OC8051_SFR_B_IE: bit_out = int_bit;
      `OC8051_SFR_B_TCON: bit_out = int_bit;
      `OC8051_SFR_B_SCON: bit_out = uart_bit;
      `OC8051_SFR_B_T2CON: bit_out = tc2_bit;
      default: bit_out = 1'b0;
    endcase
end

endmodule
