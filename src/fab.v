//////////////////////////
//
//文件名：fab.v
//模块名 FAB
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//执行模块
//能执行运算和跳转
//
//////////////////////////
`include "def.vh"

module FAB(

    input clk,
    input rst,
    input stop,//可扩展

    input num_in,//一个顺序编号，用于确定在同时进行的两条指令的顺序
    input [`PC_BUS] pc,//pc
    input [`PC_BUS] npc,//next pc
    input [71:0] decode_out,//decode 产生的控制信号具体未定义
    output [`DATA_BUS] rfrdata1,
    output [`DATA_BUS] rfrdata2,

    output branch_flag,//跳转信号
    output [`PC_BUS] branch_address,//跳转地址


    output num_out,
    output rfwe,//
    output [`REG_ADDR_BUS] rfwaddr,
    output [`DATA_BUS] rfwdata,


    output _endsign//暂时不用
);



//TODO:流水线寄存器

    FAB_PLREG REG1(
        .clk()

    );



endmodule



//模块名：FAB_PLREG
//FAB中的流水线寄存器
module FAB_PLREG(
    input clk,
    input rst,
    input stop
    

);


endmodule 


