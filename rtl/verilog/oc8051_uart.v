//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores serial interface                                 ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   uart for 8051 core                                         ////
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
// Revision 1.10  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.9  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"

module oc8051_uart (rst, clk, 
             bit_in, data_in,
	     rd_addr, wr_addr,
	     bit_out, data_out,
	     wr, wr_bit,
             rxd, txd, 
	     intr,
             brate2, t1_ow, pres_ow,
	     rclk, tclk);

input        rst,
             clk,
	     bit_in,
	     wr,
	     rxd,
	     wr_bit,
	     t1_ow,
	     brate2,
	     pres_ow,
	     rclk,
	     tclk;
input [7:0]  rd_addr,
             data_in,
	     wr_addr;

output       txd,
             intr,
	     bit_out;
output [7:0] data_out;

reg /*txd, */bit_out;
reg [7:0] data_out;

reg t1_ow_buf;
//reg tr_start, trans, trans_buf, t1_ow_buf;
//reg [5:0] smod_cnt_r, smod_cnt_t;
//reg receive, receive_buf, rxd_buf, r_int;
//
reg [7:0] /*sbuf_rxd, sbuf_txd, */scon, pcon;
//reg [10:0] sbuf_rxd_tmp;
//
//tr_count	trancive counter
//re_count	receive counter
//reg [3:0] tr_count, re_count, re_count_buff;


reg        txd,
           trans,
           receive,
           tx_done,
	   rx_done,
	   rxd_r,
	   shift_tr,
	   shift_re;
reg [1:0]  rx_sam;
reg [3:0]  tr_count,
           re_count;
reg [7:0]  sbuf_rxd;
reg [11:0] sbuf_rxd_tmp;
reg [12:0] sbuf_txd;


assign intr = scon[1] | scon [0];

//
//serial port control register
//
wire ren, tb8, rb8, ri;
assign ren = scon[4];
assign tb8 = scon[3];
assign rb8 = scon[2];
assign ri  = scon[0];

