`include "ctrl_encode_def.vh"

module IF_ID(
    input clk,
    input rst,
    input stop,

    input [31:0] if_inst,
    output reg [31:0] id_inst,

    input [31:0] if_pc,
    output reg [31:0] id_pc,

    input [31:0] if_npc,
    output reg [31:0] id_npc
);

    always @ (posedge clk)
        if(rst)
        begin
            id_pc <= `PC_INITIAL;
            id_inst <= `INST_INITIAL;
            id_npc <= `NPC_INITIAL;
        end
        else
            if(stop)
            begin
                id_pc <= id_pc;
                id_inst <= id_inst;
                id_npc <= id_npc;
            end
            else
            begin
                id_pc <= if_pc;
                id_inst <= if_inst;
                id_npc <= if_npc;
            end

endmodule