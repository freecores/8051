// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_fpga_tb;

reg rst, clk, int1, int2, int3;

wire  sw1, sw2, sw3, sw4, int_act;
wire [7:0] p0_out, p1_out, p2_out, p3_out, data_out;
wire [13:0] dispout;
wire [15:0] ext_addr;

oc8051_fpga_top oc8051_fpga_top1(.clk(clk), .rst(rst), .int1(int1), .int2(int2), .int3(int3), .sw1(sw1), .sw2(sw2), .sw3(sw3), .sw4(sw4),
                      .int_act(int_act), .dispout(dispout), .p0_out(p0_out), .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out), .data_out(data_out),
                      .ext_addr(ext_addr));

initial begin
  clk= 1'b0;
  rst= 1'b0;
  int1= 1'b1;
  int2= 1'b1;
  int3= 1'b1;
#22
  rst = 1'b1;
#1000
  int2= 1'b0;
#100
  int2= 1'b1;

#40000
  int3= 1'b0;
#100
  int3= 1'b1;
#40000

  rst = 1'b0;
#20
  $finish;
end

always clk = #5 ~clk;

initial $dumpvars;

//initial $monitor("time ",$time," rst ",rst, " int1 ", int1, " int2 ", int2, " int3 ", int3, " sw1 ", sw1, " sw2 ", sw2, " sw3 ", sw3, " sw4 ", sw4, " int act ", int_act, " p0_out %h", p0_out);

initial $monitor("time ",$time," rst ",rst, " int1 ", int1, " int2 ", int2, " int3 ", int3, " int act ", int_act, " p0_out %h", p0_out);

endmodule
