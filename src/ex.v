////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: ex.v
//
//ex阶段
//alu
//判断是否跳转
//
///////////////////////////////////////////////////`include "ctrl_encode_def.vh"

`include "ctrl_encode_def.vh"
module EX(
    input clk,
    input [31:0] ex_pc,
    input [31:0] ex_npc,
    input [2:0] ex_NPCop,
    input  ex_ALUsrc,
    input [4:0] ex_ALUop,
    input [31:0] ex_immout,
    input [31:0] ex_rfrdata1,
    input [31:0] ex_rfrdata2,
    output [31:0] ex_aluout,

    output reg ex_branch_flag,
    output reg [31:0] ex_branch_address

);

 
     wire Zero;
     reg [31:0] B;
     always @ (*)
     case (ex_ALUsrc)
         `ALU_FROM_IMM: B <= ex_immout;
         `ALU_FROM_RF2: B <= ex_rfrdata2;
     endcase

     ALU U_ALU(
         .A(ex_rfrdata1),
         .B(B),
         .ALUop(ex_ALUop),
         .PC(ex_pc),
         .C(ex_aluout),
         .Zero(Zero)
     );
    
    always @(*)
    begin
        case (ex_NPCop & {2'b11,Zero})
            `NPC_PLUS4: ex_branch_address = ex_pc + 4;
            `NPC_BRANCH: ex_branch_address = ex_pc+ex_immout;//BEQ,BNE
            `NPC_JUMP: ex_branch_address = ex_pc+ex_immout;//JAL
            `NPC_JALR: ex_branch_address =ex_aluout;//JALR
            default: ex_branch_address = ex_npc;
        endcase
        ex_branch_flag <= (ex_branch_address != ex_npc);
    end

endmodule