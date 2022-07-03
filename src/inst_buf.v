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
    input rst,
    input stop,

    input [`INST_BUS] in1_inst,
    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,

    input [`INST_BUS] in2_inst,
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    
    input [`INST_BUS] out1_inst,
    input [`PC_BUS] out1_pc,
    input [`PC_BUS] out11_npc,

    input [`INST_BUS] out2_inst,
    input [`PC_BUS] out2_pc,
    input [`PC_BUS] out2_npc,


//TODO:具体有待定义，用于清空一部分指令,不一定需要
    input branch_flag,
    input [`PC_BUS]branch_pc,

    output instbuf_full//TODO:具体有待定义，送出表示当前状态的指令送给if,用于确定是否取指

);
//对于顺序发射,能否跳转时直接清空？


endmodule