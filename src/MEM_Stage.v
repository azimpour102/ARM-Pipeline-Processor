module MEM_Stage(input clk,rst,write_en,read_en,
                       input [31:0] address,writeData,
                       output[31:0] readData,output ready,
                       inout [63:0] SRAM_DQ,
                       output [15:0] SRAM_ADDR,
                       output SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N);
                       
  wire miss,cchUpdate;
  wire [31:0] addr,_addr;
  wire [63:0] _writeData,_readData;
  assign _addr={address[31:2],2'b00}-32'd1024;
  
  Mux #(64) m(_readData,{32'b0,writeData},write_en,_writeData);
  
  Cache cch(clk,rst,write_en,read_en,cchUpdate,_addr[18:0],_writeData,miss,readData);
  SRAM_Controller sc(clk,rst,write_en,read_en,miss,_addr,writeData,
                       _readData,ready,cchUpdate,SRAM_DQ,SRAM_ADDR,
                       SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N);
  
endmodule