//////////////////////////
//
//文件名：SCPU.v
//模块名：SCPU
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-4
//
//
//////////////////////////
`include "def.vh"
module SCPU(
    input clk,            // clock
    input reset,          // reset
    output [31:0] inst_addr_out,
    input [63:0] inst_in,     //一次存取两条指令
   


//用于传给RAM
    output mem_w, // output: memory write signal
    output [`MEM_ADDR_BUS] Addr_out,   // ALU output
    input [`DATA_BUS] Data_in,     // data from data memory
    output [`DATA_BUS] Data_out,// data to data memory
    output [3:0] DWea,
    
    input wire INT//中断信号，暂不实现中断和异常
);

    wire branch_num;
    wire isbranch_pre;
    wire branch_flag;//跳转信号
    wire branch_address;//跳转地址

//取指：一次取多条
//内置PC,输出PC地址
    IF U_IF(

    );

    wire [3:0] launch_flag;

//指令缓存
//代替IF,ID间的流水线寄存器
    INST_BUF U_INSTBUF(

    );



    wire [`DECODEOUT_BUS] decode_out1;
    wire [`DECODEOUT_BUS] decode_out2;
//解码模块1
    DECODE DECODE_1(
        .inst(),
        .decode_out(decode_out1)
    );

//解码模块2
    DECODE DECODE_2(
        .inst(),
        .decode_out(decode_out2)
    );

    wire [`DATA_BUS] rfrd1;
    wire [`DATA_BUS] rfrd2;
    wire [`DATA_BUS] rfrd3;
    wire [`DATA_BUS] rfrd4;

    wire lout1_num;
    wire [`PC_BUS] lout1_pc;
    wire [`PC_BUS] lout1_npc;
    wire [`DECODEOUT_BUS] lout1_decodeout;
    wire [`DATA_BUS] lout1_rfrd1;
    wire [`DATA_BUS] lout1_rfrd2;


    wire lout2_num;
    wire [`PC_BUS] lout2_pc;
    wire [`PC_BUS] lout2_npc;
    wire [`DECODEOUT_BUS] lout2_decodeout;
    wire [`DATA_BUS] lout2_rfrd1;
    wire [`DATA_BUS] lout2_rfrd2;

    wire [`RFW_BUS] ex1_rfw_s1;
    wire [`RFW_BUS] ex1_rfw;

    wire [`RFW_BUS] ex2_rfw_s1;
    wire [`RFW_BUS] ex2_rfw;

    wire ex1in_num;
    wire [`PC_BUS] ex1in_pc;
    wire [`PC_BUS] ex1in_npc;
    wire [`DECODEOUT_BUS] ex1in_decodeout;
    wire [`DATA_BUS] ex1in_rfrd1;
    wire [`DATA_BUS] ex1in_rfrd2;

    wire ex1out_num;

    wire ex2in_num;
    wire [`PC_BUS] ex2in_pc;
    wire [`PC_BUS] ex2in_npc;
    wire [`DECODEOUT_BUS] ex2in_decodeout;
    wire [`DATA_BUS] ex2in_rfrd1;
    wire [`DATA_BUS] ex2in_rfrd2;

    wire ex2out_num;

//对解码的输出进行选择，送入执行阶段
    LAUNCH_SELECT U_L(
        .in1_pc(),
        .in1_npc(),
        .in1_decodeout(decode_out1),
        .receive_flag1(),
    
        .in2_pc(),
        .in2_npc(),
        .in2_decodeout(decode_out2),
        .receive_flag2(),

        .rfrd1(rfrd1),
        .rfrd2(rfrd2),
        .rfrd3(rfrd3),
        .rfrd4(rfrd4),

        .rfw1(ex1in_num ? ex2_rfw_s1 : ex1_rfw_s1),
        .rfw2(ex1in_num ? ex1_rfw_s1 : ex2_rfw_s1),
        .rfw3(ex1out_num ? ex2_rfw : ex1_rfw),
        .rfw4(ex1out_num ? ex1_rfw : ex2_rfw),

        .out1_num(lout1_num),
        .out1_pc(lout1_pc),
        .out1_npc(lout1_npc),
        .out1_decodeout(lout1_decodeout),
        .out1_rfrdata1(lout1_rfrd1),
        .out1_rfrdata2(lout1_rfrd2),

        .out2_num(lout2_num),
        .out2_pc(lout2_pc),
        .out2_npc(lout2_npc),
        .out2_decodeout(lout2_decodeout),
        .out2_rfrdata1(lout2_rfrd1),
        .out2_rfrdata2(lout2_rfrd2),

        .launch_flag(launch_flag) 

    );

