//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores top level module                                 ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Interrupt prioriti register                                ////
////   timer/counter                                              ////
////   serial port                                                ////
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


module oc8051_top (rst, clk, int0, int1, ea, rom_addr, op1, op2, op3, data_in,
		data_out, ext_addr, write, p0_in, p1_in, p2_in, p3_in, p0_out,
		p1_out, p2_out, p3_out, rxd, txd, t0, t1);
//
// rst           (in)  reset - pin
// clk           (in)  clock - pin
// rom_addr      (out) program rom addres (pin + internal)
// int0           (in)  external interrupt 0
// int1           (in)  external interrupt 1
// data_in       (in)  exteranal ram input
// data_out      (out) exteranal ram output
// ext_addr      (out) external address
// write         (out) write to external ram
// p0_in, p1_in, p2_in, p3_in           (in)  port inputs
// p0_out, p1_out, p2_out, p3_out       (out) port outputs
// rxd		 (in) receive
// txd		 (out) transmit
// t0, t1	 (in)  t/c external inputs
//
//



input rst, clk, int0, int1, ea, rxd, t0, t1;
input [7:0] data_in, p0_in, p1_in, p2_in, p3_in, op1, op2, op3;

output write, txd;
output [7:0] data_out, p0_out, p1_out, p2_out, p3_out;
//output [15:0] rom_addr, ext_addr;
output [15:0] ext_addr, rom_addr;

wire [7:0] op1_i, op2_i, op3_i, dptr_hi, dptr_lo, ri, data_out;
wire [7:0] acc, b_reg, p0_out, p1_out, p2_out, p3_out, uart, tc_out, int_out;

wire [15:0] rom_addr, pc, ext_addr;

//
// data output is always from accumulator
assign data_out = acc;

//
// ram_rd_sel    ram read (internal)
// ram_wr_sel    ram write (internal)
// src_sel1, src_sel2    from decoder to register
// imm_sel       immediate select
wire [1:0] ram_rd_sel, src_sel1, src_sel2;
wire [2:0] ram_wr_sel, ram_wr_sel_r, imm_sel;

//
// wr_addr       ram write addres
// ram_out       data from ram
// sp            stack pointer output
// rd_addr       data ram read addres
// rd_addr_r     data ram read addres registerd
wire [7:0] wr_addr, ram_data, ram_out, sp, rd_addr, rd_addr_r, ports_in;


//
// src_sel1_r, src_sel2_r       src select, registred
// cy_sel       carry select; from decoder to cy_selct1
// rom_addr_sel rom addres select; alu or pc
// ext_adddr_sel        external addres select; data pointer or Ri
// write_p      output from decoder; write to external ram, go to register;
wire [1:0] src_sel1_r, src_sel2_r, cy_sel, cy_sel_r;
wire src_sel3, src_sel3_r, rom_addr_sel, ext_addr_sel, write_p, rmw, ea_int;

//
// int_uart	interrupt from uart
// tf0		interrupt from t/c 0
// tf1		interrupt from t/c 1
// tr0		timer 0 run
// tr1		timer 1 run
wire int_uart, tf0, tf1, tr0, tr1, reti, int, ack;
wire [7:0] int_src;

//
//alu_op        alu operation (from decoder)
//alu_op_r      alu operation (registerd)
//psw_set       write to psw or not; from decoder to psw (through register)
wire [3:0] alu_op, alu_op_r; wire [1:0] psw_set, psw_set_r;

//
// immediate1, immediate1_r        from imediate_sel1 to alu_src1_sel1
// immediate2, immediate2_r        from imediate_sel1 to alu_src2_sel1
// src1. src2, src2     alu sources
// des2, des2           alu destinations
// des1_r               destination 1 registerd (to comp1)
// psw                  output from psw
// desCy                carry out
// desAc
// desOv                overflow
// wr, wr_r             write to data ram
wire [7:0] src1, src2, src3, des1, des2, des1_r, psw;
wire desCy, desAc, desOv, alu_cy, wr, wr_r;
wire [7:0] immediate1, immediate1_r, immediate2, immediate2_r;


//
// rd           read program rom
// pc_wr_sel    program counter write select (from decoder to pc)
wire rd;
wire [1:0] pc_wr_sel;

//
// op1_n                from op_select to decoder
// op2_n, op2_nr        output of op_select, to immediate_sel1, pc1, comp1
// op3_n,         output of op_select, to immediate_sel1, ram_wr_sel1
// op2_dr,      output of op_select, to ram_rd_sel1, ram_wr_sel1
wire [7:0] op1_n, op2_n, op2_dr, op3_n, op2_nr, pc_hi_r;
wire [7:0] sp_r, op2_dr_r, ri_r, op3_nr;
wire [2:0] op1_r;

