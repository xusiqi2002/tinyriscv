////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: id_ex.v
//
//id到ex的流水线寄存器
//
//
///////////////////////////////////////////////////
`include "ctrl_encode_def.vh"
module ID_EX(
    input clk,
    input rst,
    input stop,

    //id
    input [31:0] id_pc,
    output reg [31:0] ex_pc,
    
    input [31:0] id_npc,
    output reg [31:0] ex_npc,

    input [2:0] id_NPCop,
    output reg [2:0] ex_NPCop,

    input id_ALUsrc,
    output reg ex_ALUsrc,

    input [4:0] id_ALUop,
    output reg [4:0] ex_ALUop,

    input [31:0] id_immout,//immediate
    output reg[31:0] ex_immout,

    input [31:0] id_rfrdata1,
    output reg [31:0] ex_rfrdata1,

    input [31:0] id_rfrdata2,
    output reg [31:0] ex_rfrdata2,

    //mem
    input id_DMWe,//datamemory write enable
    output reg ex_DMWe,

    input id_DMsign,
    output reg ex_DMsign,

    input [1:0] id_DMwidth,
    output reg [1:0] ex_DMwidth,

    input [3:0] id_DWea,
    output reg [3:0] ex_DWea,

    //wb
    input id_RFWe,//regfile write enable
    output reg ex_RFWe,

    input [1:0] id_RFWsrc,
    output reg [1:0] ex_RFWsrc,

    
    input [4:0] id_rfwaddr,//regfile write address
    output reg [4:0] ex_rfwaddr
    //input [31:0] id_rfwdata,//regfile write address
    //output reg [31:0] ex_rfwdata

);


    always @ (posedge clk)
    if(rst)
    begin
        ex_pc <= `PC_INITIAL;
        ex_npc <= `NPC_INITIAL;
        ex_NPCop <= 3'b000;
        ex_ALUsrc <= 1'b0;
        ex_ALUop <= `ALUOP_nop;
        ex_immout <= `DATA_INITIAL;
        ex_rfrdata1 <= `DATA_INITIAL;
        ex_rfrdata2 <= `DATA_INITIAL;
        ex_DMWe <= `DISABLE;
        ex_DMsign <= 1'b0;
        ex_DMwidth <= 2'b11;
        ex_DWea <= 4'b0000;
        ex_RFWe <= `DISABLE;
        ex_RFWsrc <= 1'b0;
        ex_rfwaddr <= `RFADDR_INITIAL;
    end
    else
        if(stop)
        begin
            ex_pc <= ex_pc;
            ex_npc <= ex_npc;
            ex_NPCop <= ex_NPCop;
            ex_ALUsrc <=  ex_ALUsrc;
            ex_ALUop <= ex_ALUop;
            ex_immout <= ex_immout;
            ex_rfrdata1 <= ex_rfrdata1;
            ex_rfrdata2 <= ex_rfrdata2;
            ex_DMWe <= ex_DMWe;
            ex_DMsign <= ex_DMsign;
            ex_DMwidth <= ex_DMwidth;
            ex_DWea <= ex_DWea;
            ex_RFWe <= ex_RFWe;
            ex_RFWsrc <= ex_RFWsrc;
            ex_rfwaddr <= ex_rfwaddr;
        end
        else
        begin
            ex_pc <= id_pc;
            ex_npc <= id_npc;
            ex_NPCop <= id_NPCop;
            ex_ALUsrc <=  id_ALUsrc;
            ex_ALUop <= id_ALUop;
            ex_immout <= id_immout;
            ex_rfrdata1 <= id_rfrdata1;
            ex_rfrdata2 <= id_rfrdata2;
            ex_DMWe <= id_DMWe;
            ex_DMsign <= id_DMsign;
            ex_DMwidth <= id_DMwidth;
            ex_DWea <= id_DWea;
            ex_RFWe <= id_RFWe;
            ex_RFWsrc <= id_RFWsrc;
            ex_rfwaddr <= id_rfwaddr;
        end

endmodule
