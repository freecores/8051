// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_fpga_top (clk, rst, int1, int2, int3, sw1, sw2, sw3, sw4, int_act, dispout, p0_out, p1_out, p2_out, p3_out, data_out, ext_addr);

input clk, rst, int1, int2, int3;
output sw1, sw2, sw3, sw4, int_act;
output [13:0] dispout;
output [7:0] p0_out, p1_out, p2_out, p3_out, data_out;
output [15:0] ext_addr;


reg int;
reg [7:0] int_v;

wire reti, write;
wire [7:0] data_out;
wire nrst;

reg int_act, ok;

assign nrst = ~rst;

assign sw1 = int1;
assign sw2 = int2;
assign sw3 = int3;
assign sw4 = nrst;

oc8051_top oc8051_top_1(.rst(nrst), .clk(clk), .int(int), .int_v(int_v), .reti(reti), .data_in(8'h00), .data_out(data_out),
         .ext_addr(ext_addr), .write(write), .p0_in(8'hb0), .p1_in(8'hb1), .p2_in(8'hb2), .p3_in(8'hb3), .p0_out(p0_out),
         .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out));


  disp disp1(.in(p0_out), .out(dispout));

always @(posedge clk)
begin
  if (int_act) begin
    int <= #1 1'b0;
  end else if (ok==1'b0) begin
   if (int1==1'b0) begin
	  int_v <= #1 8'h40;
	  int <= #1 1'b1;
    end
   else if (int2==1'b0) begin
	  int_v <= #1 8'h50;
	  int <= #1 1'b1;
    end
   else if (int3==1'b0) begin
	  int_v <= #1 8'h65;
	  int <= #1 1'b1;
    end else int <= #1 1'b0;
  end
end

always @(posedge clk)
begin
  if (nrst)
    int_act <= #1 1'b0;
  else if (reti)
    int_act <= #1 1'b0;
  else if (int)
    int_act <= #1 1'b1;
end

always @(posedge clk)
begin
  case ({int1, int2, int3})
    3'b111: ok <= #1 1'b0;
    default: ok <= #1 1'b1;
  endcase
end

endmodule
