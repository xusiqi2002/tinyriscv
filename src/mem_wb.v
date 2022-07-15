////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: MEM_WB.v
//
//从mem到wb的流水线寄存器
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module MEM_WB(
    input clk,
    input rst,
    input stop,

    //input [31:0] mem_pc,
    //output reg [31:0] wb_pc,

    input mem_RFWe,//regfile write enable
    output reg wb_RFWe,

    //input [1:0] mem_RFWsrc,
    //output reg [1:0] wb_RFWsrc,

    //input mem_DMsign,
    //output reg wb_DMsign,

    //input [1:0] mem_DMwidth,
    //output reg [1:0] wb_DMwidth,

    input [4:0] mem_rfwaddr,//regfile write address
    output reg [4:0] wb_rfwaddr,

    input [31:0] mem_rfwdata,
    output reg [31:0] wb_rfwdata


    //input [31:0] mem_aluout,
    //output reg [31:0] wb_aluout,

    //input [31:0] mem_dmout,
    //output reg [31:0] wb_dmout

);


    always @ (posedge clk)
    if(rst)
    begin
        //wb_pc <= `PC_INITIAL;
        wb_RFWe <= `DISABLE;
        //wb_RFWsrc <= `RFW_NONE;
        //wb_DMsign <= 1'b0;
        ///wb_DMwidth <= 2'b00;
        wb_rfwaddr <= `RFADDR_INITIAL;
        wb_rfwdata <= `DATA_INITIAL;
        //wb_aluout <= `DATA_INITIAL;
        //wb_dmout <= `DATA_INITIAL;
        //wb_rfwdata <= `DATA_INITIAL;
    end
    else
        if(stop)
        begin
            //wb_pc <= wb_pc;
            wb_RFWe <= wb_RFWe;
            //wb_RFWsrc <= wb_RFWsrc;
            //wb_DMsign <= wb_DMsign;
            //wb_DMwidth <= wb_DMwidth;
            wb_rfwaddr <= wb_rfwaddr;
            wb_rfwdata <= wb_rfwdata;
            //wb_aluout <= wb_aluout;
            //wb_dmout <= wb_dmout;
        end
        else
        begin
            //wb_pc <= mem_pc;
            wb_RFWe <= mem_RFWe;
            //wb_RFWsrc <= mem_RFWsrc;
            //wb_DMsign <= mem_DMsign;
            //wb_DMwidth <= mem_DMwidth;
            wb_rfwaddr <= mem_rfwaddr;
            wb_rfwdata <= mem_rfwdata;
            //wb_aluout <= mem_aluout;
            //wb_dmout <= mem_dmout;
        end

endmodule