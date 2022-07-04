//////////////////////////
//
//
//文件名：inst_buf.v
//模块名:INST_BUF
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-3
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
    input stop,

    input [`INST_BUS] in1_inst,
    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input receive_flag1,//从if传来

    input [`INST_BUS] in2_inst,
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,

    input receive_flag2,//从if传来
    
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

    output instbuf_full//具体有待定义，送出表示当前状态的指令送给if,用于确定是否取指

);
//对于顺序发射,能否跳转时直接清空？


endmodule