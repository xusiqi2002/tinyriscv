//initial
`define PC_INITIAL 32'h0000_0000
`define NPC_INITIAL 32'h0000_0004
`define INST_INITIAL 32'h0000_0000
`define DATA_INITIAL 32'h0000_0000
`define RFADDR_INITIAL 5'b00000
`define DMADDR_INITIAL 10'b00_0000_0000
`define DMWRITE_DISABLE 4'b0000

`define ENABLE 1'b1
`define DISABLE 1'b0

//EXTop itype, stype, btype, utype, jtype
`define EXT_CTRL_NONE 6'b000000
`define EXT_CTRL_ITYPE_SHAMT 6'b100000
`define EXT_CTRL_ITYPE	6'b010000
`define EXT_CTRL_STYPE	6'b001000
`define EXT_CTRL_BTYPE	6'b000100
`define EXT_CTRL_UTYPE	6'b000010
`define EXT_CTRL_JTYPE	6'b000001


//ex
// NPCop
`define NPC_PLUS4   3'b000
`define NPC_BRANCH  3'b001
`define NPC_JUMP    3'b010
`define NPC_JALR    3'b100

//ALUsrc
`define ALU_FROM_RF2 1'b0
`define ALU_FROM_IMM 1'b1

//ALUop
`define ALUOP_nop 5'b11000
`define ALUOP_lui 5'b11001
`define ALUOP_auipc 5'b11010
`define ALUOP_add 5'b00000
`define ALUOP_sub 5'b01000
`define ALUOP_sll 5'b00001
`define ALUOP_slt 5'b00010
`define ALUOP_sltu 5'b00011
`define ALUOP_xor 5'b00100
`define ALUOP_srl 5'b00101
`define ALUOP_sra 5'b01101
`define ALUOP_or 5'b00110
`define ALUOP_and 5'b00111
`define ALUOP_beq 5'b10000
`define ALUOP_bne 5'b10001
`define ALUOP_blt 5'b10100
`define ALUOP_bge 5'b10101
`define ALUOP_bltu 5'b10110
`define ALUOP_bgeu 5'b10111


//mem
//DMwidth
`define DM_BYTE 2'b00 //b
`define DM_HALFWORD 2'b01 //n
`define DM_WORD 2'b10 //w

//{DMsign,DMwidth}
`define DM_BYTE_SIGNED 3'b000
`define DM_BYTE_UNSIGNED 3'b100
`define DM_HALFWORD_SIGNED 3'b001
`define DM_HALFWORD_UNSIGNED 3'b101
`define DM_WORD_SIGNED 3'b010
`define DM_WORD_UNSIGNED 3'b110

//wb
//RFWsrc
`define RFW_FROM_ALU 2'b00
`define RFW_FROM_MEM 2'b01
`define RFW_FROM_PC 2'b10
`define RFW_NONE 2'b11