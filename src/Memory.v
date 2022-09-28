`timescale 1ns/1ns
module Memory( input CLK, input RST,
  input SRAM_WE_N,
  input [15:0] SRAM_ADDR,
  inout [63:0] SRAM_DQ
  );
  reg[31:0] memory[0:511];//65535
  assign #30 SRAM_DQ = SRAM_WE_N ? {memory[{SRAM_ADDR[15:1],1'b0}],memory[{SRAM_ADDR[15:1],1'b1}]} : 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
  always@(posedge CLK)begin
    if(~SRAM_WE_N)begin
      memory[SRAM_ADDR] = SRAM_DQ; end
  end
endmodule