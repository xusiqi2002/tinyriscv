//////////////////////////
//
//文件名：SCPU.v
//模块名：SCPU
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//
//////////////////////////
`include "def.vh"
module SCPU(
    input clk,            // clock
    input reset,          // reset
    output [31:0] inst_addr_out,
    input [63:0] inst_in,     //一次存取两条指令
   

    output    mem_w, // output: memory write signal
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
  INST_BUF U_INSTBUF(

  );




//解码模块1
    DECODE DECODE_1(

    );

//解码模块2
    DECODE DECODE_2(

    );


//TODO: add 选择电路


//TODO: add excute




//wb
    WB U_WB(

    );

//TODO: add 冒险，旁路和阻塞



endmodule