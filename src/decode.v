//////////////////////////
//
//文件名：decode.v
//模块名：DECODE
//创建日期：2022-7-22
//最后修改日期: 2022-7-23
//
//用于解码
//产生控制型号，将立即数扩展为32位
//
//////////////////////////
`include "def.vh"

module DECODE(
    input [`INST_BUS] inst,
    
    //以下为控制信号decode out
    output [71:0]decode_out
);


    wire [2:0] InstType;
    wire [`REG_ADDR_BUS] rs;
    wire [`REG_ADDR_BUS] rt;
    wire [`REG_ADDR_BUS] rd;
    wire [`DATA_BUS]immout;//产生的立即数
    wire [5:0] EXTop;    // control signal to signed extension
    wire [2:0] NPCop;    // next pc operation
    wire ALUsrc;   // ALU source for A
    wire [4:0] ALUop;    // ALU opertion
    wire DMWe;
    wire DMsign;
    wire [1:0] DMwidth;
    wire RFWe;//regfile write enable
    wire [1:0] RFWsrc;//0:aluwire 1:datamemory

    assign decode_out = {
        InstType[2:0],
        rs[`REG_ADDR_BUS],
        rt[`REG_ADDR_BUS],
        rd[`REG_ADDR_BUS],
        immout[`DATA_BUS],
        EXTop[5:0],
        NPCop[2:0],
        ALUsrc,
        ALUop[4:0],
        DMWe,
        DMsign,
        DMwidth[1:0],
        RFWe,
        RFWsrc[1:0]
    };






endmodule