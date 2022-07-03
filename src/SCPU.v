//////////////////////////
//
//文件名：SCPU.v
//模块名：SCPU
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-23
//
//
//////////////////////////
`include "def.vh"
module SCPU(
    input clk,            // clock
    input reset,          // reset
    output [31:0] inst_addr_out,// TODO: 待修改
    input [63:0] inst_in,     //一次存取两条指令
   


//用于传给RAM
    output mem_w, // output: memory write signal
    output [`MEM_ADDR_BUS] Addr_out,   // ALU output
    input [`DATA_BUS] Data_in,     // data from data memory
    output [`DATA_BUS] Data_out,// data to data memory
    output [3:0] DWea,
    
    input wire INT//中断信号，暂不实现中断和异常
);



//取指：一次取多条
//内置PC,输出PC地址
    IF U_IF(

    );

//指令缓存
//代替IF,ID间的流水线寄存器
    INST_BUF U_INSTBUF(

    );




//解码模块1
    DECODE DECODE_1(

    );

//解码模块2
    DECODE DECODE_2(

    );

//对解码的输出进行选择，送入执行阶段
//代替了id_ex中的流水线寄存器
    LAUNCH U_L(

    );



//执行模块1,
//支持运算和跳转
    FAB EXC1(




    );



//执行模块2
//支持运算和fangcun

    FAM EXC2(

    );


//流水线寄存器 执行到写回的流水线寄存器
    PLREG_EX_WB U_PR_EX_WB(
        .clk()

    );

//写回阶段
    WB U_WB(

    );

//TODO: add 冒险，旁路和阻塞


//32个通用寄存器
    RF U_RF(
    );


endmodule


//模块名：PLREG_EX_WB
//ex到wb的流水线寄存器
module PLREG_EX_WB(

);




endmodule