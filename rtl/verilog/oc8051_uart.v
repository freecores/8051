module oc8051_uart (rst, clk, bit_in, rd_addr, data_in, bit_out, wr, wr_bit, wr_addr, data_out,
                   rxd, txd, int, t1_ow);

input rst, clk, bit_in, wr, rxd, wr_bit, t1_ow;
input [7:0] rd_addr, data_in, wr_addr;

output txd, int, bit_out;
output [7:0] data_out;

reg txd, bit_out;
reg [7:0] data_out;

reg tr_start, trans, trans_buf, t1_ow_buf, smod_cnt_t, smod_cnt_r, re_start;
reg receive, receive_buf, rxd_buf, r_int;
//
// mode 2 counter
reg [2:0] mode2_count;
reg [7:0] sbuf_rxd, sbuf_txd, scon, pcon;
reg [10:0] sbuf_rxd_tmp;
//
//tr_count	trancive counter
//re_count	receive counter
reg [3:0] tr_count, re_count;

//
// sam_cnt	sample counter
reg [2:0] sam_cnt, sample;

assign int = scon[1] | scon [0];

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
//serial port buffer (receive)
//
always @(posedge clk or posedge rst)
begin
  if (rst)
  begin
    sbuf_rxd <= #1 `OC8051_RST_SBUF;
  end
end

