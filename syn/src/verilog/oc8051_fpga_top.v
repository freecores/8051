// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_fpga_top (clk, rst, int1, int2, dispout, p0_out, p1_out, p2_out, p3_out, data_out, ext_addr, rom_addr, 
                      rxd, txd, t0, t1);

input clk, rst, int1, int2, rxd, t0, t1;
output txd;
output [13:0] dispout;
output [7:0] p0_out, p1_out, p2_out, p3_out, data_out;
output [15:0] ext_addr, rom_addr;



wire write, stb_o, cyc_o;
wire [7:0] data_out, op1, op2, op3;
wire nrst;

assign nrst = ~rst;

assign op1 = 8'h00;
assign op2 = 8'h00;
assign op3 = 8'h00;

oc8051_top oc8051_top_1(.rst(nrst), .clk(clk), .int0(int1), .int1(int2), .ea(1'b1), .rom_addr(rom_addr), .dat_i(8'h00), .dat_o(data_out),
         .op1(op1), .op2(op2), .op3(op3), .adr_o(ext_addr), .we_o(write), .ack_i(1'b1), .stb_o(stb_o), .cyc_o(cyc_o),
         .p0_in(8'hb0), .p1_in(8'hb1), .p2_in(8'hb2), .p3_in(8'hb3), .p0_out(p0_out),
         .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out), .rxd(rxd), .txd(txd), .t0(t0), .t1(t1));


  disp disp1(.in(p0_out), .out(dispout));

endmodule
