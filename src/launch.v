//////////////////////////
//
//文件名：launch.v
//模块名：LAUNCH
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-4
//
//用于判断是否将解码后的两个指令送入执行模块，以及送入哪个执行模块
//////////////////////////
`include "def.vh"
module LAUNCH_SELECT(
    input clk,
    input rst,
    input stop,

    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input [`DECODEOUT_BUS] in1_decodeout,
    input receive_flag1,
    
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    input [`DECODEOUT_BUS] in2_decodeout,
    input receive_flag2,

    input [`DATA_BUS] rfrd1,
    input [`DATA_BUS] rfrd2,
    input [`DATA_BUS] rfrd3,
    input [`DATA_BUS] rfrd4,

    //用于数据冒险
    input [`RFW_BUS] rfw1_s1,
    input [`RFW_BUS] rfw2_s1,
    input [`RFW_BUS] rfw1_s2,
    input [`RFW_BUS] rfw2_s2,


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

    output [3:0]launch_flag //用于展示是否送入执行模块以及送入那个执行模块，待改变

);

    wire [1:0] inst1_type = in1_decodeout[`DCINSTTYPE];
    wire [1:0] inst2_type = in2_decodeout[`DCINSTTYPE];

    reg inst1_c;
    reg inst2_c;


    //先判断寄存器读的数据


    //再决定顺序






endmodule