//decode和excute之间的流水线寄存器
    RLREG_DE_EX PRDEEX1(
        .clk(clk),
        .rst(),
        .stop(),
        .num_in(lout1_num),
        .num_out(ex1in_num),
        .pc_in(lout1_pc),//pc
        .pc_out(ex1in_pc),//pc
        .npc_in(lout1_npc),//next pc
        .npc_out(ex1in_npc),//next pc
        .decode_out_in(lout1_decodeout),
        .decode_out_out(ex1in_decodeout),
        .rfrdata1_in(lout1_rfrd1),
        .rfrdata1_out(ex1in_rfrd1),
        .rfrdata2_in(lout1_rfrd2),
        .rfrdata2_out(ex1in_rfrd2)
    );

    
    RLREG_DE_EX PRDEEX2(
        .clk(clk),
        .rst(),
        .stop(),
        .num_in(lout2_num),
        .num_out(ex2in_num),
        .pc_in(lout2_pc),//pc
        .pc_out(ex2in_pc),//pc
        .npc_in(lout2_npc),//next pc
        .npc_out(ex2in_npc),//next pc
        .decode_out_in(lout2_decodeout),
        .decode_out_out(ex2in_decodeout),
        .rfrdata1_in(lout2_rfrd1),
        .rfrdata1_out(ex2in_rfrd1),
        .rfrdata2_in(lout2_rfrd2),
        .rfrdata2_out(ex2in_rfrd2)
    );



//执行模块1,
//支持运算和跳转
    FAB EXC1(
        .clk(clk),
        .rst_s1(),
        .stop(),//可扩展
        .num_in(ex1in_num),//一个顺序编号，用于确定在同时进行的两条指令的顺序
        .pc(ex1in_pc),//pc
        .npc(ex1in_npc),//next pc
        .decode_out(ex1in_decodeout),//decode 产生的控制信号具体未定义
        .rfrdata1(ex1in_rfrd1),
        .rfrdata2(ex1in_rfrd2),

        .branch_num(branch_num),
        .isbranch_pre(isbranch_pre),
        .branch_flag(branch_flag),//跳转信号
        .branch_address(branch_address),//跳转地址

        .rfw_s1(ex1_rfw_s1),

        .num_out(ex1out_num),
        .rfw(ex1_rfw)
        //._endsign()//暂时不用
    );



//执行模块2
//支持运算和访存

    FAM EXC2(
        .clk(clk),
        .rst_s1(),
        .stop(),

        .num_in(ex2in_num),//用于确认该指令在并行的两条指令中的顺序
        .pc(ex2in_pc),//pc
        .decode_out(lout2_decodeout),//decode 产生的控制信号
        .rfrdata1(lout2_rfrd1),
        .rfrdata2(lout2_rfrd2),
    
        .rfw_s1(ex2_rfw_s1),

        .mem_w(mem_w),
        .DWea(DWea),//传出的写信号
        .Addr_out(Addr_out),
        .Data_out(Data_out),
        .Data_in(Data_in),

        .num_out(ex2out_num),
        .rfw(ex2_rfw)

        //._endsign()//暂时不用
    );

    wire wbin1_num;
    wire wbin1_rfwe;
    wire [`REG_ADDR_BUS] wbin1_rfwa;
    wire [`DATA_BUS] wbin1_rfwd;

//流水线寄存器 执行到写回的流水线寄存器
    PLREG_WB PRWB1(
        .clk(clk),
        .rst(),
        .stop(),
        .num_in(),
        .num_out(wbin1_num),
        .rfwe_in(),
        .rfwe_out(wbin1_rfwe),
        .rfwaddr_in(),
        .rfwaddr_out(wbin1_rfwa),
        .rfwdata_in(),
        .rfwdata_out(wbin1_rfwd)
    );


    wire wbin2_num;
    wire wbin2_rfwe;
    wire [`REG_ADDR_BUS] wbin2_rfwa;
    wire [`DATA_BUS] wbin2_rfwd;

    PLREG_WB PRWB2(
        .clk(clk),
        .rst(),
        .stop(),
        .num_in(),
        .num_out(wbin2_num),
        .rfwe_in(),
        .rfwe_out(wbin2_rfwe),
        .rfwaddr_in(),
        .rfwaddr_out(wbin2_rfwa),
        .rfwdata_in(),
        .rfwdata_out(wbin2_rfwd)
    );

    wire rfwe1;
    wire rfwe2;
