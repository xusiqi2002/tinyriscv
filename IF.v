//////////////////////////
//
//
//文件名：IF.v
//模块名:IF
//
//创建日期：2022-7-14
//最后修改日期: 2022-7-14
//
//取指模块
//
//////////////////////////
`include "def.vh"
module IF(
    input clk,
    input rst,
    input stop,
    output [`INST_ADDR_BUS] inst_addr_out,//取指的地址，与实际地址不同 
    input [63:0] inst_in,

    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output [`INST_BUS] out1_inst,
    output reg sendout_flag1,
    
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,
    output [`INST_BUS] out2_inst,
    output reg sendout_flag2,

    input isbranch_pre,//EX阶段的指令是否为跳转指令

    input branch_flag,//为1表示采用branch_addr作为下一个PC地址，预测错误
    input [`PC_BUS] branch_address//从ex阶段ALU返回
    //output  reg [1:0] issue
);

    reg [`PC_BUS] PC; //始终为两条指令中执行的第一条指令
    reg [`PC_BUS] NPC;
    //reg [`PC_BUS] NPC,npc1,npc2;//下一次取值的指令PC
    //wire [`PC_BUS] br_address1;
    //wire [`PC_BUS] br_address2;


    initial PC = `PC_INITIAL;




    always @ (posedge clk)
    begin
        if(rst) 
            //PC<=32'h0000_0000
            PC <= `PC_INITIAL;
        else 
            PC<=NPC;
    end

    always @ (*)
        if (branch_flag)
            NPC <= branch_address;
        else if(stop)
            NPC <= PC;
        else
            NPC <= {PC[31:3] + 1,3'b000};

  
    always @ (*)
    begin
        sendout_flag1 <= ~PC[2];
        sendout_flag2 <= `VALID;
    end


    assign inst_addr_out=PC;//在总线中取{PC[31:3],3'b000}
    assign out1_pc = {PC[31:3],3'b000};
    assign out2_pc = {PC[31:3],3'b100};
    assign out1_inst = inst_in[63:32];
    assign out2_inst = inst_in[31:0];
    assign out1_npc = {PC[31:3],3'b100};
    assign out2_npc = {PC[31:3] + 1,3'b000};

endmodule
