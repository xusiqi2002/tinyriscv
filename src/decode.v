//////////////////////////
//
//文件名：decode.v
//模块名：DECODE
//创建日期：2022-7-2
//最后修改日期: 2022-7-4
//
//用于解码
//产生控制型号，将立即数扩展为32位
//
//////////////////////////
`include "def.vh"

module DECODE(
    input [`INST_BUS] inst,
    
    //以下为控制信号decode out
    output [`DECODEOUT_BUS]decode_out
);
    wire  [6:0] Op; // opcode,
    wire [6:0] Funct7;   // funct7
    wire [2:0] Funct3;
    wire [4:0] iimm_shamt;
    wire [11:0] iimm;
    wire [11:0] simm;
    wire [11:0] bimm;
    wire [19:0] uimm;
    wire [19:0] jimm;

    assign Op=inst[6:0];
    assign Funct7=inst[31:25];
    assign FUnct3=inst[14:12];
    assign iimm_shamt=inst[24:20];
    assign iimm=inst[31:20];
    assign simm={inst[31:25],inst[11:7]};
    assign bimm={inst[31],inst[7],inst[30:25],inst[11:8]};
    assign uimm=inst[31:12];
    assign jimm={inst[31],inst[19:12],inst[20],inst[30:21]};

    wire [1:0] InstType;
    wire [`REG_ADDR_BUS] rs;
    wire [`REG_ADDR_BUS] rt;
    wire [`REG_ADDR_BUS] rd;
    wire [`DATA_BUS]     immout;//产生的立即数
    wire [5:0] EXTop;    // control signal to signed extension
    wire [2:0] NPCop;    // next pc operation
    wire ALUsrc;   // ALU source for A
    wire [4:0] ALUop;    // ALU opertion
    wire DMWe;
    wire DMsign;
    wire [1:0] DMwidth;
    wire RFWe;//regfile write enable
    wire [1:0] RFWsrc;//0:aluwire 1:datamemory

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

  

    
    //INSTTYPE_AL 2'b00
    //INSTTYPE_BR 2'b01
    //INSTTYPE_AG 2'b10
    assign InstType[0] = sbtype | i_jal | i_jalr;
    assign InstType[1] = stype | itype_l;

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

    EXT U_ext(iimm_shamt,iimm,simm,bimm,uimm,jimm,EXTop,immout);

    assign decode_out = {
        InstType[1:0],
        rs[`REG_ADDR_BUS],
        rt[`REG_ADDR_BUS],
        rd[`REG_ADDR_BUS],
        immout[`DATA_BUS],
        //EXTop[5:0],
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

module EXT( 
	input  [4:0]      iimm_shamt,//instrD[24,20], 5 bits  
  input	[11:0]			iimm,      //instr[31:20], 12 bits   
	input	[11:0]			simm,      //instr[31:25, 11:7], 12 bits   
	input	[11:0]			bimm,      //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits  
	input	[19:0]			uimm,      //instrD[31,12], 20 bits  
	input	[19:0]			jimm,      //instrD[31],instrD[19,12],instrD[20],instrD[30,21], 20 bits
	input	 [5:0]			EXTOp,

	output reg [31:0] 	immout
	);
   
always  @(*)
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT:  immout <= {27'b0,iimm_shamt[4:0]};		  //slli,srli,srai
		`EXT_CTRL_ITYPE:	      immout <= {{{32-12}{iimm[11]}}, iimm[11:0]};      //jalr,itype_l,addi,,,andi
		`EXT_CTRL_STYPE:	      immout <= {{{32-12}{simm[11]}}, simm[11:0]};      //stype
		`EXT_CTRL_BTYPE:        immout <= {{{32-13}{bimm[11]}}, bimm[11:0], 1'b0};//sbtype
		`EXT_CTRL_UTYPE:	      immout <= {uimm[19:0], 12'b0}; //???????????12??0 //lui,auipc
		`EXT_CTRL_JTYPE:	      immout <= {{{32-21}{jimm[19]}}, jimm[19:0], 1'b0};//jal
		default:	               immout <= 32'b0;
	 endcase

       
endmodule