//写回阶段
    WB U_WB(
        .num_in1(wbin1_num),
        .rfwe_in1(wbin1_rfwe),
        .rfwaddr_in1(wbin1_rfwa),
        .num_in2(wbin2_num),
        .rfwe_in2(wbin2_rfwe),
        .rfwaddr_in2(wbin2_rfwa),
        .rfwe_out1(rfwe1),
        .rfwe_out2(rfwe2)
    );



//32个通用寄存器
    RF U_RF(
        .clk(clk),
        .rst(reset),

        .raddr1(decode_out1[`DC_RS]),
        .rdata1(rfrd1),
        .raddr2(decode_out1[`DC_RT]),
        .rdata2(rfrd2),
        .raddr3(decode_out2[`DC_RS]),
        .rdata3(rfrd3),
        .raddr4(decode_out2[`DC_RT]),
        .rdata4(rfrd4),

        .we1(rfwe1),
        .waddr1(wbin1_rfwa),
        .wdata1(wbin1_rfwd),
        .we2(rfwe2),
        .waddr2(wbin2_rfwa),
        .wdata2(wbin2_rfwd)
    );


endmodule



module RLREG_DE_EX(
    input clk,
    input rst,
    input stop,
    input num_in,
    output reg num_out,
    input [`PC_BUS] pc_in,//pc
    output reg [`PC_BUS] pc_out,//pc
    input [`PC_BUS] npc_in,//next pc
    output reg [`PC_BUS] npc_out,//next pc
    input [`DECODEOUT_BUS] decode_out_in,
    output reg [`DECODEOUT_BUS] decode_out_out,
    input [`DATA_BUS] rfrdata1_in,
    output reg [`DATA_BUS] rfrdata1_out,
    input [`DATA_BUS] rfrdata2_in,
    output reg [`DATA_BUS] rfrdata2_out
);

    always @ (posedge clk)
    begin
        if(rst)
        begin
            num_out <= 1'b0;
            pc_out <= `PC_INITIAL;//pc
            npc_out <= `NPC_INITIAL;//next pc
            decode_out_out <= `DECODEOUTLEN'b0;
            rfrdata1_out <= `DATA_INITIAL;
            rfrdata2_out <= `DATA_INITIAL;
        end
        else if(stop)
        begin
            num_out <= num_out;
            pc_out <= pc_out;//pc
            npc_out <= npc_out;//next pc
            decode_out_out <= decode_out_out;
            rfrdata1_out <= rfrdata1_out;
            rfrdata2_out <= rfrdata2_out;
        end
        else
        begin
            num_out <= num_in;
            pc_out <= pc_in;//pc
            npc_out <= npc_in;//next pc
            decode_out_out <= decode_out_in;
            rfrdata1_out <= rfrdata1_in;
            rfrdata2_out <= rfrdata2_in;
        end
    end

endmodule

//模块名：PLREG_EX_WB
//ex到wb的流水线寄存器
module PLREG_EX_WB(
    input clk,
    input rst,
    input stop,
    input num_in,
    output reg num_out,
    input rfwe_in,
    output reg rfwe_out,
    input [`REG_ADDR_BUS] rfwaddr_in,
    output reg [`REG_ADDR_BUS] rfwaddr_out,
    input [`DATA_BUS] rfwdata_in,
    output reg [`DATA_BUS] rfwdata_out

);
    always @ (posedge clk)
    if(rst)
    begin
        num_out <= 1'b0;
        rfwe_out <= `DISABLE;
        rfwaddr_out <= 5'b00000;
        rfwdata_out <= `DATA_INITIAL;
    end
    else if(stop)
    begin
        num_out <= num_out;
        rfwe_out <= rfwe_out;
        rfwaddr_out <= rfwaddr_out;
        rfwdata_out <= rfwdata_out;
    end
    else
    begin
        num_out <= num_in;
        rfwe_out <= rfwe_in;
        rfwaddr_out <= rfwaddr_in;
        rfwdata_out <= rfwdata_in;
    end

endmodule