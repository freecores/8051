
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: C:\simont\monasm1.hex
/// date: 8/20/2002
/// time: 10:01:59 AM
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

parameter INT_ROM_WID= 10;

input rst, clk;
input [15:0] addr;
output ea_int;
output [7:0] data1, data2, data3;
reg ea_int;
reg [4:0] addr01;
reg [7:0] data1, data2, data3;

wire ea;
wire [15:0] addr_rst;
wire [7:0] int_data0, int_data1, int_data2, int_data3, int_data4, int_data5, int_data6, int_data7, int_data8, int_data9, int_data10, int_data11, int_data12, int_data13, int_data14, int_data15, int_data16, int_data17, int_data18, int_data19, int_data20, int_data21, int_data22, int_data23, int_data24, int_data25, int_data26, int_data27, int_data28, int_data29, int_data30, int_data31;

assign ea = | addr[15:INT_ROM_WID];

assign addr_rst = rst ? 16'h0000 : addr;

  rom0 rom_0 (.a(addr01), .o(int_data0));
  rom1 rom_1 (.a(addr01), .o(int_data1));
  rom2 rom_2 (.a(addr_rst[9:5]), .o(int_data2));
  rom3 rom_3 (.a(addr_rst[9:5]), .o(int_data3));
  rom4 rom_4 (.a(addr_rst[9:5]), .o(int_data4));
  rom5 rom_5 (.a(addr_rst[9:5]), .o(int_data5));
  rom6 rom_6 (.a(addr_rst[9:5]), .o(int_data6));
  rom7 rom_7 (.a(addr_rst[9:5]), .o(int_data7));
  rom8 rom_8 (.a(addr_rst[9:5]), .o(int_data8));
  rom9 rom_9 (.a(addr_rst[9:5]), .o(int_data9));
  rom10 rom_10 (.a(addr_rst[9:5]), .o(int_data10));
  rom11 rom_11 (.a(addr_rst[9:5]), .o(int_data11));
  rom12 rom_12 (.a(addr_rst[9:5]), .o(int_data12));
  rom13 rom_13 (.a(addr_rst[9:5]), .o(int_data13));
  rom14 rom_14 (.a(addr_rst[9:5]), .o(int_data14));
  rom15 rom_15 (.a(addr_rst[9:5]), .o(int_data15));
  rom16 rom_16 (.a(addr_rst[9:5]), .o(int_data16));
  rom17 rom_17 (.a(addr_rst[9:5]), .o(int_data17));
  rom18 rom_18 (.a(addr_rst[9:5]), .o(int_data18));
  rom19 rom_19 (.a(addr_rst[9:5]), .o(int_data19));
  rom20 rom_20 (.a(addr_rst[9:5]), .o(int_data20));
  rom21 rom_21 (.a(addr_rst[9:5]), .o(int_data21));
  rom22 rom_22 (.a(addr_rst[9:5]), .o(int_data22));
  rom23 rom_23 (.a(addr_rst[9:5]), .o(int_data23));
  rom24 rom_24 (.a(addr_rst[9:5]), .o(int_data24));
  rom25 rom_25 (.a(addr_rst[9:5]), .o(int_data25));
  rom26 rom_26 (.a(addr_rst[9:5]), .o(int_data26));
  rom27 rom_27 (.a(addr_rst[9:5]), .o(int_data27));
  rom28 rom_28 (.a(addr_rst[9:5]), .o(int_data28));
  rom29 rom_29 (.a(addr_rst[9:5]), .o(int_data29));
  rom30 rom_30 (.a(addr_rst[9:5]), .o(int_data30));
  rom31 rom_31 (.a(addr_rst[9:5]), .o(int_data31));

always @(addr_rst)
begin
  if (addr_rst[1])
    addr01= addr_rst[9:5]+ 5'h1;
  else
    addr01= addr_rst[9:5];
end

