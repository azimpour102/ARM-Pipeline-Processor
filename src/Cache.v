module Cache(input clk,rst,write_en,read_en,cchUpdate,
             input [18:0]adrIn,input [63:0]write_data,
             output reg miss,output reg [31:0]readData);
  reg [0:63]val1,val2;
  
  reg a,b;
  
  reg [148:0]cch[0:63];
  
  wire [5:0] ind;
  wire [148:0] cchLine;
  wire [9:0] tagIn,tag1,tag2;
  wire used;
  
  assign ind=adrIn[8:3];
  assign cchLine=cch[ind];
  assign used=cchLine[148];
  assign tagIn=adrIn[17:8];
  assign tag1=cchLine[147:138]; 
  assign tag2=cchLine[73:64];
  //assign readData=
  
  
  always@(*)begin
    miss=1'b0;
    a=(tagIn==tag1); b=(tagIn==tag2);
    if(write_en || read_en)begin
      miss=1'b1;
      if(((tagIn==tag1) && val1[ind]) || ((tagIn==tag2) && val2[ind]))
        miss=1'b0;
      //else miss=1'b1;
    end
  end
  
  always@(*)begin
    if(read_en)begin
      if(tagIn==tag1 && val1)begin
        readData=adrIn[2] ? cchLine[105:74] : cchLine[137:106];
        //val1[ind]=1'b1;
        cch[ind][148]=1'b1;
      end
      else if(tagIn==tag2 && val2)begin
        readData=adrIn[2] ? cchLine[31:0] : cchLine[63:32];
        //val2[ind]=1'b1;
        cch[ind][148]=1'b0;
      end
    end
  end
  
  always@(posedge clk,posedge rst)begin
    //miss=1'b0;
    if(rst)begin
      val1=64'b0; val2=64'b0;
    end
    else begin
      if(cchUpdate)begin
        if(read_en)begin
          if(tagIn==tag1)begin
            cch[ind][147:138]=tagIn;
            val1[ind]=1'b1;
            cch[ind][137:74]=write_data;
            //cch[ind][148]=1'b1;
          end
          else if(tagIn==tag2)begin
            cch[ind][73:64]=tagIn;
            val2[ind]=1'b1;
            cch[ind][63:0]=write_data;
            //cch[ind][148]=1'b0;
          end
          else if(used)begin
            cch[ind][73:64]=tagIn;
            val2[ind]=1'b1;
            cch[ind][63:0]=write_data;
            //cch[ind][148]=1'b0;
          end
          else begin
            cch[ind][147:138]=tagIn;
            val1[ind]=1'b1;
            cch[ind][137:74]=write_data;
            //cch[ind][148]=1'b1;
          end
        end
        if(write_en)begin
          if(miss);
          else begin
            if(tagIn==tag1 && val1)begin
              val1[ind]=1'b0;
            end
            else if(tagIn==tag2 && val2)begin
              val2[ind]=1'b0;
            end
          end
        end
      end
    end
  end
endmodule
        