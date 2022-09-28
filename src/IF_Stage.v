module IF_Stage(input clk,rst,freeze,Branch_taken,
                input [31:0] BranchAddr,
                output [31:0] PC,Instruction);
  reg [7:0] instructionMem[0:255];
  reg [31:0] pc;
   
  initial begin
    $readmemb("test.data",instructionMem);
  end
    
  always@(posedge clk,posedge rst)begin
    if(rst) begin
      pc<=32'b0;
      $readmemb("test.data",instructionMem);
    end
    else if(freeze)
      pc<=pc;
    else begin
      if(Branch_taken)
        pc<=BranchAddr;
      else pc<=pc+32'd4;
    end
  end
  
  assign PC=pc+32'b00000000000000000000000000000100;
  assign Instruction={instructionMem[pc],instructionMem[pc+1],instructionMem[pc+2],instructionMem[pc+3]};
endmodule