//
// always read tree bits in row
always @(posedge clk)
begin
  case(addr[4:0])
    5'd0: begin
      data1 <= #1 int_data0;
      data2 <= #1 int_data1;
      data3 <= #1 int_data2;
	end
    5'd1: begin
      data1 <= #1 int_data1;
      data2 <= #1 int_data2;
      data3 <= #1 int_data3;
	end
    5'd2: begin
      data1 <= #1 int_data2;
      data2 <= #1 int_data3;
      data3 <= #1 int_data4;
	end
    5'd3: begin
      data1 <= #1 int_data3;
      data2 <= #1 int_data4;
      data3 <= #1 int_data5;
	end
    5'd4: begin
      data1 <= #1 int_data4;
      data2 <= #1 int_data5;
      data3 <= #1 int_data6;
	end
    5'd5: begin
      data1 <= #1 int_data5;
      data2 <= #1 int_data6;
      data3 <= #1 int_data7;
	end
    5'd6: begin
      data1 <= #1 int_data6;
      data2 <= #1 int_data7;
      data3 <= #1 int_data8;
	end
    5'd7: begin
      data1 <= #1 int_data7;
      data2 <= #1 int_data8;
      data3 <= #1 int_data9;
	end
    5'd8: begin
      data1 <= #1 int_data8;
      data2 <= #1 int_data9;
      data3 <= #1 int_data10;
	end
    5'd9: begin
      data1 <= #1 int_data9;
      data2 <= #1 int_data10;
      data3 <= #1 int_data11;
	end
    5'd10: begin
      data1 <= #1 int_data10;
      data2 <= #1 int_data11;
      data3 <= #1 int_data12;
	end
    5'd11: begin
      data1 <= #1 int_data11;
      data2 <= #1 int_data12;
      data3 <= #1 int_data13;
	end
    5'd12: begin
      data1 <= #1 int_data12;
      data2 <= #1 int_data13;
      data3 <= #1 int_data14;
	end
    5'd13: begin
      data1 <= #1 int_data13;
      data2 <= #1 int_data14;
      data3 <= #1 int_data15;
	end
    5'd14: begin
      data1 <= #1 int_data14;
      data2 <= #1 int_data15;
      data3 <= #1 int_data16;
	end
    5'd15: begin
      data1 <= #1 int_data15;
      data2 <= #1 int_data16;
      data3 <= #1 int_data17;
	end
    5'd16: begin
      data1 <= #1 int_data16;
      data2 <= #1 int_data17;
      data3 <= #1 int_data18;
	end
    5'd17: begin
      data1 <= #1 int_data17;
      data2 <= #1 int_data18;
      data3 <= #1 int_data19;
	end
    5'd18: begin
      data1 <= #1 int_data18;
      data2 <= #1 int_data19;
      data3 <= #1 int_data20;
	end
    5'd19: begin
      data1 <= #1 int_data19;
      data2 <= #1 int_data20;
      data3 <= #1 int_data21;
	end
    5'd20: begin
      data1 <= #1 int_data20;
      data2 <= #1 int_data21;
      data3 <= #1 int_data22;
	end
    5'd21: begin
      data1 <= #1 int_data21;
      data2 <= #1 int_data22;
      data3 <= #1 int_data23;
	end
    5'd22: begin
      data1 <= #1 int_data22;
      data2 <= #1 int_data23;
      data3 <= #1 int_data24;
	end
    5'd23: begin
      data1 <= #1 int_data23;
      data2 <= #1 int_data24;
      data3 <= #1 int_data25;
	end
    5'd24: begin
      data1 <= #1 int_data24;
      data2 <= #1 int_data25;
      data3 <= #1 int_data26;
	end
    5'd25: begin
      data1 <= #1 int_data25;
      data2 <= #1 int_data26;
      data3 <= #1 int_data27;
	end
    5'd26: begin
      data1 <= #1 int_data26;
      data2 <= #1 int_data27;
      data3 <= #1 int_data28;
	end
    5'd27: begin
      data1 <= #1 int_data27;
      data2 <= #1 int_data28;
      data3 <= #1 int_data29;
	end
    5'd28: begin
      data1 <= #1 int_data28;
      data2 <= #1 int_data29;
      data3 <= #1 int_data30;
	end
    5'd29: begin
      data1 <= #1 int_data29;
      data2 <= #1 int_data30;
      data3 <= #1 int_data31;
	end
    5'd30: begin
      data1 <= #1 int_data30;
      data2 <= #1 int_data31;
      data3 <= #1 int_data0;
	end
    5'd31: begin
      data1 <= #1 int_data31;
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

always @(posedge clk or posedge rst)
 if (rst)
   ea_int <= #1 1'b1;
  else ea_int <= #1 !ea;

endmodule


//rom0
module rom0 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00028b00" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0009a981" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001a08" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00012038" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002de44" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000aea40" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00084e40" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00013d40" */;
endmodule

//rom1
module rom1 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c48f1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00027114" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d08b8" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00041150" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00034e48" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b4964" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00094a60" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002330" */;
endmodule

