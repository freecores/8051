//
// version 1.0
//



//clk  clock (pin)
//rst  reset (pin)
//wr_addr  address for selecting different registers (input)
//data_in  data input (input)
//wr   read/write signal (input)
//tf0  signal for timer interrupt 0 (input)
//tf1  signal for timer interrupt 1 (input)
//ie0   signal for external interrupt 0 (input)
//ie1   signal for external interrupt 1 (input)
//reti  return from interrupt signal (input)
//int_src  describes interrupt source (output)
//ip  ip register (internal)
//ie  ie register (internal)
//tcon  tcon register (internal)
//id  id register (internal)




`include "oc8051_defines.v"

//synopsys translate_off
`include "oc8051_timescale.v"
//synopsys translate_on



module oc0851_int (clk, wr_addr, rd_addr, data_in, bit_in, data_out, bit_out, wr, wr_bit, tf0, tf1, int, ie0, ie1, rst, reti, int_vec, tr0, tr1, uart, ack);
input [7:0] wr_addr, data_in, rd_addr;
input wr, tf0, tf1, ie0, ie1, clk, rst, reti, wr_bit, bit_in, uart, ack;

output tr0, tr1, int, bit_out;
output [7:0] int_vec, data_out;

reg [7:0] ip, ie, int_vec, id, data_out;

reg [3:0] tcon_s;
reg tcon_tf1, tcon_tf0, tcon_ie1, tcon_ie0, bit_out;
wire [7:0] tcon;

//
// isrc_cur	current interrupt source
// isrc_w	waiting interrupt source
reg [2:0] isrc_cur, isrc_w;

//
// contains witch level of interrupts is running
reg [1:0] int_levl, int_levl_w;

//
// int_l0	waiting interrupts on level 0
// int_l1	waiting interrupts on level 1
wire [4:0] int_l0, int_l1;
wire il0, il1;

integer n;


//reg set_tf0, set_tf1, set_ie0, set_ie1;
reg tf0_buff, tf1_buff, ie0_buff, ie1_buff;
//reg tf0_ack, tf1_ack, ie0_ack, ie1_ack;

assign tcon = {tcon_tf1, tcon_s[3], tcon_tf0, tcon_s[2], tcon_ie1, tcon_s[1], tcon_ie0, tcon_s[0]};
assign tr0 = tcon_s[2];
assign tr1 = tcon_s[3];
assign int = |int_vec;

assign int_l0 = ~ip[4:0] & ie[4:0] & {uart, tcon_tf1, tcon_ie1, tcon_tf0, tcon_ie0};
assign int_l1 = ip[4:0] & ie[4:0] & {uart, tcon_tf1, tcon_ie1, tcon_tf0, tcon_ie0};
assign il0 = |int_l0;
assign il1 = |int_l1;

always @(posedge clk or posedge rst)
begin
 if (rst) begin
   ip <=#1 `OC8051_RST_IP;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_IP)) begin
    ip <= #1 data_in;
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_IP))
    ip[wr_addr[2:0]] <= #1 bit_in;
end

always @(posedge clk or posedge rst)
begin
 if (rst) begin
   ie <=#1 `OC8051_RST_IE;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_IE)) begin
    ie <= #1 data_in;
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_IE))
    ie[wr_addr[2:0]] <= #1 bit_in;
end

//
// tcon_s
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
//   tcon_s <=#1 {`OC8051_RST_TCON[6], `OC8051_RST_TCON[4], `OC8051_RST_TCON[2], `OC8051_RST_TCON[0]};
   tcon_s <=#1 4'b0000;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_s <= #1 {data_in[6], data_in[4], data_in[2], data_in[0]};
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_TCON)) begin
   case (wr_addr[2:0])
     3'b000: tcon_s[0] <= #1 bit_in;
     3'b010: tcon_s[1] <= #1 bit_in;
     3'b100: tcon_s[2] <= #1 bit_in;
     3'b110: tcon_s[3] <= #1 bit_in;
   endcase
 end
end

//
// tf1 (tmod.7)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
//   tcon_tf1 <=#1 `OC8051_RST_TCON[7];
   tcon_tf1 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_tf1 <= #1 data_in[7];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b111})) begin
   tcon_tf1 <= #1 bit_in;
 end else if (!(tf1_buff) & (tf1)) begin
   tcon_tf1 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_TF1)) begin
   tcon_tf1 <= #1 1'b0;
 end
end

//
// tf0 (tmod.5)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
//   tcon_tf0 <=#1 `OC8051_RST_TCON[5];
   tcon_tf0 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_tf0 <= #1 data_in[5];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b101})) begin
   tcon_tf0 <= #1 bit_in;
 end else if (!(tf0_buff) & (tf0)) begin
   tcon_tf0 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_TF0)) begin
   tcon_tf0 <= #1 1'b0;
 end
end


//
// ie0 (tmod.1)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
//   tcon_ie0 <=#1 `OC8051_RST_TCON[1];
   tcon_ie0 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_ie0 <= #1 data_in[1];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b001})) begin
   tcon_ie0 <= #1 bit_in;
 end else if (((tcon_s[0]) & (ie0_buff) & !(ie0)) | (!(tcon_s[0]) & !(ie0))) begin
   tcon_ie0 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_IE0) & (tcon_s[0])) begin
   tcon_ie0 <= #1 1'b0;
 end else if (!(tcon_s[0]) & (ie0)) begin
   tcon_ie0 <= #1 1'b0;
 end 
