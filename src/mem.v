////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: mem.v
//
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module MEM(
    input clk,
    input mem_DMWe,
    input mem_DMsign,
    input [1:0] mem_DMwidth,
    input [1:0] mem_RFWsrc,
    //input [3:0] mem_DWea,

    //input [31:0] mem_immout,
    input [31:0] mem_pc,
    input [31:0] mem_aluout,
    input [31:0] mem_rfrdata2,
    //output reg [31:0] mem_dmout,
    output reg [31:0] mem_rfwdata,

    //output reg mem_w,
    //output reg [3:0] DWea,
    //output reg [31:0] Data_out,
    //output reg [31:0] Addr_out,
    input [31:0] Data_in
);

    reg [31:0] mem_dmout;


    reg [31:0] Addr_out;
    //TODO:
    wire [31:0] _Data_in;
    assign _Data_in = Data_in >> (Addr_out[1:0] * 8);

    always @ (*)
    begin
        case ({mem_DMsign,mem_DMwidth})
            `DM_BYTE_SIGNED: mem_dmout <= {{24{_Data_in[7]}},_Data_in[7:0]};
            `DM_BYTE_UNSIGNED: mem_dmout <= {24'b0,_Data_in[7:0]};
            `DM_HALFWORD_SIGNED: mem_dmout <= {{16{_Data_in[15]}},_Data_in[15:0]};
            `DM_HALFWORD_UNSIGNED: mem_dmout <= {16'b0,_Data_in[15:0]};
            `DM_WORD_SIGNED: mem_dmout <= _Data_in;
            default mem_dmout <= 32'b0;
        endcase
        /*
        case ({mem_DMsign,mem_DMwidth})
            `DM_BYTE_SIGNED: mem_dmout <= {{24{Data_in[7]}},Data_in[7:0]};
            `DM_BYTE_UNSIGNED: mem_dmout <= {24'b0,Data_in[7:0]};
            `DM_HALFWORD_SIGNED: mem_dmout <= {{16{Data_in[15]}},Data_in[15:0]};
            `DM_HALFWORD_UNSIGNED: mem_dmout <= {16'b0,Data_in[15:0]};
            `DM_WORD_SIGNED: mem_dmout <= Data_in;
            default mem_dmout <= 32'b0;
        endcase
        */
        //Data_out <= mem_rfrdata2;
        Addr_out <= mem_aluout;
        //mem_w <= mem_DMWe;
        /*if(mem_DMWe)
        case (mem_DMwidth)
            `DM_BYTE: DWea <= 4'b0001 << Addr_out[1:0];
            `DM_HALFWORD: DWea <= 4'b0011 << Addr_out[1:0];
            `DM_WORD: DWea <= 4'b1111;
            default: DWea <= 4'b0000;
        endcase
        else
            DWea <= 4'b0000;*/
        //DWea <= mem_DWea;
        case (mem_RFWsrc)
            `RFW_NONE: mem_rfwdata <= `DATA_INITIAL;
            `RFW_FROM_ALU: mem_rfwdata <= mem_aluout;
            `RFW_FROM_MEM: mem_rfwdata <= mem_dmout;
            `RFW_FROM_PC: mem_rfwdata <= mem_pc + 4;
        endcase
        
    end

endmodule