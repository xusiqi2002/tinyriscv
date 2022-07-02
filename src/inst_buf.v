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
    input [`INST_BUS] inst_in1,
    input [`INST_BUS] inst_in2,
    output [`INST_BUS] inst_out1,
    output [`INST_BUS] inst_out2,

    input [`PC_BUS] inst_pc1,//TODO: 用于在预测错误时清除：是pc还是时间戳？
    input [`PC_BUS] inst_pc2,


    input branch_flag,
    input [`PC_BUS]branch_pc,//TODO:具体有待定义，用于清空一部分指令

    output instbuf_full//TODO:具体有待定义，送出表示当前状态的指令送给if,用于确定是否取指
);
//对于顺序发射,能否跳转时直接清空？


endmodule