//
// comp_sel     select source1 and source2 to compare
// eq           result (from comp1 to decoder)
// wad2, wad2_r write to accumulator from destination 2
wire [2:0] comp_sel;
wire eq, wad2, wad2_r;


//
// bit_addr     bit addresable instruction
// bit_data     bit data from ram to ram_select
// bit_out      bit data from ram_select to alu and cy_select
wire bit_addr, bit_data, bit_out, bit_addr_r;

//
// p     parity from accumulator to psw
wire p;
wire b_bit, acc_bit, psw_bit, int_bit, port_bit, uart_bit;


//
//registers
oc8051_reg8 oc8051_reg8_pc_hi(.clk(clk), .rst(rst), .in(pc[15:8]), .out(pc_hi_r));
oc8051_reg1 oc8051_reg1_write(.clk(clk), .rst(rst), .in(write_p), .out(write));

oc8051_reg2 oc8051_reg2_src_sel1(.clk(clk), .rst(rst), .in(src_sel1), .out(src_sel1_r));
oc8051_reg2 oc8051_reg2_src_sel2(.clk(clk), .rst(rst), .in(src_sel2), .out(src_sel2_r));
oc8051_reg1 oc8051_reg1_sre_sel3(.clk(clk), .rst(rst), .in(src_sel3), .out(src_sel3_r));

oc8051_reg1 oc8051_reg1_wr (.clk(clk), .rst(rst), .in(wr), .out(wr_r));
//oc8051_reg8 oc8051_reg8_wr_addr (.clk(clk), .rst(rst), .in(wr_addr1), .out(wr_addr_r));
oc8051_reg3 oc8051_reg3_wr_sel(.clk(clk), .rst(rst), .in(ram_wr_sel), .out(ram_wr_sel_r));
oc8051_reg8 oc8051_reg8_ram_op(.clk(clk), .rst(rst), .in(op2_n), .out(op2_nr));
oc8051_reg8 oc8051_reg8_sp(.clk(clk), .rst(rst), .in(sp), .out(sp_r));
oc8051_reg3 oc8051_reg3_op1(.clk(clk), .rst(rst), .in(op1_n[2:0]), .out(op1_r));
oc8051_reg8 oc8051_reg8_op2(.clk(clk), .rst(rst), .in(op2_dr), .out(op2_dr_r));
oc8051_reg8 oc8051_reg8_ri(.clk(clk), .rst(rst), .in(ri), .out(ri_r));
oc8051_reg8 oc8051_reg8_op3(.clk(clk), .rst(rst), .in(op3_n), .out(op3_nr));
//oc8051_reg5 oc8051_reg5_rn(.clk(clk), .rst(rst), .in({psw[4:3], op1_n[2:0]}), .out(rn_r));

oc8051_reg4 oc8051_reg4_alu_op(.clk(clk), .rst(rst), .in(alu_op), .out(alu_op_r));

oc8051_reg8 oc8051_reg8_imm1(.clk(clk), .rst(rst), .in(immediate1), .out(immediate1_r));
oc8051_reg8 oc8051_reg8_imm2(.clk(clk), .rst(rst), .in(immediate2), .out(immediate2_r));
oc8051_reg1 oc8051_reg1_bit_addr(.clk(clk), .rst(rst), .in(bit_addr), .out(bit_addr_r));

oc8051_reg1 oc8051_reg1_wad2(.clk(clk), .rst(rst), .in(wad2), .out(wad2_r));
oc8051_reg8 oc8051_reg8_des1(.clk(clk), .rst(rst), .in(des1), .out(des1_r));
oc8051_reg2 oc8051_reg2_cy(.clk(clk), .rst(rst), .in(cy_sel), .out(cy_sel_r));
oc8051_reg2 oc8051_psw_reg (.clk(clk), .rst(rst), .in(psw_set), .out(psw_set_r));
//oc8051_reg8 oc8051_op2_dr_reg (.clk(clk), .rst(rst), .in(op2_dr), .out(op2_dr_r));
oc8051_reg8 oc8051_reg8_rd_ram (.clk(clk), .rst(rst), .in(rd_addr), .out(rd_addr_r));

//
//program counter
oc8051_pc oc8051_pc1(.rst(rst), .clk(clk), .pc_out(pc), .alu({des2,des1}),
       .pc_wr_sel(pc_wr_sel), .op1(op1_n), .op2(op2_n), .op3(op3_n), .wr(pc_wr),
       .rd(rd), .int(int));

