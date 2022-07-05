//////////////////////////
//
//
//文件名：inst_buf.v
//模块名:INST_BUF
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//
//指令缓存
//替代if,id间的流水线寄存器
//从if阶段读入取得的指令
//向id送出指令
//////////////////////////
`include "def.vh"
module INST_BUF(
    input clk,
    input rst,//清空
    input stop,//从IF输出，停止更新指令buffer

    input [1:0] issue,

    input [`INST_BUS] in1_inst,
    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    //input receive_flag1,//从if传来

    input [`INST_BUS] in2_inst,
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    //input receive_flag2,//从if传来
    
    output [`INST_BUS] out1_inst,
    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output sendout_flag1,
    input isbranch1,
    input br_taken1,

    output [`INST_BUS] out2_inst,
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,

    output sendout_flag2,
    input  isbranch2,
    input  br_taken2,

    output instbuf_full//TODO:具体有待定义，送出表示当前状态的指令送给if,用于确定是否取指

);
//对于顺序发射,能否跳转时直接清空？

    reg sendout_flag1,sendout_flag2,buf_full;
    reg [97:0] inst[0:3];//inst[97]=isbranch,inst[96]=br_taken,inst[95:64]=pc,inst[63:32]=npc,inst[31:0]=inst
    wire [97:0] null_inst;
    assign null_inst=98'b0;

    

    always@(posedge clk,posedge rst)
    begin
        if(rst) begin
            for(i=0;i<4;i++)
                inst[i]=null_inst;
        end
        else begin
            //上一周期指令，sendout_flag寄存器类型，还未更改
            //更新指令缓存
            if(sendout_flag1 && !sendout_flag2) begin//第一条指令送出,第二条指令保留
                for(i=0;i<3;i++)
                    inst[i]=inst[i+1];
                inst[3]=null_inst;
            end
            else if(sendout_flag2) begin//第二条指令送出,第一条指令肯定也送出
                for(i=0;i<2;i++)
                    inst[i]=inst[i+2];
                inst[2]=null_inst;
                inst[3]=null_inst;
            end
            //存入新的指令
            if(!instbuf_full)
                case(issue)
                    2'b01: begin
                        for(i=0;i<4;i++)
                            if(inst[i]==null_inst)
                                inst[i]={isbranch1,br_taken1,in2_pc,in2_npc,in2_inst};
                    end
                    2'b11: begin
                        for(i=0;i<4;i++)
                            if(inst[i]==null_inst && i<3) begin//buf剩两个以上空位
                                inst[i]={isbranch1,br_taken1,in1_pc,in1_npc,in1_inst};
                                inst[i+1]={isbranch2,br_taken2,in2_pc,in2_npc,in2_inst};
                            end
                            else 
                                buf_full=1'b1;//指令buf剩一个空位，需存入两条指令，传出buf_full
                    end
                endcase
            //判断该周期送出哪些指令
            if(inst[0][97:96]==2'b11) begin//inst[0]是branch指令且预测发生跳转
                send_flag1=1'b1;
                send_flag2=1'b0;
                for(i=1;i<4;i++)
                    inst[i]=null_inst;
            end
            else if(inst[1][97:96]==2'b11) begin//inst[1]是branch指令且预测发生跳转
                send_flag1=1'b1;
                send_flag2=1'b1;
                for(i=2;i<4;i++)
                    inst[i]=null_inst;
            end
            else if(inst[0][97]==1'b1 && inst[1][97]==1'b1) begin//
                send_flag1=1'b1;
                send_flag2=1'b0;
            end
            else if((inst[0][6:0]==7'b0000011 | inst[0][6:0]==7'b0100011) && 
                (inst[1][6:0]==7'b0000011 | inst[1][6:0]==7'b0100011)) begin
                send_flag1=1'b1;
                send_flag2=1'b0;
            end
            else begin   
                send_flag1=1'b1;
                send_flag2=1'b1;
            end
        end
    end
    assign instbuf_full=(inst[3]!=null_inst | buf_full) ? 1'b1 : 1'b0 ;
    assign sendout_flag1=send_flag1;
    assign sendout_flag2=send_flag2;
    assign out1_pc  =inst[0][95:64];
    assign out1_npc =inst[0][63:32];
    assign out1_inst=inst[0][31:0];
    assign out2_pc  =inst[1][95:64];
    assign out2_npc =inst[1][63:32];
    assign out2_inst=inst[1][31:0]; 

endmodule