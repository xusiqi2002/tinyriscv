////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: SCPU.v
//
//SCPU
//
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module SCPU(

    input clk,            // clock
    input reset,          // reset
    input [31:0] inst_in,     // instruction
    input [31:0] Data_in,     // data from data memory
   
    input wire INT,

    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    //output Data_sign,
    //output [1:0] Data_width,
    output [3:0] DWea

    //input  [4:0] reg_sel    // register selection (for debug use)
    
);

    //if
    wire [31:0] if_pc;
    wire [31:0] if_npc;
    wire [31:0] if_inst;
    assign if_inst = inst_in;
    assign PC_out = if_pc;

    wire branch_flag;
    wire [31:0] branch_address;

    //id
    wire [31:0] id_pc;
    wire [31:0] id_npc;
    wire [31:0] id_inst;
    
    wire [2:0] id_NPCop;   // next pc operation
    wire id_ALUsrc;   // ALU source for A
    wire [4:0] id_ALUop;    // ALU opertion
    wire id_DMWe;
    wire id_DMsign;
    wire [1:0] id_DMwidth;
    wire id_RFWe;//regfile write enable
    wire [1:0] id_RFWsrc;

    wire [31:0] id_immout;

    wire [4:0] id_rfraddr1;
    wire [4:0] id_rfraddr2;
    wire [4:0] id_rfwaddr;

    wire [31:0] id_rfrdata1;
    wire [31:0] id_rfrdata2;

    wire id_branch_flag;
    wire [31:0] id_branch_address;
    wire id_stall;

    wire RFWe;
    wire [4:0] rfwaddr;
    wire [31:0] rfwdata;
    //ex
    
    wire [31:0] ex_pc;
    wire [31:0] ex_npc;
    wire [2:0] ex_NPCop;
    wire ex_ALUsrc;
    wire [4:0]ex_ALUop;
    wire ex_DMWe;
    wire ex_DMsign;
    wire [1:0] ex_DMwidth;
    wire ex_RFWe;//regfile write enable
    wire [1:0] ex_RFWsrc;//0:aluoutput 1:datamemory
    

    wire [4:0] ex_rfwaddr;//regfile write address
    wire [31:0] ex_immout;
    wire [31:0] ex_rfrdata1;
    wire [31:0] ex_rfrdata2;
    wire [31:0] ex_aluout;

    wire ex_branch_flag;
    wire [31:0] ex_branch_address;

