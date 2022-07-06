//////////////////////////
//
//
//文件名：inst_buf.v
//模块名:INST_BUF
//
//创建日期：2022-7-6
//最后修改日期: 2022-7-6
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

    input branch_flag,
    input [1:0] issue,

    input [`INST_BUS] in1_inst,
    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input launch_flag1,

    input [`INST_BUS] in2_inst,
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    input launch_flag2,
    
    output [`INST_BUS] out1_inst,
    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output sendout_flag1,

    output [`INST_BUS] out2_inst,
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,

    output sendout_flag2,

    output instbuf_full

);

    integer i;

    reg buf_full;
    initial begin
        buf_full=1'b0;
    end
    reg [95:0] inst[0:3];//inst[95:64]=pc,inst[63:32]=npc,inst[31:0]=inst
    wire [95:0] null_inst;
    assign null_inst=96'b0;


    initial buf_full = 1'b0;

    always@(posedge clk)
    //always@(posedge clk,posedge rst)
    begin
        if(rst | branch_flag)
        begin
            for(i=0;i<4;i=i+1)
                inst[i]=null_inst;
        end
        else 
        begin
            /*if(branch_flag==1'b1)//之前产生预测错误，清空全部指令
                for(i=0;i<4;i=i+1)
                    inst[i]=null_inst;
            */
            //上一周期指令，sendout_flag寄存器类型，还未更改
            //更新指令缓存，将送出的指令清除
            if(launch_flag1 && !launch_flag2) begin//第一条指令送出,第二条指令保留
                for(i=0;i<3;i=i+1)
                    inst[i]=inst[i+1];
                inst[3]=null_inst;
            end
            else if(launch_flag2) begin//第二条指令送出,第一条指令肯定也送出
                for(i=0;i<2;i=i+1)
                    inst[i]=inst[i+2];
                inst[2]=null_inst;
                inst[3]=null_inst;
            end
            //存入新的指令
            if(instbuf_full!=1'b1)
                case(issue)
                    2'b01: begin
                        if(inst[0]==null_inst)
                            inst[0]={in2_pc,in2_npc,in2_inst};
                        else if(inst[1]==null_inst)
                            inst[1]={in2_pc,in2_npc,in2_inst};
                        else if(inst[2]==null_inst)
                            inst[2]={in2_pc,in2_npc,in2_inst};
                        else 
                            inst[3]={in2_pc,in2_npc,in2_inst};
                    end
                    2'b10: begin
                        if(inst[0]==null_inst)
                            inst[0]={in1_pc,in1_npc,in1_inst};
                        else if(inst[1]==null_inst)
                            inst[1]={in1_pc,in1_npc,in1_inst};
                        else if(inst[2]==null_inst)
                            inst[2]={in1_pc,in1_npc,in1_inst};
                        else 
                            inst[3]={in1_pc,in1_npc,in1_inst};
                    end
                    2'b11: begin
                        if(inst[2]!=null_inst && inst[3]==null_inst)
                            buf_full=1'b1;//指令buf剩一个空位，需存入两条指令，传出buf_full
                        else begin
                            if(inst[0]==null_inst) begin
                                inst[0]={in1_pc,in1_npc,in1_inst};
                                inst[1]={in2_pc,in2_npc,in2_inst};
                            end
                            else if(inst[1]==null_inst) begin
                                inst[1]={in1_pc,in1_npc,in1_inst};
                                inst[2]={in2_pc,in2_npc,in2_inst};
                            end
                            else if(inst[2]==null_inst) begin
                                inst[2]={in1_pc,in1_npc,in1_inst};
                                inst[3]={in2_pc,in2_npc,in2_inst};
                            end
                        end
                    end
                endcase
        end
    end
    assign instbuf_full=(inst[3]!=null_inst | buf_full) ? 1'b1 : 1'b0 ;
    assign sendout_flag1=(inst[0]==null_inst)?1'b0:1'b1;
    assign sendout_flag2=(inst[1]==null_inst)?1'b0:1'b1;
    assign out1_pc  =inst[0][95:64];
    assign out1_npc =inst[0][63:32];
    assign out1_inst=inst[0][31:0];
    assign out2_pc  =inst[1][95:64];
    assign out2_npc =inst[1][63:32];
    assign out2_inst=inst[1][31:0]; 

endmodule