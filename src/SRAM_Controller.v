module SRAM_Controller(input clk,rst,write_en,read_en,miss,
                       input [31:0] addr,writeData,
                       output[63:0] readData,output reg ready,cchUpdate,
                       inout [63:0] SRAM_DQ,
                       output [15:0] SRAM_ADDR,
                       output SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N);
                       
  
           
  assign SRAM_ADDR={2'b00,addr[15:2]};
  assign readData=SRAM_DQ;
  assign {SRAM_UB_N,SRAM_LB_N,SRAM_CE_N,SRAM_OE_N}='b0;
  
  assign SRAM_WE_N=write_en ? 1'b0 : 1;
  assign SRAM_DQ=read_en ? 64'bz : writeData;
  
  reg [1:0] ns,ps;
  reg [2:0] cnt,cntr;
  
  initial begin
    ns=2'b00;
    cntr=3'b000;
  end
  
  always@(posedge clk)begin
    ps<=ns;
    cnt<=cntr;
  end
  
  always@(*)begin
    if(ps==2'b00)begin
      ready=1'b0;
      cchUpdate=1'b0;
      cntr=3'b000;
      if(write_en || read_en && miss) ns=2'b01;
      else begin
        ns=2'b00;
        if(write_en || read_en) ready=1'b1;
      end  
    end
    if(ps==2'b01)begin
      ready=1'b0;
      cchUpdate=1'b0;
      cntr=cntr+1;
      if(cnt==3'b011) ns=2'b10; else  ns=2'b01;
    end
    if(ps==2'b10)begin
      ready=1'b0;
      cchUpdate=1'b1;
      //cchWrite=read_en;
      //clrValid=write_en&&(!miss);
      ns=2'b11;
    end
    if(ps==2'b11)begin
      ready=1'b1;
      cchUpdate=1'b0;
      cntr=3'b000;
      ns=2'b00;
    end
  end
  
endmodule
