////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: ctrl.v
//
//控制信号的产生
//所有电路都是组合电路
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module CTRL(
    input  [6:0] Op, // opcode,
    input [6:0] Funct7,   // funct7
    input [2:0] Funct3,   // funct3
    //output [1:0] GPRSel,   // general purpose register selection
    //output [1:0] WDSel,   // (register) write data selection
   
    output [5:0] EXTop,    // control signal to signed extension
    output [2:0] NPCop,    // next pc operation
    output ALUsrc,   // ALU source for A
    output [4:0] ALUop,    // ALU opertion
    output DMWe,
    output DMsign,
    output [1:0] DMwidth,
    output RFWe,//regfile write enable
    output [1:0] RFWsrc//0:aluoutput 1:datamemory
);
            
 
  // r format 0110011
  wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; 
  wire i_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
  wire i_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
  wire i_sll  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sll 0000000 001
  wire i_slt  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]&~Funct3[0]; // slt 0000000 010
  wire i_sltu = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]& Funct3[0]; // sltu 0000000 011
  wire i_xor  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]&~Funct3[0]; // xor 0000000 100
  wire i_srl  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srl 0000000 101
  wire i_sra  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // sra 0100000 101
  wire i_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
  wire i_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
  
  // i format
  //0000011 LB,LH,LW,LBU,LHU
  wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];
  wire i_lb = itype_l & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lb 000
  wire i_lh = itype_l & ~Funct3[2] & ~Funct3[1] & Funct3[0]; //lh 001
  wire i_lw = itype_l & ~Funct3[2] & Funct3[1] & ~Funct3[0]; //lw 010
  wire i_lbu = itype_l & Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lb 100
  wire i_lhu = itype_l & Funct3[2] & ~Funct3[1] & Funct3[0]; //lh 101

  // i format
  //0010011 addi,slti,sltiu,xori,ori,andi
  wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];

  wire i_addi  = itype_r& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // addi 0000000 000
  //wire i_sub  = itype_r& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
  wire i_slli  = itype_r& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // slli 0000000 001
  wire i_slti  = itype_r& ~Funct3[2]& Funct3[1]&~Funct3[0]; // slti 010
  wire i_sltiu = itype_r& ~Funct3[2]& Funct3[1]& Funct3[0]; // sltiu 011
  wire i_xori  = itype_r&  Funct3[2]&~Funct3[1]&~Funct3[0]; // xori 100
  wire i_srli  = itype_r& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srli 0000000 101
  wire i_srai  = itype_r& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srai 0100000 101
  wire i_ori   = itype_r&  Funct3[2]& Funct3[1]&~Funct3[0]; // ori 110
  wire i_andi  = itype_r&  Funct3[2]& Funct3[1]& Funct3[0]; // andi 111
  wire itype_r_shamt = i_slli | i_srli | i_srai;


 //jalr
	wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
  //0100011 sb,sh,sw
  wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
  wire i_sw = stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010
  wire i_sb = stype& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // sb 000
  wire i_sh = stype& ~Funct3[2]&~Funct3[1]&Funct3[0]; // sh 001
  // sb format
  wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
  wire i_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq 000
  wire i_bne = sbtype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // bne 001
  wire i_blt = sbtype & Funct3[2] & ~Funct3[1] &~Funct3[0]; // blt 100
  wire i_bge = sbtype & Funct3[2] & ~Funct3[1] & Funct3[0]; // bge 101
  wire i_bltu = sbtype & Funct3[2] & Funct3[1] &~Funct3[0]; // bltu 110
  wire i_bgeu = sbtype & Funct3[2] & Funct3[1] & Funct3[0]; // bgeu 111

  // u format
  wire i_lui  = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; //lui 0110111
  wire i_auipc = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; //auipc 0110111
  wire utype = i_lui | i_auipc;

 // j format
  wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111

  
  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTop[5] = itype_r_shamt; //itype_shamt
  assign EXTop[4] = itype_l | (itype_r & ~itype_r_shamt) | i_jalr;  //itype
  assign EXTop[3] = stype; //stype
  assign EXTop[2] = sbtype; //btype
  assign EXTop[1] = utype;   //utype
  assign EXTop[0] = i_jal; //jtype
  
    // NPC_PLUS4   3'b000
    // NPC_BRANCH  3'b001
    // NPC_JUMP    3'b010
    // NPC_JALR	3'b100
    assign NPCop[0] = sbtype;
    assign NPCop[1] = i_jal;
	  assign NPCop[2] = i_jalr;
  
    assign ALUsrc     = itype_l | itype_r | stype | i_jal | i_jalr | utype;   // ALU B is from instruction immediate

    assign  ALUop[4] = sbtype | utype;
    assign  ALUop[3] = utype | (rtype & Funct7[5]) | i_srai;
    assign  ALUop[2] = ((itype_r | rtype | sbtype) & Funct3[2]);
    assign  ALUop[1] = ((itype_r | rtype | sbtype) & Funct3[1]) | i_auipc;
    assign  ALUop[0] = ((itype_r | rtype | sbtype) & Funct3[0]) | i_lui;

    assign DMWe   = stype;  // memory write
  
    assign DMsign = Funct3[2];
    assign DMwidth = Funct3[1:0];

    assign RFWe   = rtype | itype_l |itype_r | i_jalr | i_jal | utype; // register write

    //TODO:待改变(需同时改变vh)
    //`define RFW_FROM_ALU 2'b00
    //`define RFW_FROM_MEM 2'b01
    //`define RFW_FROM_PC 2'b10
    //`define RFW_NONE 2'b11
    assign RFWsrc[0] = itype_l;
    assign RFWsrc[1] = i_jal | i_jalr;

endmodule