always @(posedge clk or posedge rst)
begin
  if (rst)
    scon <= #1 `OC8051_RST_SCON;
  else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_SCON))
    scon <= #1 data_in;
  else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_SCON))
    scon[wr_addr[2:0]] <= #1 bit_in;
  else if (tx_done)
    scon[1] <= #1 1'b1;
  else if (!rx_done) begin
    if (scon[7:6]==2'b00) begin
      scon[0] <= #1 1'b1;
    end else if ((sbuf_rxd_tmp[11]) | !(scon[5])) begin
      scon[0] <= #1 1'b1;
      scon[2] <= #1 sbuf_rxd_tmp[11];
    end else
      scon[2] <= #1 sbuf_rxd_tmp[11];
  end
end

//
//power control register
//
wire smod;
assign smod = pcon[7];
always @(posedge clk or posedge rst)
begin
  if (rst)
  begin
    pcon <= #1 `OC8051_RST_PCON;
  end else if ((wr_addr==`OC8051_SFR_PCON) & (wr) & !(wr_bit))
    pcon <= #1 data_in;
end


//
//serial port buffer (transmit)
//

wire wr_sbuf;
assign wr_sbuf = (wr_addr==`OC8051_SFR_SBUF) & (wr) & !(wr_bit);

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    txd      <= #1 1'b1;
    tr_count <= #1 4'd0;
    trans    <= #1 1'b0;
    sbuf_txd <= #1 11'h00;
    tx_done  <= #1 1'b0;
//
// start transmiting
//
  end else if (wr_sbuf) begin
    case (scon[7:6])
      2'b00: begin  // mode 0
        sbuf_txd <= #1 {3'b001, data_in};
      end
      2'b01: begin // mode 1
        sbuf_txd <= #1 {2'b01, data_in, 1'b0};
      end
      default: begin  // mode 2 and mode 3
        sbuf_txd <= #1 {1'b1, tb8, data_in, 1'b0};
      end
    endcase
    trans    <= #1 1'b1;
    tr_count <= #1 4'd0;
    tx_done  <= #1 1'b0;
//
// transmiting
//
  end else if (trans & (scon[7:6] == 2'b00) & pres_ow) // mode 0
  begin
    if (~|sbuf_txd[10:1]) begin
      trans   <= #1 1'b0;
      tx_done <= #1 1'b1;
    end else begin
      {sbuf_txd, txd} <= #1 {1'b0, sbuf_txd};
      tx_done         <= #1 1'b0;
    end
  end else if (trans & (scon[7:6] != 2'b00) & shift_tr) begin // mode 1, 2, 3
    tr_count <= #1 tr_count + 4'd1;
    if (~|tr_count) begin
      if (~|sbuf_txd[10:0]) begin
        trans   <= #1 1'b0;
        tx_done <= #1 1'b1;
        txd <= #1 1'b1;
      end else begin
        {sbuf_txd, txd} <= #1 {1'b0, sbuf_txd};
        tx_done         <= #1 1'b0;
      end
    end
  end else if (!trans) begin
    txd     <= #1 1'b1;
    tx_done <= #1 1'b0;
  end
end

//
//
reg sc_clk_tr, smod_clk_tr;
always @(brate2 or t1_ow or t1_ow_buf or scon[7:6] or tclk)
begin
  if (scon[7:6]==8'b10) begin //mode 2
    sc_clk_tr = 1'b1;
  end else if (tclk) begin //
    sc_clk_tr = brate2;
  end else begin //
    sc_clk_tr = !t1_ow_buf & t1_ow;
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    smod_clk_tr <= #1 1'b0;
    shift_tr    <= #1 1'b0;
  end else if (sc_clk_tr) begin
    if (smod) begin
      shift_tr <= #1 1'b1;
    end else begin
      shift_tr    <= #1  smod_clk_tr;
      smod_clk_tr <= #1 !smod_clk_tr;
    end
  end else begin
    shift_tr <= #1 1'b0;
  end
end

/*
//
// transmit
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    txd <= #1 1'b1;
    tr_count <= #1 4'd0;
    trans <= #1 1'b0;
    smod_cnt_t <= #1 6'h0;
//
// start transmiting
//
  end else if (tr_start) begin
    case (scon[7:6])
      2'b00: begin  // mode 0
        txd <= #1 sbuf_txd[0];
	tr_count <= #1 4'd1;
      end
      2'b10: begin
        txd <= #1 1'b0;
	tr_count <= #1 4'd0;
      end
      default: begin  // mode 1 and mode 3
	tr_count <= #1 4'b1111;
      end
    endcase
    trans <= #1 1'b1;
    smod_cnt_t <= #1 6'h0;
//
// transmiting/
//
  end else if (trans)
  begin
    case (scon[7:6])
      2'b00: begin //mode 0
        if (smod_cnt_t == 6'd12) begin
          if (tr_count==4'd8)
          begin
	          trans <= #1 1'b0;
	          txd <= #1 1'b1;
	        end else begin
      	    txd <= #1 sbuf_txd[tr_count];
	          tr_count <= #1 tr_count + 4'b1;
	        end
          smod_cnt_t <= #1 6'h0;
	      end else smod_cnt_t <= #1 smod_cnt_t + 6'h01;
      end
      2'b01: begin // mode 1
        if ((t1_ow) & !(t1_ow_buf))
       	begin
	        if (((pcon[7]) &  (smod_cnt_t == 6'd15))| (!(pcon[7]) & (smod_cnt_t==6'd31)))
	        begin
            case (tr_count)
              4'd8: txd <= #1 1'b1;  // stop bit
	            4'd9: trans <= #1 1'b0;
	            4'b1111: txd <= #1 1'b0; //start bit
	            default: txd <= #1 sbuf_txd[tr_count];
	          endcase
            tr_count <= #1 tr_count + 4'b1;
	          smod_cnt_t <= #1 6'h0;
	        end else smod_cnt_t <= #1 smod_cnt_t + 6'h01;
	      end
      end
      2'b10: begin // mode 2
//
// if smod (pcon[7]) is 1 count to 4 else count to 6
//
        if (((pcon[7]) & (smod_cnt_t==6'd31)) | (!(pcon[7]) & (smod_cnt_t==6'd63))) begin
     	    case (tr_count)
            4'd8: begin
	            txd <= #1 scon[3];
	          end
            4'd9: begin
	            txd <= #1 1'b1; //stop bit
	          end
            4'd10: begin
	            trans <= #1 1'b0;
	          end
            
	          default: begin
	            txd <= #1 sbuf_txd[tr_count];
	          end
	        endcase
          tr_count <= #1 tr_count+1'b1;
	        smod_cnt_t <= #1 6'h00;
	      end else begin
          smod_cnt_t <= #1 smod_cnt_t + 6'h01;
	      end
      end
      default: begin // mode 3
        if ((t1_ow) & !(t1_ow_buf))
	begin
      if (((pcon[7]) &  (smod_cnt_t == 6'd15))| (!(pcon[7]) & (smod_cnt_t==6'd31)))
	  begin
	    case (tr_count)
              4'd8: begin
	        txd <= #1 scon[3];
	      end
              4'd9: begin
	        txd <= #1 1'b1; //stop bit
	      end
              4'd10: begin
          trans <= #1 1'b0;
        end
	      4'b1111: txd <= #1 1'b0; //start bit
	      default: begin
	        txd <= #1 sbuf_txd[tr_count];
	      end
	    endcase
            tr_count <= #1 tr_count+1'b1;
	    smod_cnt_t <= #1 6'h00;
	  end else smod_cnt_t <= #1 smod_cnt_t + 6'h01;
	end
      end
    endcase
  end else
    txd <= #1 1'b1;
end
*/

//
//serial port buffer (receive)
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    re_count     <= #1 4'd0;
    receive      <= #1 1'b0;
    sbuf_rxd     <= #1 8'h00;
    sbuf_rxd_tmp <= #1 12'd0;
    rx_done      <= #1 1'b1;
    rxd_r        <= #1 1'b1;
    rx_sam       <= #1 2'b00;
  end else if (!rx_done) begin
    receive <= #1 1'b0;
    rx_done <= #1 1'b1;
//    if (scon[7:6]==2'b00) begin
      sbuf_rxd <= #1 sbuf_rxd_tmp[10:3];
//    end else begin
//      sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
//    end
  end else if (receive & (scon[7:6]==2'b00) & pres_ow) begin //mode 0
    {sbuf_rxd_tmp, rx_done} <= #1 {rxd, sbuf_rxd_tmp};
  end else if (receive & (scon[7:6]!=2'b00) & shift_re) begin //mode 1, 2, 3
    re_count <= #1 re_count + 4'd1;
    case (re_count)
      4'h7: rx_sam[0] <= #1 rxd;
      4'h8: rx_sam[1] <= #1 rxd;
      4'h9: begin
        {sbuf_rxd_tmp, rx_done} <= #1 {(rxd==rx_sam[0] ? rxd : rx_sam[1]), sbuf_rxd_tmp};
      end
    endcase
//
//start receiving
//
  end else if (scon[7:6]==2'b00) begin //start mode 0
    rx_done <= #1 1'b1;
    if (ren && !ri && !receive) begin
      receive      <= #1 1'b1;
      sbuf_rxd_tmp <= #1 10'h0ff;
    end
  end else if (ren & shift_re) begin
    rxd_r <= #1 rxd;
    rx_done <= #1 1'b1;
    re_count <= #1 4'h0;
    receive <= #1 (rxd_r & !rxd);
    sbuf_rxd_tmp <= #1 10'h1ff;
  end else
    rx_done <= #1 1'b1;
end

//
//
reg sc_clk_re, smod_clk_re;
always @(brate2 or t1_ow or t1_ow_buf or scon[7:6] or rclk)
begin
  if (scon[7:6]==8'b10) begin //mode 2
    sc_clk_re = 1'b1;
  end else if (rclk) begin //
    sc_clk_re = brate2;
  end else begin //
    sc_clk_re = !t1_ow_buf & t1_ow;
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    smod_clk_re <= #1 1'b0;
    shift_re    <= #1 1'b0;
  end else if (sc_clk_re) begin
    if (smod) begin
      shift_re <= #1 1'b1;
    end else begin
      shift_re    <= #1  smod_clk_re;
      smod_clk_re <= #1 !smod_clk_re;
    end
  end else begin
    shift_re <= #1 1'b0;
  end
end


/*
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    re_count <= #1 4'd0;
    receive <= #1 1'b0;
    sbuf_rxd <= #1 8'h00;
    sbuf_rxd_tmp <= #1 11'd0;
    smod_cnt_r <= #1 6'h00;
    r_int <= #1 1'b0;
  end else if (receive) begin
    case (scon[7:6])
      2'b00: begin // mode 0
        if (smod_cnt_r==6'd12) begin
          if (re_count==4'd8) begin
	          receive <= #1 1'b0;
	          r_int <= #1 1'b1;
	          sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
  	      end else begin
            sbuf_rxd_tmp[re_count + 4'd1] <= #1 rxd;
	          r_int <= #1 1'b0;
	        end
          re_count <= #1 re_count + 4'd1;
          smod_cnt_r <= #1 6'h00;
        end else smod_cnt_r <= #1 smod_cnt_r + 6'h01;
      end
      2'b01: begin // mode 1
        if ((t1_ow) & !(t1_ow_buf))
        begin
          if (((pcon[7]) &  (smod_cnt_r == 6'd15))| (!(pcon[7]) & (smod_cnt_r==6'd31)))
	        begin
            r_int <= #1 1'b0;
      	    re_count <= #1 re_count + 4'd1;
            smod_cnt_r <= #1 6'h00;
            sbuf_rxd_tmp[re_count_buff] <= #1 rxd;
            if ((re_count==4'd0) && (rxd))
              receive <= #1 1'b0;

	        end else smod_cnt_r <= #1 smod_cnt_r + 6'h01;
	      end else begin
   	      r_int <= #1 1'b1;
     	    if (re_count == 4'd10)
          begin
     	      sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
            receive <= #1 1'b0;
     	      r_int <= #1 1'b1;
          end else r_int <= #1 1'b0;
        end
      end
      2'b10: begin // mode 2
        if (((pcon[7]) & (smod_cnt_r==6'd31)) | (!(pcon[7]) & (smod_cnt_r==6'd63))) begin
          r_int <= #1 1'b0;
    	    re_count <= #1 re_count + 4'd1;
          smod_cnt_r <= #1 6'h00;
          sbuf_rxd_tmp[re_count_buff] <= #1 rxd;
          re_count <= #1 re_count + 4'd1;
	      end else begin
          smod_cnt_r <= #1 smod_cnt_r + 6'h1;
	        if (re_count==4'd11) begin
	          sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
	          r_int <= #1 sbuf_rxd_tmp[0] | !scon[5];
	          receive <= #1 1'b0;
	        end else 
	          r_int <= #1 1'b0;
        end
      end
      default: begin // mode 3
        if ((t1_ow) & !(t1_ow_buf))
        begin
          if (((pcon[7]) &  (smod_cnt_r == 6'd15))| (!(pcon[7]) & (smod_cnt_r==6'd31)))
	        begin
            sbuf_rxd_tmp[re_count] <= #1 rxd;
	          r_int <= #1 1'b0;
  	        re_count <= #1 re_count + 4'd1;
	          smod_cnt_r <= #1 6'h00;
	        end else smod_cnt_r <= #1 smod_cnt_r + 6'h01;
	      end else begin
          if (re_count==4'd11) begin
            sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
            receive <= #1 1'b0;
	          r_int <= #1 sbuf_rxd_tmp[0] | !scon[5];
	        end else begin
            r_int <= #1 1'b0;
          end
	      end
      end
    endcase
  end else begin
    case (scon[7:6])
      2'b00: begin
        if ((scon[4]) && !(scon[0]) && !(r_int)) begin
          receive <= #1 1'b1;
          smod_cnt_r <= #1 6'h6;
        end
      end
      2'b10: begin
        if ((scon[4]) && !(rxd)) begin
          receive <= #1 1'b1;
          if (pcon[7])
            smod_cnt_r <= #1 6'd15;
          else smod_cnt_r <= #1 6'd31;
        end
      end
      default: begin
        if ((scon[4]) && (!rxd)) begin
          if (pcon[7])
            smod_cnt_r <= #1 6'd7;
          else smod_cnt_r <= #1 6'd15;
          receive <= #1 1'b1;
        end
      end
    endcase

    sbuf_rxd_tmp <= #1 11'd0;
    re_count <= #1 4'd0;
    r_int <= #1 1'b0;
  end
end
*/

//
//
//
always @(posedge clk or posedge rst)
begin
  if (rst) data_out <= #1 8'h0;
  else if (wr & !wr_bit & (wr_addr==rd_addr) & ((wr_addr==`OC8051_SFR_PCON) |
     (wr_addr==`OC8051_SFR_SCON))) begin
    data_out <= #1 data_in;
  end else begin
    case (rd_addr)
      `OC8051_SFR_SBUF: data_out <= #1 sbuf_rxd;
      `OC8051_SFR_PCON: data_out <= #1 pcon;
      default: data_out <= #1 scon;
    endcase
  end
end


always @(posedge clk or posedge rst)
begin
  if (rst) begin
//    trans_buf <= #1 1'b0;
//    receive_buf <= #1 1'b0;
    t1_ow_buf <= #1 1'b0;
//    rxd_buf <= #1 1'b0;
  end else begin
//    trans_buf <= #1 trans;
//    receive_buf <= #1 receive;
    t1_ow_buf <= #1 t1_ow;
//    rxd_buf <= #1 rxd;
  end
end


always  @(posedge clk or posedge rst)
begin
  if (rst) bit_out <= #1 1'b0;
  else if (wr & wr_bit & (rd_addr==wr_addr) & (wr_addr[7:3]==`OC8051_SFR_B_SCON)) begin
    bit_out <= #1 bit_in;
  end else
    bit_out <= #1 scon[rd_addr[2:0]];
end

/*
always @(posedge clk or posedge rst)
  if (rst)
    re_count_buff <= #1 4'h4;
  else re_count_buff <= #1 re_count;
*/

endmodule

