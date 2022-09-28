module ARM(input clk,rst,fwd_EN, output [31:0] IFpc,
  output SRAM_WE_N, output [15:0] SRAM_ADDR, inout [63:0] SRAM_DQ);
  
  wire Branch_taken,Hazard_Detected,_freeze,freeze,Two_Src,memReady,notMemReady,memStall,_memStall;
  wire ID_WB_EN,EXE_WB_EN,MEM_WB_EN,WB_WB_EN,writeBackEn;
  wire ID_MEM_R_EN,EXE_MEM_R_EN,MEM_MEM_R_EN,WB_MEM_R_EN;
  wire ID_MEM_W_EN,EXE_MEM_W_EN,MEM_MEM_W_EN;
  wire ID_S,EXE_S,ID_B;
  wire fRnSEXE,fRnSMEM,fRmSEXE,fRmSMEM,stallNeaded;
  wire ID_fRnSEXE,ID_fRnSMEM,ID_fRmSEXE,ID_fRmSMEM;
  wire SRAM_UB_N,SRAM_LB_N,SRAM_CE_N,SRAM_OE_N;
  wire [3:0] Dest_wb,SR,newStatus,src1,src2;
  wire [3:0] ID_EXE_CMD,ID_Dest,EXE_EXE_CMD,EXE_Dest,MEM_EXE_CMD,MEM_Dest,WB_Dest;
  wire [11:0] Shift_operand_IN,Shift_operand;
  wire [23:0] Signed_imm_24_IN,Signed_imm_24;
  wire [31:0] IFinstruction,IDinstructionIn;
  wire [31:0] pre_Val_Rn,pre_Val_Rm,_pre_Val_Rn,_pre_Val_Rm,Val_Rn_IN,Val_Rm_IN,Val_Rn,Val_Rm,MEM_Val_Rm;
  wire [31:0] EXE_ALU_result,MEM_ALU_result,WB_ALU_result;
  wire [31:0] IDpc,EXEpcIn,EXEpcOut,MEMpcIn,MEMpcOut,WBpcIn,WBpcOut;
  wire [31:0] BranchAddr,Result_WB,MEM_result,WB_MEM_result;
      
  IF_Stage ifs(clk,rst,freeze,Branch_taken,BranchAddr,IFpc,IFinstruction);
  IF_Stage_Reg ifsr(clk,rst,freeze,Branch_taken,IFpc,IFinstruction,IDpc,IDinstructionIn);
  
  ID_Stage ids(clk,rst,IDinstructionIn,Result_WB,writeBackEn,Dest_wb,_freeze,SR,
        ID_WB_EN,ID_MEM_R_EN,ID_MEM_W_EN,ID_B,ID_S,ID_EXE_CMD,
        Val_Rn_IN,Val_Rm_IN,imm_IN,Shift_operand_IN,Signed_imm_24_IN,ID_Dest,
        src1,src2,Two_Src,hasRn);
  HazardDetectionUnit hdu(src1,src2,Two_Src,hasRn,EXE_Dest,EXE_WB_EN,MEM_Dest,MEM_WB_EN,Hazard_Detected);
  ForwardingUnit fu(src1,src2,EXE_Dest,MEM_Dest,fwd_EN,Two_Src,hasRn,EXE_WB_EN,EXE_MEM_R_EN,MEM_WB_EN,
                ID_fRnSEXE,ID_fRnSMEM,ID_fRmSEXE,ID_fRmSMEM,stallNeaded);
  ID_Stage_Reg idsr(clk,rst,memStall,Branch_taken,ID_WB_EN,ID_MEM_R_EN,ID_MEM_W_EN,ID_B,ID_S,
        ID_fRnSEXE,ID_fRnSMEM,ID_fRmSEXE,ID_fRmSMEM,ID_EXE_CMD,
        IDpc,Val_Rn_IN,Val_Rm_IN,imm_IN,Shift_operand_IN,Signed_imm_24_IN,ID_Dest,
        EXE_WB_EN,EXE_MEM_R_EN,EXE_MEM_W_EN,Branch_taken,EXE_S,
        fRnSEXE,fRnSMEM,fRmSEXE,fRmSMEM,EXE_EXE_CMD,
        EXEpcIn,pre_Val_Rn,pre_Val_Rm,imm,Shift_operand,Signed_imm_24,EXE_Dest);
        
  and a1(_freeze,Hazard_Detected,stallNeaded);
  or o2(freeze,_freeze,memStall);
  
  Mux #(32) fRn1(pre_Val_Rn,MEM_ALU_result,fRnSEXE,_pre_Val_Rn);
  Mux #(32) fRn2(_pre_Val_Rn,Result_WB,fRnSMEM,Val_Rn);
  Mux #(32) fRm1(pre_Val_Rm,MEM_ALU_result,fRmSEXE,_pre_Val_Rm);
  Mux #(32) fRm2(_pre_Val_Rm,Result_WB,fRmSMEM,Val_Rm);
  
  EXE_Stage exes(clk,EXE_EXE_CMD,EXE_MEM_R_EN,EXE_MEM_W_EN,EXEpcIn,Val_Rn,Val_Rm,imm,
                Shift_operand,Signed_imm_24,SR,EXE_ALU_result,BranchAddr,newStatus);
  EXE_Stage_Reg exesr(clk,rst,memStall,EXE_WB_EN,EXE_MEM_R_EN,EXE_MEM_W_EN,EXE_ALU_result,Val_Rm,EXE_Dest,
                MEM_WB_EN,MEM_MEM_R_EN,MEM_MEM_W_EN,MEM_ALU_result,MEM_Val_Rm,MEM_Dest);
  StatusRegister sr(newStatus,EXE_S,clk,rst,SR);
  
  MEM_Stage ms(clk,rst,MEM_MEM_W_EN,MEM_MEM_R_EN,MEM_ALU_result,MEM_Val_Rm,
                       MEM_result,memReady,
                       SRAM_DQ,SRAM_ADDR,SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N);
  or o1(_memStall,MEM_MEM_W_EN,MEM_MEM_R_EN);
  not n1(notMemReady,memReady);
  and a2(memStall,notMemReady,_memStall);
  MEM_Stage_Reg memsr(clk,rst,memStall,MEM_WB_EN,MEM_MEM_R_EN,MEM_ALU_result,MEM_result,MEM_Dest,
                      writeBackEn,WB_MEM_R_EN,WB_ALU_result,WB_MEM_result,Dest_wb);
  
  WB_Stage wbs(WB_ALU_result,WB_MEM_result,WB_MEM_R_EN,Result_WB);
  
endmodule