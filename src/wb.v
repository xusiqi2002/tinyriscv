////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: WB.v
//
//完成write back阶段
//所有电路都是组合电路
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module WB(
    input clk,
    input reset,

    input wb_RFWe,//regfile write enable

    input [4:0] wb_rfwaddr,//regfile write address
    input [31:0] wb_rfwdata,

    output reg RFrst,
    output reg RFWe,
    output reg [4:0] rfwaddr,
    output reg [31:0] rfwdata
);
    always @ (*)
    begin
        RFrst <= reset;
        RFWe <= wb_RFWe;
        rfwaddr <= wb_rfwaddr;
        rfwdata <= wb_rfwdata;
    end

endmodule