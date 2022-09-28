module ForwardingUnit(input [3:0] src1,src2,EXE_Dest,MEM_Dest,
                      input fwd_EN,Two_Src,hasRn,EXE_WB_EN,EXE_MEM_R_EN,MEM_WB_EN,
                      output reg fRnSEXE,fRnSMEM,fRmSEXE,fRmSMEM,stallNeaded);
  
  always@(*) begin
    fRnSEXE=1'b0; fRnSMEM=1'b0;
    fRmSEXE=1'b0; fRmSMEM=1'b0;
    stallNeaded=1'b1;
    if(fwd_EN)begin
      stallNeaded=1'b0;
      if(EXE_WB_EN) begin
        if(src1==EXE_Dest && hasRn)begin
          if(EXE_MEM_R_EN)  stallNeaded=1'b1; else  fRnSEXE=1'b1;
        end
        if(src2==EXE_Dest && Two_Src)begin
          if(EXE_MEM_R_EN)  stallNeaded=1'b1; else  fRmSEXE=1'b1;
        end
      end
      if(MEM_WB_EN) begin
        if(src1==MEM_Dest && hasRn) fRnSMEM=1'b1;
        if(src2==MEM_Dest && Two_Src) fRmSMEM=1'b1;
      end
    end
  end
  
endmodule