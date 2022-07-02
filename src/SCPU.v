//////////////////////////
//
//
//模块名：SCPU.v
//顶层模块
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//
//////////////////////////
module SCPU(
    input clk,            // clock
    input reset,          // reset
    output [31:0] inst_addr_out,
    input [63:0] inst_in,     //一次存取两条指令
   

    output    mem_w, // output: memory write signal
    output [31:0] Addr_out,   // ALU output
    input [31:0] Data_in,     // data from data memory
    output [31:0] Data_out,// data to data memory
    output [3:0] DWea,
    
    input wire INT//中断信号，暂不实现中断和异常
);



//取指：一次取多条
//内置PC,输出PC地址
    IF U_IF(

    );


//  TODO: 此处差一个指令缓存

//解码模块1
    DECODE DECODE_1(

    );

//解码模块2
    DECODE DECODE_2(

    );


//中间差一个选择电路


//excute




//wb







endmodule