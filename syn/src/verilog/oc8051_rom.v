
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: C:\simont\serial1.hex
/// date: 8/16/2002
/// time: 7:51:31 PM
///

module ROM32X1(O, A0, A1, A2, A3, A4); // synthesis syn_black_box syn_resources="luts=2"
output O;
input A0;
input A1;
input A2;
input A3;
input A4;
endmodule

//rom for 8051 processor

module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);

parameter INT_ROM_WID= 7;

input rst, clk;
input [15:0] addr;
output ea_int;
output [7:0] data1, data2, data3;
reg [4:0] addr01;
reg [7:0] data1, data2, data3;

wire ea;
wire [15:0] addr_rst;
wire [7:0] int_data0, int_data1, int_data2, int_data3;

assign ea = | addr[15:INT_ROM_WID];
assign ea_int = ! ea;

assign addr_rst = rst ? 16'h0000 : addr;

  rom0 rom_0 (.a(addr01), .o(int_data0));
  rom1 rom_1 (.a(addr01), .o(int_data1));
  rom2 rom_2 (.a(addr_rst[6:2]), .o(int_data2));
  rom3 rom_3 (.a(addr_rst[6:2]), .o(int_data3));

always @(addr_rst)
begin
  if (addr_rst[1])
    addr01= addr_rst[6:2]+ 5'h1;
  else
    addr01= addr_rst[6:2];
end

//
// always read tree bits in row
always @(posedge clk)
begin
  case(addr[1:0])
    2'd0: begin
      data1 <= #1 int_data0;
      data2 <= #1 int_data1;
      data3 <= #1 int_data2;
	end
    2'd1: begin
      data1 <= #1 int_data1;
      data2 <= #1 int_data2;
      data3 <= #1 int_data3;
	end
    2'd2: begin
      data1 <= #1 int_data2;
      data2 <= #1 int_data3;
      data3 <= #1 int_data0;
	end
    2'd3: begin
      data1 <= #1 int_data3;
      data2 <= #1 int_data0;
      data3 <= #1 int_data1;
	end
    default: begin
      data1 <= #1 8'h00;
      data2 <= #1 8'h00;
      data3 <= #1 8'h00;
	end
  endcase
end

endmodule


//rom0
module rom0 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002c01" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001800" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000600" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002800" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002400" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001600" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000600" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002a00" */;
endmodule

//rom1
module rom1 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002600" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00003000" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000601" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000400" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00003a00" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002a01" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001200" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001400" */;
endmodule

//rom2
module rom2 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000800" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001000" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001800" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001200" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000e00" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000c00" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000800" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001200" */;
endmodule

//rom3
module rom3 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001c00" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000155" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001400" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000800" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001555" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001555" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001600" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000800" */;
endmodule

