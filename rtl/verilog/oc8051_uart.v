// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"

module oc8051_uart (rst, clk, bit_in, rd_addr, data_in, bit_out, wr, wr_bit, wr_addr, data_out,
                   rxd, txd, intr, t1_ow);

input rst, clk, bit_in, wr, rxd, wr_bit, t1_ow;
input [7:0] rd_addr, data_in, wr_addr;

output txd, intr, bit_out;
output [7:0] data_out;

reg txd, bit_out;
reg [7:0] data_out;

reg tr_start, trans, trans_buf, t1_ow_buf;
reg [5:0] smod_cnt_r, smod_cnt_t; 
reg receive, receive_buf, rxd_buf, r_int;
//
reg [7:0] sbuf_rxd, sbuf_txd, scon, pcon;
reg [10:0] sbuf_rxd_tmp;
//
//tr_count	trancive counter
//re_count	receive counter
reg [3:0] tr_count, re_count, re_count_buff;


assign intr = scon[1] | scon [0];

//
//serial port control register
//
always @(posedge clk or posedge rst)
begin
  if (rst)
    scon <= #1 `OC8051_RST_SCON;
  else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_SCON))
    scon <= #1 data_in;
  else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_SCON))
    scon[wr_addr[2:0]] <= #1 bit_in;
  else if ((trans_buf) & !(trans))
    scon[1] <= #1 1'b1;
  else if ((receive_buf) & !(receive) & !(sbuf_rxd_tmp[0])) begin
    case (scon[7:6])
      2'b00: scon[0] <= #1 1'b1;
      default: begin
        if ((sbuf_rxd_tmp[9]) | !(scon[5])) scon[0] <= #1 1'b1;
	scon[2] <= #1 sbuf_rxd_tmp[9];
      end
    endcase
  end

end

//
//serial port buffer (transmit)
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    sbuf_txd <= #1 `OC8051_RST_SBUF;
    tr_start <= #1 1'b0;
  end else if ((wr_addr==`OC8051_SFR_SBUF) & (wr) & !(wr_bit)) begin
    sbuf_txd <= #1 data_in;
    tr_start <= #1 1'b1;
  end else tr_start <= #1 1'b0;
end

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

//
//power control register
//
always @(posedge clk or posedge rst)
begin
  if (rst)
  begin
    pcon <= #1 `OC8051_RST_PCON;
  end else if ((wr_addr==`OC8051_SFR_PCON) & (wr) & !(wr_bit))
    pcon <= #1 data_in;
end

//
//serial port buffer (receive)
//
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
    trans_buf <= #1 1'b0;
    receive_buf <= #1 1'b0;
    t1_ow_buf <= #1 1'b0;
    rxd_buf <= #1 1'b0;
  end else begin
    trans_buf <= #1 trans;
    receive_buf <= #1 receive;
    t1_ow_buf <= #1 t1_ow;
    rxd_buf <= #1 rxd;
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

always @(posedge clk or posedge rst)
  if (rst)
    re_count_buff <= #1 4'h4;
  else re_count_buff <= #1 re_count;

endmodule

