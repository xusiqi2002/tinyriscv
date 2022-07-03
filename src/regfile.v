//////////////////////////
//
//
//文件名：regfile.v
//模块名：RF
//
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//寄存器堆
//
//此处仅考虑32个通用寄存器
//两个输入端口，四个输出端口
//
//////////////////////////
`include "def.vh"
module RF(

    input clk,
    input rst,

    input [`REG_ADDR_BUS] raddr1,
    output [`DATA_BUS] rdata1,
    input [`REG_ADDR_BUS] raddr2,
    output [`DATA_BUS] rdata2,
    input [`REG_ADDR_BUS] raddr3,
    output [`DATA_BUS] rdata3,
    input [`REG_ADDR_BUS] raddr4,
    output [`DATA_BUS] rdata4,

    input we1,
    input [`REG_ADDR_BUS] waddr1,
    input [`DATA_BUS] wdata1,
    input we2,
    input [`REG_ADDR_BUS] waddr2,
    input [`DATA_BUS] wdata2

);


endmodule