//
//serial port buffer (transmit)
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    sbuf_txd <= #1 `OC8051_RST_SBUF;
    tr_start <= 1'b0;
  end else if ((wr_addr==`OC8051_SFR_SBUF) & (wr) & !(wr_bit)) begin
    sbuf_txd <= #1 data_in;
    tr_start <= #1 1'b1;
   end else
    tr_start <= #1 1'b0;
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
    smod_cnt_t <= #1 1'b0;
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
    smod_cnt_t <= #1 1'b0;
    mode2_count <= #1 3'b000;
//
// transmiting
//
  end else if (trans)
  begin
    case (scon[7:6])
      2'b00: begin //mode 0
        if (tr_count==9'd8)
	begin
	  trans <= #1 1'b0;
	  txd <= #1 1'b1;
	end else begin
	  txd <= #1 sbuf_txd[tr_count];
	  tr_count <= #1 tr_count +1'b1;
	end
      end
      2'b01: begin // mode 1
        if ((t1_ow) & !(t1_ow_buf))
	begin
	  if ((pcon[7]) | (smod_cnt_t))
	  begin
            case (tr_count)
              4'd8: txd <= #1 1'b1;  // stop bit
	      4'd9: trans <= #1 1'b0;
	      4'b1111: txd <= #1 1'b0; //start bit
	      default: txd <= #1 sbuf_txd[tr_count];
	    endcase
            tr_count <= #1 tr_count +1'b1;
	    smod_cnt_t <= #1 1'b0;
	  end else smod_cnt_t <= #1 1'b1;
	end
      end
      2'b10: begin // mode 2
//
// if smod (pcon[7]) is 1 count to 4 else count to 6
//
        if (((pcon[7]) & (mode2_count==3'b011)) | (!(pcon[7]) & (mode2_count==3'b101))) begin
	  case (tr_count)
            4'd8: begin
	      txd <= #1 scon[3];
	    end
            4'd9: begin
	      txd <= #1 1'b1; //stop bit
	      trans <= #1 1'b0;
	    end
	    default: begin
	      txd <= #1 sbuf_txd[tr_count];
	    end
	  endcase
          tr_count <= #1 tr_count+1'b1;
	  mode2_count <= #1 4'd0;
	end else begin
          mode2_count <= #1 mode2_count + 1'b1;
	end
      end
      default: begin // mode 3
        if ((t1_ow) & !(t1_ow_buf))
	begin
	  if ((pcon[7]) | (smod_cnt_t))
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
	    smod_cnt_t <= #1 1'b0;
	  end else smod_cnt_t <= #1 1'b1;
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
// receive
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    sample <= #1 3'b000;
    sam_cnt <= #1 3'b000;
    re_count <= #1 4'd0;
    receive <= #1 1'b0;
    sbuf_rxd <= #1 8'h00;
    sbuf_rxd_tmp <= #1 11'd0;
    smod_cnt_r <= #1 1'b0;
    r_int <= #1 1'b0;
    re_start <= #1 1'b0;
  end else if (receive) begin
    case (scon[7:6])
      2'b00: begin // mode 0
        if (re_count==4'd8) begin
	  receive <= #1 1'b0;
	  r_int <= #1 1'b1;
	  sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
	end else begin
          sbuf_rxd_tmp[re_count+1] <= #1 rxd;
	  r_int <= #1 1'b0;
	end
        re_count <= #1 re_count + 1'b1;
      end
      2'b01: begin // mode 1
        if ((t1_ow) & !(t1_ow_buf))
	begin
	  if ((pcon[7]) | (smod_cnt_r))
	  begin
            sam_cnt <= #1 3'b000;
            r_int <= #1 1'b0;

	    re_count <= #1 re_count +1'b1;
	    smod_cnt_r <= #1 1'b0;
	  end else smod_cnt_r <= #1 1'b1;
	end else begin
	  if (sam_cnt==3'b011) begin
	    if ((sample[0] % sample[1]) | (sample[0] % sample[2]))
	      sbuf_rxd_tmp[re_count] <= #1 sample[0];
	    else
	      sbuf_rxd_tmp[re_count] <= #1 sample[1];
	    if (re_count==4'h9)
	    begin
	      sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
	      receive <= #1 1'b0;
	      r_int <= #1 1'b1;
	    end else r_int <= #1 1'b0;
	  end else begin
	    sample[sam_cnt[1:0]] <= #1 rxd;
	    sam_cnt <= #1 sam_cnt +1'b1;
	    r_int <= #1 1'b0;
	  end
	end
      end
      2'b10: begin // mode 2
        if (((pcon[7]) & (sam_cnt==3'b100)) | (!(pcon[7]) & (sam_cnt==3'b110))) begin
	  if (re_count==4'd11) begin
	      sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
	      r_int <= #1 sbuf_rxd_tmp[0] | !scon[5];
	      receive <= #1 1'b0;
	  end else begin
	    sam_cnt <= #1 3'b001;
	    sample[0] <= #1 rxd;
	    r_int <= #1 1'b0;
	  end
    re_count <= #1 re_count + 1'b1;
	end else begin
	  r_int <= #1 1'b0;

	  if (sam_cnt==3'b011) begin
	    if ((sample[0] % sample[1]) | (sample[0] % sample[2]))
	      sbuf_rxd_tmp[re_count] <= #1 sample[0];
	    else
	      sbuf_rxd_tmp[re_count] <= #1 sample[1];
	  end else begin
	    sample[sam_cnt[1:0]] <= #1 rxd;
	  end
    sam_cnt <= #1 sam_cnt + 1'b1;
	end
      end
      default: begin // mode 3
        if ((t1_ow) & !(t1_ow_buf))
	begin
	  if ((pcon[7]) | (smod_cnt_r))
	  begin
            sam_cnt <= #1 3'b000;

            if (re_count==4'd11) begin
	      sbuf_rxd <= #1 sbuf_rxd_tmp[8:1];
	      receive <= #1 1'b0;
	      r_int <= #1 sbuf_rxd_tmp[0] | !scon[5];
	    end else begin
	      sam_cnt <= #1 3'b000;
	      r_int <= #1 1'b0;
	    end

	    re_count <= #1 re_count +1'b1;
	    smod_cnt_r <= #1 1'b0;
	  end else smod_cnt_r <= #1 1'b1;
	end else begin
	  r_int <= #1 1'b0;
	  if (sam_cnt==3'b011)
	    if ((sample[0] % sample[1]) | (sample[0] % sample[2]))
	      sbuf_rxd_tmp[re_count] <= #1 sample[0];
	    else
	      sbuf_rxd_tmp[re_count] <= #1 sample[1];
	  else begin
	    sample[sam_cnt[1:0]] <= #1 rxd;
	    sam_cnt <= #1 sam_cnt +1'b1;
	  end
	end
      end
    endcase
  end else begin
    case (scon[7:6])
      2'b00: begin
        if ((scon[4]) & !(scon[0]) & !(r_int)) begin
          receive <= #1 1'b1;
        end
      end 
      2'b10: begin
        if ((rxd_buf) & !(rxd)) begin
          receive <= #1 1'b1;
        end  
      end
      default: begin 
        if ((rxd_buf) & !(rxd)) begin
          re_start <= #1 1'b1;
        end else if ((re_start) & (t1_ow) & !(t1_ow_buf)) begin
          re_start <= #1 1'b0;
          receive <= 1'b1;
        end
      end
    endcase
    
    sample <= #1 3'b000;
    sam_cnt <= #1 3'b000;
    re_count <= #1 4'd0;
    sbuf_rxd_tmp <= #1 11'd0;
    r_int <= #1 1'b0;
  end
end

//
//
//
always @(posedge clk)
begin
  if (wr & !wr_bit & (wr_addr==rd_addr) & ((wr_addr==`OC8051_SFR_PCON) |
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


always @(posedge clk)
begin
  trans_buf <= #1 trans;
end

always @(posedge clk)
begin
  receive_buf <= #1 receive;
end

always @(posedge clk)
begin
  t1_ow_buf <= #1 t1_ow;
end

always @(posedge clk)
begin
  rxd_buf <= #1 rxd;
end


always  @(posedge clk)
begin
  if (wr & wr_bit & (rd_addr==wr_addr) & (wr_addr[7:3]==`OC8051_SFR_B_SCON)) begin
    bit_out <= #1 bit_in;
  end else 
    bit_out <= #1 scon[rd_addr[2:0]];

end

endmodule