//mem
    wire [31:0] mem_pc;

    wire mem_RFWe;//regfile write enable
    wire [1:0] mem_RFWsrc;//0:aluoutput 1:datamemory
    wire mem_DMWe;
    wire mem_DMsign;
    wire [1:0] mem_DMwidth;

    wire [4:0] mem_rfwaddr;//regfile write address
    wire [31:0] mem_rfrdata2;
    wire [31:0] mem_aluout;

    //wire [31:0] mem_dmout;
    wire [31:0] mem_rfwdata;


    wire id_rst;
    wire ex_rst;
    wire mem_rst;
    wire wb_rst;
    wire if_stop;
    wire id_stop;
    wire ex_stop;
    wire mem_stop;
    wire wb_stop;

    //wb
    wire wb_RFWe;//regfile write enable
    wire [4:0] wb_rfwaddr;//regfile write address
    wire [31:0] wb_rfwdata;

    wire [3:0] id_DWea;
    wire [3:0] ex_DWea;
    wire [3:0] mem_DWea;



    //if
    PC U_PC(
        .clk(clk),//input
        .rst(reset),//input
        .stop(if_stop),//input: stop
        .branch_flag(branch_flag),//input
        .branch_address(branch_address),//input [31:0]
        .PC(if_pc),//output [31:0]
        .NPC(if_npc)
    );

    //id
    IF_ID U_IFID(
        .clk(clk),
        .rst(id_rst),
        .stop(id_stop),
        .if_inst(if_inst),
        .id_inst(id_inst),
        .if_pc(if_pc),
        .id_pc(id_pc),
        .if_npc(if_npc),
        .id_npc(id_npc)
    );

    ID U_ID(
        .clk(clk),

        .id_pc(id_pc),
        .id_npc(id_npc),
        .id_inst(id_inst),

        .ex_RFWe(ex_RFWe),
        .ex_RFWsrc(ex_RFWsrc),
        .ex_rfwaddr(ex_rfwaddr),
        .ex_aluout(ex_aluout),
        .ex_pc(ex_pc),
        .mem_RFWe(mem_RFWe),
        .mem_rfwaddr(mem_rfwaddr),
        .mem_rfwdata(mem_rfwdata),


        .id_NPCop(id_NPCop),
        .id_ALUsrc(id_ALUsrc),
        .id_ALUop(id_ALUop),
        .id_DMWe(id_DMWe),
        .id_DMsign(id_DMsign),
        .id_DMwidth(id_DMwidth),
        .id_RFWe(id_RFWe),
        .id_RFWsrc(id_RFWsrc),
        .id_DWea(id_DWea),

        .id_immout(id_immout),

        //.id_rfraddr1(id_rfraddr1),
        //.id_rfraddr2(id_rfraddr2),
        .id_rfwaddr(id_rfwaddr),

        .id_rfrdata1(id_rfrdata1),
        .id_rfrdata2(id_rfrdata2),

        .id_stall(id_stall),

        .id_branch_flag(id_branch_flag),
        .id_branch_address(id_branch_address),

        .RFrst(RFrst),
        .RFWe(RFWe),
        .rfwaddr(rfwaddr),
        .rfwdata(rfwdata)
    );

    //ex

    ID_EX U_IDEX(
        .clk(clk),//input
        .rst(ex_rst),//input
        .stop(ex_stop),//input

        .id_npc(id_npc),
        .ex_npc(ex_npc),

        //id
        .id_pc(id_pc),
        .ex_pc(ex_pc),

        .id_NPCop(id_NPCop),
        .ex_NPCop(ex_NPCop),
        
        .id_ALUsrc(id_ALUsrc),
        .ex_ALUsrc(ex_ALUsrc),

        .id_ALUop(id_ALUop),
        .ex_ALUop(ex_ALUop),

        .id_immout(id_immout),//immediate
        .ex_immout(ex_immout),

        .id_rfrdata1(id_rfrdata1),
        .ex_rfrdata1(ex_rfrdata1),

        .id_rfrdata2(id_rfrdata2),
        .ex_rfrdata2(ex_rfrdata2),

        //mem
        .id_DMWe(id_DMWe),//datamemory write enable
        .ex_DMWe(ex_DMWe),

        .id_DMsign(id_DMsign),
        .ex_DMsign(ex_DMsign),

        .id_DMwidth(id_DMwidth),
        .ex_DMwidth(ex_DMwidth),

        .id_DWea(id_DWea),
        .ex_DWea(ex_DWea),

        //wb
        .id_RFWe(id_RFWe),//regfile write enable
        .ex_RFWe(ex_RFWe),

        .id_RFWsrc(id_RFWsrc),
        .ex_RFWsrc(ex_RFWsrc),

        .id_rfwaddr(id_rfwaddr),//regfile write address
        .ex_rfwaddr(ex_rfwaddr)

    );


    EX U_EX(
        .clk(clk),
        .ex_pc(ex_pc),
        .ex_npc(ex_npc),
        .ex_NPCop(ex_NPCop),
        .ex_ALUsrc(ex_ALUsrc),
        .ex_ALUop(ex_ALUop),
        .ex_immout(ex_immout),
        .ex_rfrdata1(ex_rfrdata1),
        .ex_rfrdata2(ex_rfrdata2),
        .ex_aluout(ex_aluout),
        .ex_branch_flag(ex_branch_flag),
        .ex_branch_address(ex_branch_address)
    );

    //mem
    EX_MEM U_EXMEM(
        .clk(clk),//input
        .rst(mem_rst),//input
        .stop(mem_stop),//input

        .ex_pc(ex_pc),
        .mem_pc(mem_pc),

        //mem
        .ex_DMWe(ex_DMWe),//datamemory write enable
        .mem_DMWe(mem_DMWe),

        .ex_DMsign(ex_DMsign),
        .mem_DMsign(mem_DMsign),

        .ex_DMwidth(ex_DMwidth),
        .mem_DMwidth(mem_DMwidth),

        .ex_DWea(ex_DWea),
        .mem_DWea(mem_DWea),

        .ex_aluout(ex_aluout),
        .mem_aluout(mem_aluout),

        .ex_rfrdata2(ex_rfrdata2),
        .mem_rfrdata2(mem_rfrdata2),
    
        //wb
        .ex_RFWe(ex_RFWe),//regfile write enable
        .mem_RFWe(mem_RFWe),

        .ex_RFWsrc(ex_RFWsrc),
        .mem_RFWsrc(mem_RFWsrc),

        .ex_rfwaddr(ex_rfwaddr),//regfile write address
        .mem_rfwaddr(mem_rfwaddr)

    );


    MEM U_MEM(
        .clk(clk),
        //.stop(mem_stop),
        .mem_DMWe(mem_DMWe),
        .mem_DMsign(mem_DMsign),
        .mem_DMwidth(mem_DMwidth),
        .mem_RFWsrc(mem_RFWsrc),
        //.mem_DWea(mem_DWea),
        .mem_pc(mem_pc),
        .mem_aluout(mem_aluout),
        .mem_rfrdata2(mem_rfrdata2),
        //.mem_dmout(mem_dmout),
        .mem_rfwdata(mem_rfwdata),

        //.mem_w(mem_w),
        //.DWea(DWea),
        //.Data_out(Data_out),
        //.Addr_out(Addr_out),
        .Data_in(Data_in)
    );

    assign DWea = mem_DWea;
    assign Addr_out = mem_aluout;
    assign Data_out = mem_rfrdata2;
    assign mem_w = mem_DMWe;
    //wb



    MEM_WB U_MEMWB(
        .clk(clk),//input
        .rst(wb_rst),//input
        .stop(wb_stop),//input

        //.mem_pc(mem_pc),
        //.wb_pc(wb_pc),

        .mem_RFWe(mem_RFWe),//regfile write enable
        .wb_RFWe(wb_RFWe),

        //.mem_RFWsrc(mem_RFWsrc),
        //.wb_RFWsrc(wb_RFWsrc),

        //.mem_DMsign(mem_DMsign),
        //.wb_DMsign(wb_DMsign),

        //.mem_DMwidth(mem_DMwidth),
        //.wb_DMwidth(wb_DMwidth),

        .mem_rfwaddr(mem_rfwaddr),//regfile write address
        .wb_rfwaddr(wb_rfwaddr),

        .mem_rfwdata(mem_rfwdata),
        .wb_rfwdata(wb_rfwdata)

    );

    WB U_WB(
        .clk(clk),//input
        .reset(reset),//input

        .wb_RFWe(wb_RFWe),
        
        .wb_rfwaddr(wb_rfwaddr),//regfile write address
        //.wb_aluout(wb_aluout),
        //.wb_dmout(wb_dmout),
        //.wb_pc(wb_pc),
        .wb_rfwdata(wb_rfwdata),

        .RFrst(RFrst),
        .RFWe(RFWe),
        .rfwaddr(rfwaddr),
        .rfwdata(rfwdata)
    );


//hazards

    HAZARD_CTRL U_HAZARD(
        .reset(reset),
        .id_branch_flag(id_branch_flag),
        .id_branch_address(id_branch_address),
        .ex_branch_flag(ex_branch_flag),
        .ex_branch_address(ex_branch_address),
        .id_stall(id_stall),
        .branch_flag(branch_flag),
        .branch_address(branch_address),
        .if_stop(if_stop),
        .id_rst(id_rst),
        .id_stop(id_stop),
        .ex_rst(ex_rst),
        .ex_stop(ex_stop),
        .mem_rst(mem_rst),
        .mem_stop(mem_stop),
        .wb_rst(wb_rst),
        .wb_stop(wb_stop)
    );

endmodule