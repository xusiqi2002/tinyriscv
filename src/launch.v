//////////////////////////
//
//文件名：launch.v
//模块名：LAUNCH
//
//创建日期：2022-7-23
//最后修改日期: 2022-7-23
//
//用于判断是否将解码后的两个指令送入执行模块，以及送入那个执行模块
//也起了流水线寄存器的作用
//同时也进行了取寄存器
//////////////////////////
`include "def.vh"
module LAUNCH(
    input clk,
    input rst,
    input stop,

    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input [71:0] in1_decodeout,
    
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    input [71:0] in2_decodeout,


//传给第一个执行模块的输出
//算数 or 跳转
    output out1_num,
    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output [71:0] out1_decodeout,
    output [`DATA_BUS] out1_rfrdata1,
    output [`DATA_BUS] out1_rfrdata2,

    
    output out2_num,
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,
    output [71:0] out2_decodeout,
    output [`DATA_BUS] out2_rfrdata1,
    output [`DATA_BUS] out2_rfrdata2,

    output [3:0]l_flag //用于展示是否送入执行模块以及送入那个执行模块，待改变

);



endmodule