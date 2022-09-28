`timescale 1ns/1ns
module TB();
  reg clk,rst,fwd_EN,memClk,memRst;
  wire SRAM_WE_N;
  wire [15:0] SRAM_ADDR;
  wire [31:0] IFpc;
  wire [63:0] SRAM_DQ;
  
  ARM cut(clk,rst,fwd_EN,IFpc,SRAM_WE_N,SRAM_ADDR,SRAM_DQ);
  Memory mem(memClk,memRst,SRAM_WE_N,SRAM_ADDR,SRAM_DQ);
  
  initial begin
    fwd_EN=1'b1;
    #10 clk=1; memClk=0; rst=1; memRst=1;
    #10 clk=0; rst=0; memRst=0;
    repeat(1000)begin
      #10 clk=~clk; memClk=~memClk; #10 clk=~clk;
    end
  end
endmodule