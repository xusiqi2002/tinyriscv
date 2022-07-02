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

module INST_BUF(
    input clk,
    input rst,
    input [31:0] inst_in1,
    input [31:0] inst_in2,
    output [31:0] inst_out1,
    output [31:0] inst_out2,

    input [31:0] inst_pc1,//TODO: 用于在预测错误时清除：是pc还是时间戳？
    input [31:0] inst_pc2,


    input branch_flag,
    input branch_pc,//具体有待定义，用于清空一部分指令

    output instbuf_full//具体有待定义，送出表示当前状态的指令送给if,用于确定是否取指
);



endmodule