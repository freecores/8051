
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: D:\tmp\asm\serial.hex
/// date: 9.7.02
/// time: 10:02:47
///

module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);

parameter INT_ROM_WID= 7;

input rst, clk;
input [15:0] addr;
output ea_int;
output [7:0] data1, data2, data3;
reg [7:0] data1, data2, data3;
reg [7:0] buff [65535:0];
integer i;

wire ea;

assign ea = | addr[15:INT_ROM_WID];
assign ea_int = ! ea;

initial
begin
    for (i=0; i<65536; i=i+1)
      buff [i] = 8'h00;
#2

    buff [16'h00_00] = 8'h74;
    buff [16'h00_01] = 8'h48;
    buff [16'h00_02] = 8'hF5;
    buff [16'h00_03] = 8'h99;
    buff [16'h00_04] = 8'h74;
    buff [16'h00_05] = 8'h0A;
    buff [16'h00_06] = 8'h00;
    buff [16'h00_07] = 8'h14;
    buff [16'h00_08] = 8'h70;
    buff [16'h00_09] = 8'hFC;
    buff [16'h00_0a] = 8'h85;
    buff [16'h00_0b] = 8'h98;
    buff [16'h00_0c] = 8'h80;
    buff [16'h00_0d] = 8'h74;
    buff [16'h00_0e] = 8'h5E;
    buff [16'h00_0f] = 8'h75;
    buff [16'h00_10] = 8'h98;
    buff [16'h00_11] = 8'h80;
    buff [16'h00_12] = 8'hF5;
    buff [16'h00_13] = 8'h99;
    buff [16'h00_14] = 8'h74;
    buff [16'h00_15] = 8'h0F;
    buff [16'h00_16] = 8'h00;
    buff [16'h00_17] = 8'h14;
    buff [16'h00_18] = 8'h70;
    buff [16'h00_19] = 8'hFC;
    buff [16'h00_1a] = 8'h85;
    buff [16'h00_1b] = 8'h98;
    buff [16'h00_1c] = 8'h80;
    buff [16'h00_1d] = 8'h74;
    buff [16'h00_1e] = 8'h5E;
    buff [16'h00_1f] = 8'h75;
    buff [16'h00_20] = 8'h98;
    buff [16'h00_21] = 8'hA0;
    buff [16'h00_22] = 8'hF5;
    buff [16'h00_23] = 8'h99;
    buff [16'h00_24] = 8'h74;
    buff [16'h00_25] = 8'h19;
    buff [16'h00_26] = 8'h00;
    buff [16'h00_27] = 8'h14;
    buff [16'h00_28] = 8'h70;
    buff [16'h00_29] = 8'hFC;
    buff [16'h00_2a] = 8'h85;
    buff [16'h00_2b] = 8'h98;
    buff [16'h00_2c] = 8'h80;
    buff [16'h00_2d] = 8'h74;
    buff [16'h00_2e] = 8'h5E;
    buff [16'h00_2f] = 8'h75;
    buff [16'h00_30] = 8'h98;
    buff [16'h00_31] = 8'h40;
    buff [16'h00_32] = 8'hF5;
    buff [16'h00_33] = 8'h99;
    buff [16'h00_34] = 8'h74;
    buff [16'h00_35] = 8'h14;
    buff [16'h00_36] = 8'h00;
    buff [16'h00_37] = 8'h00;
    buff [16'h00_38] = 8'h00;
    buff [16'h00_39] = 8'h00;
    buff [16'h00_3a] = 8'hF2;
    buff [16'h00_3b] = 8'h14;
    buff [16'h00_3c] = 8'h70;
    buff [16'h00_3d] = 8'hF8;
    buff [16'h00_3e] = 8'h85;
    buff [16'h00_3f] = 8'h98;
    buff [16'h00_40] = 8'h80;
    buff [16'h00_41] = 8'h74;
    buff [16'h00_42] = 8'h5E;
    buff [16'h00_43] = 8'hD2;
    buff [16'h00_44] = 8'h9B;
    buff [16'h00_45] = 8'hF5;
    buff [16'h00_46] = 8'h99;
    buff [16'h00_47] = 8'h74;
    buff [16'h00_48] = 8'h14;
    buff [16'h00_49] = 8'h00;
    buff [16'h00_4a] = 8'h00;
    buff [16'h00_4b] = 8'h00;
    buff [16'h00_4c] = 8'h00;
    buff [16'h00_4d] = 8'hF2;
    buff [16'h00_4e] = 8'h14;
    buff [16'h00_4f] = 8'h70;
    buff [16'h00_50] = 8'hF8;
    buff [16'h00_51] = 8'h85;
    buff [16'h00_52] = 8'h98;
    buff [16'h00_53] = 8'h80;
    buff [16'h00_54] = 8'h74;
    buff [16'h00_55] = 8'h5E;
    buff [16'h00_56] = 8'h75;
    buff [16'h00_57] = 8'h98;
    buff [16'h00_58] = 8'hC0;
    buff [16'h00_59] = 8'hF5;
    buff [16'h00_5a] = 8'h99;
    buff [16'h00_5b] = 8'h74;
    buff [16'h00_5c] = 8'h14;
    buff [16'h00_5d] = 8'h00;
    buff [16'h00_5e] = 8'h00;
    buff [16'h00_5f] = 8'h00;
    buff [16'h00_60] = 8'h00;
    buff [16'h00_61] = 8'hF2;
    buff [16'h00_62] = 8'h14;
    buff [16'h00_63] = 8'h70;
    buff [16'h00_64] = 8'hF8;
    buff [16'h00_65] = 8'h85;
    buff [16'h00_66] = 8'h98;
    buff [16'h00_67] = 8'h80;
    buff [16'h00_68] = 8'h74;
    buff [16'h00_69] = 8'h5E;
    buff [16'h00_6a] = 8'hD2;
    buff [16'h00_6b] = 8'h9B;
    buff [16'h00_6c] = 8'hF5;
    buff [16'h00_6d] = 8'h99;
    buff [16'h00_6e] = 8'h74;
    buff [16'h00_6f] = 8'h14;
    buff [16'h00_70] = 8'h00;
    buff [16'h00_71] = 8'h00;
    buff [16'h00_72] = 8'h00;
    buff [16'h00_73] = 8'h00;
    buff [16'h00_74] = 8'hF2;
    buff [16'h00_75] = 8'h14;
    buff [16'h00_76] = 8'h70;
    buff [16'h00_77] = 8'hF8;
    buff [16'h00_78] = 8'h85;
    buff [16'h00_79] = 8'h98;
    buff [16'h00_7a] = 8'h80;
    buff [16'h00_7b] = 8'h75;
    buff [16'h00_7c] = 8'h80;
    buff [16'h00_7d] = 8'h00;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
