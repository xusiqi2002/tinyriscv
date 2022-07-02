//////////////////////////
//
//
//文件名：decode.v
//模块名：DECODE
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//用于解码
//产生控制型号，将立即数扩展为32位
//
//////////////////////////
`include "def.vh"

module DECODE(
    input [`INST_BUS] inst,
    output decode_out,//TODO:具体信号：未定义
    output [`DATA_BUS]immout//产生的立即数
);

endmodule