////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: id.v
//
//id阶段
//读出寄存器数据，立即数拓展
//产生控制信号
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module ID(
    input clk,
    //input reset,

    input [31:0] id_pc,
    input [31:0] id_npc,
    input [31:0] id_inst,

    input ex_RFWe,
    input [1:0] ex_RFWsrc,
    input [4:0] ex_rfwaddr,
    input [31:0] ex_aluout,
    input [31:0] ex_pc,

    input mem_RFWe,
    input [4:0] mem_rfwaddr,
    input [31:0] mem_rfwdata,

    output [2:0] id_NPCop,    // next pc operation
    output id_ALUsrc,   // ALU source for A
    output [4:0] id_ALUop,    // ALU opertion
    output id_DMWe,
    output id_DMsign,
    output [1:0] id_DMwidth,
    output id_RFWe,//regfile write enable
    output [1:0] id_RFWsrc,
    output reg [3:0] id_DWea,

    output [31:0] id_immout,

    output [4:0] id_rfwaddr,

    output reg [31:0] id_rfrdata1,
    output reg [31:0] id_rfrdata2,


    output reg id_stall,

    output reg id_branch_flag,
    output reg [31:0] id_branch_address,

    input RFrst,
    input RFWe,
    input [4:0] rfwaddr,
    input [31:0] rfwdata
);
    wire [6:0] Op;
    wire [6:0] Funct7;
    wire [2:0] Funct3;
    wire [5:0] id_EXTop;

    assign Op = id_inst[6:0];  // instruction
    assign Funct7 = id_inst[31:25]; // funct7
    assign Funct3 = id_inst[14:12]; // funct3


    CTRL U_CRTL(
        .Op(Op), // opcode,
        .Funct7(Funct7),   // funct7
        .Funct3(Funct3),   // funct3
        .EXTop(id_EXTop),    // control signal to signed extension
        .NPCop(id_NPCop),    // next pc operation
        .ALUsrc(id_ALUsrc),   // ALU source for A
        .ALUop(id_ALUop),    // ALU opertion
        .DMWe(id_DMWe),
        .DMsign(id_DMsign),
        .DMwidth(id_DMwidth),
        .RFWe(id_RFWe),//regfile write enable
        .RFWsrc(id_RFWsrc)//0:aluoutput 1:datamemory
    );


    wire [4:0] iimm_shamt;
    wire [11:0] iimm; //instr[31:20], 12 bits
	wire [11:0] simm; //instr[31:25, 11:7], 12 bits
	wire [11:0] bimm; //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	wire [19:0] uimm;
	wire [19:0] jimm;
    
	assign iimm_shamt = id_inst[24:20];
	assign iimm = id_inst[31:20];
	assign simm={id_inst[31:25],id_inst[11:7]};
	assign bimm={id_inst[31],id_inst[7],id_inst[30:25],id_inst[11:8]};
	assign uimm=id_inst[31:12];
	assign jimm={id_inst[31],id_inst[19:12],id_inst[20],id_inst[30:21]};
   

    EXT U_EXT( 
        .iimm_shamt(iimm_shamt),
        .iimm(iimm), //instr[31:20], 12 bits
        .simm(simm), //instr[31:25, 11:7], 12 bits
        .bimm(bimm), //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
        .uimm(uimm),
        .jimm(jimm),
        .EXTop(id_EXTop),
        .immout(id_immout)
    );
    
    wire [4:0] id_rfraddr1;
    wire [4:0] id_rfraddr2;
    wire [31:0] rfrdata1;
    wire [31:0] rfrdata2;

    assign id_rfraddr1[4:0] = id_inst[19:15];  // rs1
    assign id_rfraddr2[4:0]  = id_inst[24:20];  // rs2
    assign id_rfwaddr[4:0] = id_inst[11:7];  // rd


    RF U_RF(
        .clk(clk), 
        .rst(RFrst),
        .RFWr(RFWe), //write_enable
        .A1(id_rfraddr1), .A2(id_rfraddr2), .A3(rfwaddr), //A1,A2: read_address
        .WD(rfwdata), // writedata
        .RD1(rfrdata1),//read_data
        .RD2(rfrdata2)
    );


    reg [3:0] d_hz;

    always @ (*)
    begin
        //TODO:换一种写法： stall 和 rfrdata 分开赋值
        d_hz[3] <= (ex_RFWe) && (ex_rfwaddr == id_rfraddr1);
        d_hz[2] <= (ex_RFWe) && (ex_rfwaddr == id_rfraddr2);
        d_hz[1] <= (mem_RFWe) && (mem_rfwaddr == id_rfraddr1);
        d_hz[0] <= (mem_RFWe) && (mem_rfwaddr == id_rfraddr2);
        if((d_hz[3] || d_hz[2]) && (ex_RFWsrc == `RFW_FROM_MEM))//stall
        begin
            id_stall <= `ENABLE;
            id_rfrdata1 <= rfrdata1;
            id_rfrdata2 <= rfrdata2;
        end
        else
        begin
            id_stall <= `DISABLE;
            //rdata1
            if(d_hz[3])
                case (ex_RFWsrc)
                    `RFW_FROM_ALU : id_rfrdata1 <= ex_aluout;
                    `RFW_FROM_PC : id_rfrdata1 <= ex_pc;
                    default : id_rfrdata1 <= `DATA_INITIAL;
                endcase
            else if(d_hz[1])
                id_rfrdata1 <= mem_rfwdata;
            else
                id_rfrdata1 <= rfrdata1;
            //rdata2
            if(d_hz[2])
                case (ex_RFWsrc)
                    `RFW_FROM_ALU : id_rfrdata2 <= ex_aluout;
                    `RFW_FROM_PC : id_rfrdata2 <= ex_pc;
                    default : id_rfrdata2 <= `DATA_INITIAL;
                endcase
            else if(d_hz[0])
                id_rfrdata2 <= mem_rfwdata;
            else
                id_rfrdata2 <= rfrdata2;
        end
    end

    always @(*)
        if(id_NPCop == `NPC_JUMP)//JAL
        begin
            id_branch_address <= id_pc+id_immout;
            id_branch_flag <= (id_branch_address != id_npc);
        end
        else
        begin
            id_branch_address <= id_npc;
            id_branch_flag <= `DISABLE;
        end


    always @ (*)
    begin
    if(id_DMWe)
        case (id_DMwidth)
            `DM_BYTE: id_DWea <= 4'b0001;
            `DM_HALFWORD: id_DWea <= 4'b0011;
            `DM_WORD: id_DWea <= 4'b1111;
            default: id_DWea <= 4'b0000;
        endcase
        else
            id_DWea <= 4'b0000;
    end

endmodule