//
// decoder
oc8051_decoder oc8051_decoder1(.clk(clk), .rst(rst), .op_in(op1_n), .ram_rd_sel(ram_rd_sel),
		 .ram_wr_sel(ram_wr_sel), .bit_addr(bit_addr), .src_sel1(src_sel1),
		 .src_sel2(src_sel2), .src_sel3(src_sel3), .alu_op(alu_op), .psw_set(psw_set),
		 .imm_sel(imm_sel), .cy_sel(cy_sel), .wr(wr), .pc_wr(pc_wr), .pc_sel(pc_wr_sel),
		 .comp_sel(comp_sel), .eq(eq), .rom_addr_sel(rom_addr_sel), .ext_addr_sel(ext_addr_sel),
		.wad2(wad2), .rd(rd), .write_x(write_p), .reti(reti), .rmw(rmw));



//
// ram red and ram write select
oc8051_ram_rd_sel oc8051_ram_rd_sel1 (.sel(ram_rd_sel),  .sp(sp), .ri(ri),
		.rn({psw[4:3], op1_n[2:0]}), .imm(op2_dr), .out(rd_addr));

oc8051_ram_wr_sel oc8051_ram_wr_sel1 (.sel(ram_wr_sel_r),  .sp(sp_r),
         .rn({psw[4:3], op1_r}), .imm(op2_dr_r), .ri(ri_r), .imm2(op3_nr), .out(wr_addr));


//
//alu
oc8051_alu oc8051_alu1(.op_code(alu_op_r), .src1(src1), .src2(src2), .src3(src3),
         .srcCy(alu_cy), .srcAc(psw[6]), .des1(des1), .des2(des2), .desCy(desCy),
	 .desAc(desAc), .desOv(desOv), .bit_in(bit_out));


//
//
oc8051_immediate_sel oc8051_immediate_sel1(.sel(imm_sel), .op1(op1_n), .op2(op2_n),
          .op3(op3_n), .pch(pc_hi_r), .pcl(pc[7:0]), .out1(immediate1), .out2(immediate2));

//
//data ram
oc8051_ram_top oc8051_ram_top1(.clk(clk), .rst(rst), .rd_addr(rd_addr), .rd_data(ram_data),
          .wr_addr(wr_addr), .bit_addr(bit_addr), .wr_data(des1), .wr(wr_r),
	  .bit_data_in(desCy), .bit_data_out(bit_data));

//
//
oc8051_acc oc8051_acc1(.clk(clk), .rst(rst), .bit_in(desCy), .data_in(des1),
           .data2_in(des2), .wr(wr_r), .wr_bit(bit_addr_r), .wad2(wad2_r),
	   .wr_addr(wr_addr), .rd_addr(rd_addr[2:0]), .data_out(acc), .bit_out(acc_bit), .p(p));


//
//
oc8051_b_register oc8051_b_register (.clk(clk), .rst(rst), .bit_in(desCy), .bit_out(b_bit), .data_in(des1),
                    .wr(wr_r), .wr_bit(bit_addr_r), .wr_addr(wr_addr), .rd_addr(rd_addr[2:0]), .data_out(b_reg));

//
//
oc8051_alu_src1_sel oc8051_alu_src1_sel1(.sel(src_sel1_r), .immediate(immediate1_r),
		.acc(acc), .ram(ram_out), .ext(data_in), .des(src1));
oc8051_alu_src2_sel oc8051_alu_src2_sel1(.sel(src_sel2_r), .immediate(immediate2_r),
		.acc(acc), .ram(ram_out), .des(src2));
oc8051_alu_src3_sel oc8051_alu_src3_sel1(.sel(src_sel3_r), .pc(pc_hi_r),
		.dptr(dptr_hi), .out(src3));

//
//
oc8051_comp oc8051_comp1(.sel(comp_sel), .eq(eq), .b_in(bit_out), .cy(psw[7]), .acc(acc),
		.ram(ram_out), .op2(op2_nr), .des(des1_r));

//
//stack pointer
oc8051_sp oc8051_sp1(.clk(clk), .rst(rst), .ram_rd_sel(ram_rd_sel), .ram_wr_sel(ram_wr_sel),
		 .wr_addr(wr_addr), .wr(wr_r), .wr_bit(bit_addr_r), .data_in(des1),
		 .data_out(sp));

//
//program rom
oc8051_rom oc8051_rom1(.rst(rst), .clk(clk), .ea_int(ea_int), .addr(rom_addr), 
		.data1(op1_i), .data2(op2_i), .data3(op3_i));

//
//data pointer
oc8051_dptr oc8051_dptr1(.clk(clk), .rst(rst), .addr(wr_addr), .data_in(des1), 
		.data2_in(des2), .wr(wr_r), .wr_bit(bit_addr_r), .wd2(ram_wr_sel_r),
		.data_hi(dptr_hi), .data_lo(dptr_lo));