//rom2
module rom2 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000260b1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e7585" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004401" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00053030" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ae870" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000bf40d" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00097c48" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00009db5" */;
endmodule

//rom3
module rom3 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0005a36c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000103" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000204f0" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00048b14" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00031535" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000783f1" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000491f0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000006e4" */;
endmodule

//rom4
module rom4 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a1790" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001a98" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e2400" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c2c00" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002e0cc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0006a848" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004e844" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004ae0" */;
endmodule

//rom5
module rom5 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00014848" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a627e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00073924" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d0308" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00025974" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00064fb8" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00044dae" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00011268" */;
endmodule

//rom6
module rom6 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e0148" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a265e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f00d0" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000884b0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003fc4a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ff042" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d4844" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00008a5c" */;
endmodule

//rom7
module rom7 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ca2de" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c1708" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000524a2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003825c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000223b6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fb782" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000da682" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000434" */;
endmodule

//rom8
module rom8 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007eb64" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000000" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00009d74" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a0832" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b1c96" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f899c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004899c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00007d82" */;
endmodule

//rom9
module rom9 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00023c08" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002018" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00046e08" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00040600" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00082f46" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e5f68" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00065b66" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000144" */;
endmodule

//rom10
module rom10 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0009088a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00032030" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008012a" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000188a0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00086d9a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ec4da" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000255ca" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00018808" */;
endmodule

//rom11
module rom11 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f157e" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00070f41" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000c530" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000590e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00098099" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fd611" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007d090" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000142e" */;
endmodule

//rom12
module rom12 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0005aa34" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d200c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000eb200" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c8c30" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00081338" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000faa0a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078200" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000019f4" */;
endmodule

//rom13
module rom13 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000788ea" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001fd0c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000794c2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0005803c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000022e2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007845a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000786da" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004eec" */;
endmodule

//rom14
module rom14 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c250a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003094e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fc110" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d0932" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000017d8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007cc70" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007d030" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000008ae" */;
endmodule

//rom15
module rom15 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00061558" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080d88" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00023064" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a060c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00006722" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00045646" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00045644" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00003964" */;
endmodule

//rom16
module rom16 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00088882" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e19b0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c05a2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fd9a0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00010b72" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c5bde" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c5d4e" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00019540" */;
endmodule

//rom17
module rom17 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b075a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b0044" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00049502" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000020a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00019650" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f8738" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f8724" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000015c2" */;
endmodule

//rom18
module rom18 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002d0b8" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003d060" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002188c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a0870" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00081f7e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b8d6a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00039f48" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004548" */;
endmodule

//rom19
module rom19 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078a6a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00009211" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078b22" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00068408" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000941fb" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000bd277" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003c326" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000288" */;
endmodule

//rom20
module rom20 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a0010" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00058c98" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b8444" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00068056" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008592c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000bcf5c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00038730" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001532" */;
endmodule

//rom21
module rom21 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e0698" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001010" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000030c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00040000" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080c1c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e0448" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000601ca" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002910" */;
endmodule

//rom22
module rom22 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001251a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00021f10" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00061222" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007b478" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001272a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e3466" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00063466" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001e388" */;
endmodule

//rom23
module rom23 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080d6c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002924" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e9568" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0328" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001c92e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ff13c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fdd32" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001122" */;
endmodule

//rom24
module rom24 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d7200" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00091930" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c008c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008820a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000546c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fe5e8" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000da4c8" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000014c0" */;
endmodule

//rom25
module rom25 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000534d0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d2080" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f1458" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00090022" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000295b2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fb676" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f3676" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000011d0" */;
endmodule

//rom26
module rom26 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e3094" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003210c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00030080" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b1a14" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00005efa" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f2aee" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f2ec0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00005ed0" */;
endmodule

//rom27
module rom27 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000012ca" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000811" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c934e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00048c88" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00085ab7" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e5b5b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c5b0a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000088a8" */;
endmodule

//rom28
module rom28 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000900a0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00094450" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b8980" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a040a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000da88" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ee18e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ab39c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00013f5a" */;
endmodule

//rom29
module rom29 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00020144" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e2108" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0006804c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00068234" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080df6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000eac60" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ea4c0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000005fa" */;
endmodule

//rom30
module rom30 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00041512" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a0240" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00060136" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a1400" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004811e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0006d73a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0006093a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00005568" */;
endmodule

//rom31
module rom31 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00061ba8" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00021000" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00060a20" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00040180" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00016f78" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00076eac" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00066e74" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00003db2" */;
endmodule

