//////////////////////////
//
//文件名：fab.v
//模块名 FAB
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//执行模块
//能执行运算和访存
//
//////////////////////////
`include "def.vh"

module FAM(
    input clk,
    input rst,

    input num_in,//用于确认该指令在并行的两条指令中的顺序
    input [`PC_BUS] pc,//pc
    //input [`PC_BUS] npc,//next pc
    input [`DATA_BUS] imm,//立即数
    input [71:0] decode_out,//decode 产生的控制信号具体未定义
    output [`DATA_BUS] rfrdata1,
    output [`DATA_BUS] rfrdata2,


    output [3:0] DWea,//传出的写信号
    output [`MEM_ADDR_BUS] Addr_out,
    output [`DATA_BUS] Data_out,
    input [`DATA_BUS] Data_in,

    
    output num_out,
    output rfwe,//寄存器写
    output [`REG_ADDR_BUS] rfwaddr,
    output [`DATA_BUS] rfwdata,

    output _endsign//暂时不用
);


// 第一个阶段
    ALU U_ALU(

    );



//流水线寄存器
    FAM_PLREG PR1(

    );


//第二个阶段
//作用相当与流水线中的mem
//产生与



endmodule



//模块名：FAM_PLREG
//FAM中的流水线寄存器
module FAM_PLREG(
    input clk,
    input rst,
    input stop
    

);


endmodule 

