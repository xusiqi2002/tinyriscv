//////////////////////////
//
//
//文件名：inst_buf.v
//模块名:INST_BUF
//
//创建日期：2022-7-9
//最后修改日期: 2022-7-14
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

    input [`INST_BUS] in1_inst,
    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input receive_flag1,

    input [`INST_BUS] in2_inst,
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    input receive_flag2,
    
    output [`INST_BUS] out1_inst,
    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output sendout_flag1,
    input launch_flag1,

    output [`INST_BUS] out2_inst,
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,
    output sendout_flag2,
    input launch_flag2,

    output instbuf_full,

    output reg error//出现错误

);
    reg [`INSTBUF_BUS] ib[0:3];
    //reg [1:0] ib_l;
    wire [`INSTBUF_BUS] in1 = receive_flag1 ? {`VALID,in1_inst,in1_pc,in1_npc} : `IB_INITIAL;
    wire [`INSTBUF_BUS] in2 = receive_flag2 ? {`VALID,in2_inst,in2_pc,in2_npc} : `IB_INITIAL;


    initial
    begin
        ib[0] <= `IB_INITIAL;
        ib[1] <= `IB_INITIAL;
        ib[2] <= `IB_INITIAL;
        ib[3] <= `IB_INITIAL; 
    end

    always @ (posedge clk)
    if(rst | branch_flag)
    begin
        ib[0] <= `IB_INITIAL;
        ib[1] <= `IB_INITIAL;
        ib[2] <= `IB_INITIAL;
        ib[3] <= `IB_INITIAL; 
    end
    else
        case ({ib[0][`IB_V],ib[1][`IB_V],ib[2][`IB_V],ib[3][`IB_V]})
            4'b0000:
                if(receive_flag1)
                begin
                    ib[0] <= in1;
                    ib[1] <= in2;
                end
                else
                    ib[0] <= in2;
            4'b1000:
                if(launch_flag1)
                    if(receive_flag1)
                    begin
                        ib[0] <= in1;
                        ib[1] <= in2;
                    end
                    else
                        ib[0] <= in2;
                else
                    if(receive_flag1)
                    begin
                        ib[1] <= in1;
                        ib[2] <= in2;
                    end
                    else
                        ib[1] <= in2;
            4'b1100:
            begin
                case ({launch_flag1,launch_flag2})
                    2'b00:
                        if(receive_flag1)
                        begin
                            ib[2] <= in1;
                            ib[3] <= in2;
                        end
                        else
                            ib[2] <= in2;
                    2'b10:
                    begin
                        ib[0] <= ib[1];
                        if(receive_flag1)
                        begin
                            ib[1] <= in1;
                            ib[2] <= in2;
                        end
                        else
                            ib[1] <= in2;
                    end
                    2'b11:
                        if(receive_flag1)
                        begin
                            ib[0] <= in1;
                            ib[1] <= in2;
                        end
                        else
                        begin
                            ib[0] <= in2;
                            ib[1] <= `IB_INITIAL;
                        end
                endcase
            end
            4'b1110:
                case ({launch_flag1,launch_flag2})
                    2'b10:
                    begin
                        ib[0] <= ib[1];
                        ib[1] <= ib[2];
                        ib[2] <= `IB_INITIAL; 
                    end
                    2'b11:
                    begin
                        ib[0] <= ib[2];
                        ib[1] <= `IB_INITIAL;
                        ib[2] <= `IB_INITIAL;
                    end
                endcase
            4'b1111:
                case ({launch_flag1,launch_flag2})
                    2'b10:
                    begin
                        ib[0] <= ib[1];
                        ib[1] <= ib[2];
                        ib[2] <= ib[3];
                        ib[3] <= `IB_INITIAL; 
                    end
                    2'b11:
                    begin
                        ib[0] <= ib[2];
                        ib[1] <= ib[3];
                        ib[2] <= `IB_INITIAL;
                        ib[3] <= `IB_INITIAL;
                    end
                endcase
        endcase


    assign {sendout_flag1,out1_inst,out1_pc,out1_npc} = ib[0];
    assign {sendout_flag2,out2_inst,out2_pc,out2_npc} = ib[1];
    assign instbuf_full = ib[2][`IB_V];

endmodule