end


//
// ie1 (tmod.3)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
//   tcon_ie1 <=#1 `OC8051_RST_TCON[3];
   tcon_ie1 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_ie1 <= #1 data_in[3];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b011})) begin
   tcon_ie1 <= #1 bit_in;
 end else if (((tcon_s[1]) & (ie1_buff) & !(ie1)) | (!(tcon_s[1]) & !(ie1))) begin
   tcon_ie1 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_IE1) & (tcon_s[1])) begin
   tcon_ie1 <= #1 1'b0;
 end else if (!(tcon_s[1]) & (ie1)) begin
   tcon_ie1 <= #1 1'b0;
 end
end


always @(posedge clk or posedge rst)
begin
 if (rst) begin
   int_vec <= #1 8'h00;
   isrc_cur <= #1 `OC8051_ISRC_NO;
   isrc_w <= #1 `OC8051_ISRC_NO;
   int_levl <= #1 `OC8051_ILEV_NO;
   int_levl_w <= #1 `OC8051_ILEV_NO;
 end else if (reti) begin  // return from interrupt
   isrc_cur <= #1 isrc_w;
   int_levl <= #1 int_levl_w;
 end else if ((ie[7]) & (int_levl!=`OC8051_ILEV_L1) & (il1)) begin  // interrupt on level 1
   isrc_w <= #1 isrc_cur;
   int_levl <= #1 `OC8051_ILEV_L1;
   int_levl_w <= #1 int_levl;
   if (int_l1[0]) begin
     int_vec <= #1 `OC8051_INT_X0;
     isrc_cur <= #1 `OC8051_ISRC_IE0;
   end else if (int_l1[1]) begin
     int_vec <= #1 `OC8051_INT_T0;
     isrc_cur <= #1 `OC8051_ISRC_TF0;
   end else if (int_l1[2]) begin
     int_vec <= #1 `OC8051_INT_X1;
     isrc_cur <= #1 `OC8051_ISRC_IE1;
   end else if (int_l1[3]) begin
     int_vec <= #1 `OC8051_INT_T1;
     isrc_cur <= #1 `OC8051_ISRC_TF1;
   end else if (int_l1[4]) begin
     int_vec <= #1 `OC8051_INT_UART;
     isrc_cur <= #1 `OC8051_ISRC_UART;
   end
 end else if ((ie[7]) & (int_levl==`OC8051_ILEV_NO) & (il0)) begin  // interrupt on level 0
   int_levl <= #1 `OC8051_ILEV_L0;
   if (int_l0[0]) begin
     int_vec <= #1 `OC8051_INT_X0;
     isrc_cur <= #1 `OC8051_ISRC_IE0;
   end else if (int_l0[1]) begin
     int_vec <= #1 `OC8051_INT_T0;
     isrc_cur <= #1 `OC8051_ISRC_TF0;
   end else if (int_l0[2]) begin
     int_vec <= #1 `OC8051_INT_X1;
     isrc_cur <= #1 `OC8051_ISRC_IE1;
   end else if (int_l0[3]) begin
     int_vec <= #1 `OC8051_INT_T1;
     isrc_cur <= #1 `OC8051_ISRC_TF1;
   end else if (int_l0[4]) begin
     int_vec <= #1 `OC8051_INT_UART;
     isrc_cur <= #1 `OC8051_ISRC_UART;
   end
 end else begin
   int_vec <= #1 8'h00;
 end
end


always @(posedge clk)
begin
  if (wr & !wr_bit & (wr_addr==rd_addr) & (
     (wr_addr==`OC8051_SFR_IP) | (wr_addr==`OC8051_SFR_IE) | (wr_addr==`OC8051_SFR_TCON))) begin
    data_out <= #1 data_in;
  end else begin
    case (rd_addr)
      `OC8051_SFR_IP: data_out <= #1 ip;
      `OC8051_SFR_IE: data_out <= #1 ie;
      default: data_out <= #1 tcon;
    endcase
  end
end

always @(posedge clk)
  tf0_buff <= #1 tf0;

always @(posedge clk)
  tf1_buff <= #1 tf1;

always @(posedge clk)
  ie0_buff <= #1 ie0;

always @(posedge clk)
  ie1_buff <= #1 ie1;

always  @(posedge clk)
begin
  if (wr & wr_bit & (wr_addr==rd_addr) & ((wr_addr[7:3]==`OC8051_SFR_B_IP) | 
     (wr_addr[7:3]==`OC8051_SFR_B_IE) | (wr_addr[7:3]==`OC8051_SFR_B_TCON))) begin
    bit_out <= #1 bit_in;
  end else begin
    case (rd_addr[7:3])
      `OC8051_SFR_B_IP: bit_out <= #1 ip[rd_addr[2:0]];
      `OC8051_SFR_B_IE: bit_out <= #1 ie[rd_addr[2:0]];
      default: bit_out <= #1 tcon[rd_addr[2:0]];
    endcase
  end
end


endmodule
