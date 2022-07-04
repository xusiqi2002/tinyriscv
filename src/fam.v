//////////////////////////
//
//文件名：fab.v
//模块名 FAB
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-3
//
//执行模块
//能执行运算和访存
//
//////////////////////////
`include "def.vh"

module FAM(
    input clk,
    input rst_s1,
    input stop,

    input num_in,//用于确认该指令在并行的两条指令中的顺序
    input [`PC_BUS] pc,//pc
    //input [`PC_BUS] npc,//next pc
    input [`DATA_BUS] imm,//立即数
    input [`DECODEOUT_BUS] decode_out,//decode 产生的控制信号具体未定义
    output [`DATA_BUS] rfrdata1,
    output [`DATA_BUS] rfrdata2,

    //TODO: 需要传出中间的寄存器写信号用于数据冒险


    output reg mem_w,
    output reg [3:0] DWea,//传出的写信号
    output reg [`MEM_ADDR_BUS] Addr_out,
    output reg [`DATA_BUS] Data_out,
    input [`DATA_BUS] Data_in,

    
    output num_out,
    output rfwe,//寄存器写
    output [`REG_ADDR_BUS] rfwaddr,
    output reg [`DATA_BUS] rfwdata,

    output _endsign//暂时不用
);


    wire [1:0] InstType;
    wire [`REG_ADDR_BUS] rs;
    wire [`REG_ADDR_BUS] rt;
    wire [`REG_ADDR_BUS] rd;
    wire rs_v;
    wire rt_v;
    wire [`DATA_BUS]immout;//产生的立即数
    //wire [5:0] EXTop;    // control signal to signed extension
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
        rs_v,
        rt_v,
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
    } = decode_out;

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


    wire mem_DMWe;
    wire mem_DMsign;
    wire [1:0] mem_DMwidth;
    wire mem_RFWe;//regfile write enable
    wire [1:0] mem_RFWsrc;//0:aluwire 1:datamemory

    wire [`PC_BUS] mem_pc;
    wire [`DATA_BUS] mem_rfrdata2;
    wire [`DATA_BUS] mem_aluout;

//流水线寄存器
    FAM_PLREG PR1(
        .clk(clk),
        .rst(rst_s1),
        .stop(stop),
        .DMWe(DMWe),
        .mem_DMWe(mem_DMWe),
        .DMsign(DMsign),
        .mem_DMsign(mem_DMsign),
        .DMwidth(DMwidth),
        .mem_DMwidth(mem_DMwidth),
        .RFWsrc(RFWsrc),
        .mem_RFWsrc(mem_RFWsrc),
        .RFWe(RFWe),
        .rfwe(rfwe),//寄存器写
        .rd(rd),
        .rfwaddr(rfwaddr),
        .pc(pc),
        .mem_pc(mem_pc),
        .rfrdata2(rfrdata2),
        .mem_rfrdata2(mem_rfrdata2),
        .aluout(aluout),
        .mem_aluout(mem_aluout)
    );


//第二个阶段
//作用相当与流水线中的mem
//产生与

    reg [31:0] dmout;

    wire [31:0] _Data_in;
    assign _Data_in = Data_in >> (Addr_out[1:0] * 8);

    always @ (*)
    begin
        case ({mem_DMsign,mem_DMwidth})
            `DM_BYTE_SIGNED: dmout <= {{24{_Data_in[7]}},_Data_in[7:0]};
            `DM_BYTE_UNSIGNED: dmout <= {24'b0,_Data_in[7:0]};
            `DM_HALFWORD_SIGNED: dmout <= {{16{_Data_in[15]}},_Data_in[15:0]};
            `DM_HALFWORD_UNSIGNED: dmout <= {16'b0,_Data_in[15:0]};
            `DM_WORD_SIGNED: dmout <= _Data_in;
            default dmout <= 32'b0;
        endcase
        
        Data_out <= mem_rfrdata2;
        Addr_out <= mem_aluout;
        mem_w <= mem_DMWe;
        if(mem_DMWe)
        case (mem_DMwidth)
            `DM_BYTE: DWea <= 4'b0001 << Addr_out[1:0];
            `DM_HALFWORD: DWea <= 4'b0011 << Addr_out[1:0];
            `DM_WORD: DWea <= 4'b1111;
            default: DWea <= 4'b0000;
        endcase
        else
            DWea <= 4'b0000;
        case (mem_RFWsrc)
            `RFW_NONE: rfwdata <= `DATA_INITIAL;
            `RFW_FROM_ALU: rfwdata <= mem_aluout;
            `RFW_FROM_MEM: rfwdata <= dmout;
            `RFW_FROM_PC: rfwdata <= mem_pc + 4;
        endcase
        
    end


endmodule



//模块名：FAM_PLREG
//FAM中的流水线寄存器
module FAM_PLREG(
    input clk,
    input rst,
    input stop,
    input num_in,
    output reg num_out,
    input DMWe,
    output reg mem_DMWe,
    input DMsign,
    output reg mem_DMsign,
    input [1:0] DMwidth,
    output reg [1:0] mem_DMwidth,
    input [1:0] RFWsrc,
    output reg [1:0] mem_RFWsrc,
    input RFWe,
    output reg rfwe,//寄存器写
    input [`REG_ADDR_BUS] rd,
    output reg [`REG_ADDR_BUS] rfwaddr,
    input [`PC_BUS]pc,
    output reg [`PC_BUS]mem_pc,
    input [`DATA_BUS] rfrdata2,
    output reg [`DATA_BUS] mem_rfrdata2,
    input [`DATA_BUS] aluout,
    output reg [`DATA_BUS] mem_aluout
);

    always @ (posedge clk)
    if(rst)
    begin
        num_out <= 0;
        mem_DMWe <= `DISABLE;
        mem_DMsign <= 1'b0;
        mem_DMwidth <= 2'b0;
        mem_RFWsrc <= 2'b0;
        rfwe <= `DISABLE;
        rfwaddr <= 5'b0;
        mem_pc <= `PC_INITIAL;
        mem_rfrdata2 <= `DATA_INITIAL;
        mem_aluout <= `DATA_INITIAL;
    end
    else if(stop)
    begin
        num_out <= num_out;
        mem_DMWe <= mem_DMWe;
        mem_DMsign <= mem_DMsign;
        mem_DMwidth <= mem_DMwidth;
        mem_RFWsrc <= mem_RFWsrc;
        rfwe <= rfwe;
        rfwaddr <= rfwaddr;
        mem_pc <= mem_pc;
        mem_rfrdata2 <= mem_rfrdata2;
        mem_aluout <= mem_aluout;
    end
    else
    begin
        num_out <= num_in;
        mem_DMWe <= DMWe;
        mem_DMsign <= DMsign;
        mem_DMwidth <= DMwidth;
        mem_RFWsrc <= RFWsrc;
        rfwe <= RFWe;
        rfwaddr <= rd;
        mem_pc <= pc;
        mem_rfrdata2 <= rfrdata2;
        mem_aluout <= aluout;
    end

endmodule 