//
//
oc8051_cy_select oc8051_cy_select1(.cy_sel(cy_sel_r), .cy_in(psw[7]), .data_in(bit_out),
		 .data_out(alu_cy));

//
//program status word
oc8051_psw oc8051_psw1 (.clk(clk), .rst(rst), .wr_addr(wr_addr), .rd_addr(rd_addr[2:0]), .data_in(des1), .wr(wr_r),
		.wr_bit(bit_addr_r), .data_out(psw), .bit_out(psw_bit), .p(p), .cy_in(desCy),
		.ac_in(desAc), .ov_in(desOv), .set(psw_set_r));

//
//
oc8051_indi_addr oc8051_indi_addr1 (.clk(clk), .rst(rst), .addr(wr_addr), .data_in(des1),
		 .wr(wr_r), .wr_bit(bit_addr_r), .data_out(ri), .sel(op1_n[0]), 
		 .bank(psw[4:3]));

//
//
oc8051_rom_addr_sel oc8051_rom_addr_sel1(.rst(rst), .clk(clk), .select(rom_addr_sel), 
		.des1(des1), .des2(des2), .pc(pc), .out_addr(rom_addr));

//
//
oc8051_ext_addr_sel oc8051_ext_addr_sel1(.clk(clk), .select(ext_addr_sel), .write(write_p),
		 .dptr_hi(dptr_hi), .dptr_lo(dptr_lo), .ri(ri), .addr_out(ext_addr));

//
//
oc8051_ram_sel oc8051_ram_sel1(.addr(rd_addr_r), .bit_in(bit_data), .in_ram(ram_data),
		.psw(psw), .acc(acc), .dptr_hi(dptr_hi), .ports_in(ports_in), .sp(sp),
		.b_reg(b_reg), .uart(uart), .int(int_out), .tc(tc_out), .b_bit(b_bit),
		.acc_bit(acc_bit), .psw_bit(psw_bit), .int_bit(int_bit), .port_bit(port_bit),
		.uart_bit(uart_bit), .bit_out(bit_out), .out_data(ram_out));

//
//
oc8051_ports oc8051_ports1(.clk(clk), .rst(rst), .bit_in(desCy), .data_in(des1), .wr(wr_r),
		 .wr_bit(bit_addr_r), .wr_addr(wr_addr), .rd_addr(rd_addr), .rmw(rmw),
		 .data_out(ports_in), .bit_out(port_bit), .p0_out(p0_out), .p1_out(p1_out), .p2_out(p2_out),
		 .p3_out(p3_out), .p0_in(p0_in), .p1_in(p1_in), .p2_in(p2_in), .p3_in(p3_in));

//
//
oc8051_op_select oc8051_op_select1(.clk(clk), .rst(rst), .ea(ea), .ea_int(ea_int), .op1_i(op1_i),
		.op2_i(op2_i), .op3_i(op3_i), .op1_x(op1), .op2_x(op2), .op3_x(op3),
		.op1_out(op1_n), .op2_out(op2_n), .op2_direct(op2_dr), .op3_out(op3_n),
		.int(int), .int_v(int_src), .rd(rd), .ack(ack));

//
// serial interface
oc8051_uart oc8051_uatr1 (.clk(clk), .rst(rst), .bit_in(desCy), .rd_addr(rd_addr),
		.data_in(des1), .wr(wr_r), .wr_bit(bit_addr_r), .wr_addr(wr_addr),
		.data_out(uart), .bit_out(uart_bit), .rxd(rxd), .txd(txd), .int(int_uart), .t1_ow(tf1));


oc0851_int oc8051_int1(.clk(clk), .rst(rst), .wr_addr(wr_addr), .rd_addr(rd_addr), .bit_in(desCy), .ack(ack),
		.int(int), .data_in(des1), .data_out(int_out), .bit_out(int_bit), .wr(wr_r), .wr_bit(bit_addr_r), .tf0(tf0), .tf1(tf1),
		.ie0(int0), .ie1(int1), .reti(reti), .int_vec(int_src), .tr0(tr0), .tr1(tr1), .uart(int_uart));

oc8051_tc oc8051_tc1(.clk(clk), .rst(rst), .wr_addr(wr_addr), .rd_addr(rd_addr),
		.data_in(des1), .wr(wr_r), .wr_bit(bit_addr_r), .ie0(int0), .ie1(int1), .tr0(tr0),
		.tr1(tr1), .t0(t0), .t1(t1), .data_out(tc_out), .tf0(tf0), .tf1(tf1));

endmodule
