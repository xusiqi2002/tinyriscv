//////////////////////////
//
//文件名：fab.v
//模块名 FAB
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-3
//
//执行模块
//能执行运算和跳转
//
//////////////////////////
`include "def.vh"

module FAB(

    input clk,
    input rst,
    input stop,//可扩展

    input num_in,//一个顺序编号，用于确定在同时进行的两条指令的顺序
    input [`PC_BUS] pc,//pc
    input [`PC_BUS] npc,//next pc
    input [71:0] decode_out,//decode 产生的控制信号具体未定义
    input [`DATA_BUS] rfrdata1,
    input [`DATA_BUS] rfrdata2,

    output reg isbranch_pre,
    output reg branch_flag,//跳转信号
    output reg [`PC_BUS] branch_address,//跳转地址


    output num_out,
    output rfwe,//
    output [`REG_ADDR_BUS] rfwaddr,
    output [`DATA_BUS] rfwdata,

    output _endsign//暂时不用
);

    wire [2:0] InstType;
    wire [`REG_ADDR_BUS] rs;
    wire [`REG_ADDR_BUS] rt;
    wire [`REG_ADDR_BUS] rd;
    wire [`DATA_BUS]immout;//产生的立即数
    wire [5:0] EXTop;    // control signal to signed extension
    wire [2:0] NPCop;    // next pc operation
    wire ALUsrc;   // ALU source for A
    wire [4:0] ALUop;    // ALU opertion
    wire DMWe;
    wire DMsign;
    wire [1:0] DMwidth;
    wire RFWe;//regfile write enable
    wire [1:0] RFWsrc;//0:aluwire 1:datamemory

    assign {
        InstType[2:0],
        rs[`REG_ADDR_BUS],
        rt[`REG_ADDR_BUS],
        rd[`REG_ADDR_BUS],
        immout[`DATA_BUS],
        EXTop[5:0],
        NPCop[2:0],
        ALUsrc,
        ALUop[4:0],
        DMWe,
        DMsign,
        DMwidth[1:0],
        RFWe,
        RFWsrc[1:0]
    } = decode_out;


    reg [`DATA_BUS] rfwdata1;
    wire [31:0] aluout;


     wire Zero;
     reg [`DATA_BUS] B;
     always @ (*)
     case (ALUsrc)
         `ALU_FROM_IMM: B <= immout;
         `ALU_FROM_RF2: B <= rfrdata2;
     endcase

     ALU U_ALU(
         .A(rfrdata1),
         .B(B),
         .ALUop(ALUop),
         .PC(pc),
         .C(aluout),
         .Zero(Zero)
     );

     
    always @(*)
    begin
        case (NPCop & {2'b11,Zero})
            `NPC_PLUS4: branch_address = pc + 4;
            `NPC_BRANCH: branch_address = pc+immout;//BEQ,BNE
            `NPC_JUMP: branch_address = pc+immout;//JAL
            `NPC_JALR: branch_address =aluout;//JALR
            default: branch_address = npc;
        endcase
        branch_flag <= (branch_address != npc);
        isbranch_pre <= (NPCop == `NPC_BRANCH);


        case (RFWsrc)
            //`RFW_NONE: rfwdata <= `DATA_INITIAL;
            `RFW_FROM_ALU: rfwdata1 <= aluout;
            //`RFW_FROM_MEM: mem_rfwdata <= mem_dmout;
            `RFW_FROM_PC: rfwdata1 <= pc + 4;
            default: rfwdata1 <= `DATA_INITIAL;
        endcase
    end


//流水线寄存器

    FAB_PLREG REG1(
        .clk(clk),
        .rst(rst),
        .stop(stop),
        .num_in(num_in),
        .num_out(num_out),
        .RFWe(RFWe),
        .rfwe(rfwe),
        .rd(rd),
        .rfwaddr(rfwaddr),
        .rfwdata1(rfwdata1),
        .rfwdata(rfwdata)
    );

endmodule



//模块名：FAB_PLREG
//FAB中的流水线寄存器
module FAB_PLREG(
    input clk,
    input rst,
    input stop,

    input num_in,
    output reg num_out,
    input RFWe,
    output reg rfwe,
    input [`REG_ADDR_BUS] rd,
    output reg [`REG_ADDR_BUS] rfwaddr,
    input [`DATA_BUS] rfwdata1,
    output reg [`DATA_BUS] rfwdata
);


    always @ (posedge clk)
    begin
        if(rst)
        begin
            num_out <= 0;
            rfwe <= `DISABLE;
            rfwaddr <= 5'b00000;
            rfwdata <= `DATA_INITIAL;
        end
        else if(stop)
        begin
            num_out <= num_out;
            rfwe <= rfwe;
            rfwaddr <= rfwaddr;
            rfwdata <= rfwdata;
        end
        else
        begin
            num_out <= num_in;
            rfwe <= RFWe;
            rfwaddr <= rd;
            rfwdata <= rfwdata1;
        end
    end


endmodule 
