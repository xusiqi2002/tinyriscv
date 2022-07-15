////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: ex_mem.v
//
//ex到mem的流水线寄存器
//
//
///////////////////////////////////////////////////
`include "ctrl_encode_def.vh"
module EX_MEM(
    input clk,
    input rst,
    input stop,
    
    input [31:0] ex_pc,
    output reg [31:0] mem_pc,

    input ex_DMWe,//datamemory write enable
    output reg mem_DMWe,

    input ex_DMsign,
    output reg mem_DMsign,

    input [1:0] ex_DMwidth,
    output reg [1:0] mem_DMwidth,

    input [3:0] ex_DWea,
    output reg [3:0] mem_DWea,

    input [31:0] ex_aluout,
    output reg [31:0] mem_aluout,

    input [31:0] ex_rfrdata2,
    output reg [31:0] mem_rfrdata2,
    //wb
    input ex_RFWe,//regfile write enable
    output reg mem_RFWe,

    input [1:0] ex_RFWsrc,
    output reg [1:0] mem_RFWsrc,
    
    input [4:0] ex_rfwaddr,//regfile write address
    output reg [4:0] mem_rfwaddr

);

    always @ (posedge clk)
    if(rst)
    begin
        mem_pc <= `PC_INITIAL;
        mem_DMWe <= `DMWRITE_DISABLE;
        mem_DMsign <= 1'b0;
        mem_DMwidth <= 2'b11;
        mem_DWea <= 4'b0000;
        mem_aluout <= `DATA_INITIAL;
        mem_rfrdata2 <= `DATA_INITIAL;
        mem_RFWe <= `DISABLE;
        mem_RFWsrc <= 1'b0;
        mem_rfwaddr <= `RFADDR_INITIAL;
    end
    else
        if(stop)
        begin
            mem_pc <= mem_pc;
            mem_DMWe <= mem_DMWe;
            mem_DMsign <= mem_DMsign;
            mem_DMwidth <= mem_DMwidth;
            mem_DWea <= mem_DWea;
            mem_aluout <= mem_aluout;
            mem_rfrdata2 <= mem_rfrdata2;
            mem_RFWe <= mem_RFWe;
            mem_RFWsrc <= mem_RFWsrc;
            mem_rfwaddr <= mem_rfwaddr;
        end
        else
        begin
            mem_pc <= ex_pc;
            mem_DMWe <= ex_DMWe;
            mem_DMsign <= ex_DMsign;
            mem_DMwidth <= ex_DMwidth;
            mem_DWea <= ex_DWea;
            mem_aluout <= ex_aluout;
            mem_rfrdata2 <= ex_rfrdata2;
            mem_RFWe <= ex_RFWe;
            mem_RFWsrc <= ex_RFWsrc;
            mem_rfwaddr <= ex_rfwaddr;
        end

endmodule