//////////////////////////
//
//
//文件名：if.v
//模块名:IF
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-4
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
    
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,
    output [`INST_BUS] out2_inst,

    input isbranch_pre,//EX阶段的指令是否为跳转指令

    input branch_flag,//为1表示采用branch_addr作为下一个PC地址，预测错误
    input [`PC_BUS] branch_addr,//从ex阶段ALU返回
    output  reg [1:0] issue
);

    reg [`PC_BUS] PC; //始终为两条指令中执行的第一条指令
    reg [`PC_BUS] NPC,npc1,npc2;//下一次取值的指令PC
    wire [`PC_BUS] br_address1;
    wire [`PC_BUS] br_address2;


    initial PC = `PC_INITIAL;

    MINI_DECODE MDECODE1(.inst(out1_inst),.PC(out1_pc),
        .br_flag(br_flag1),.jump_flag(jump_flag1),.br_address(br_address1)
    );

    MINI_DECODE MDECODE2(.inst(out2_inst),.PC(out2_pc),
        .br_flag(br_flag2),.jump_flag(jump_flag2),.br_address(br_address2)
    );

    BRANCH_PREDICT U_BP(.clk(clk),.isbranch_pre(isbranch_pre),
        .branch_flag(branch_flag),.br_flag_pre(br_flag_pre)
    );

    always@*
    begin
        if(branch_flag) 
            NPC<=branch_addr;
        else begin
            if(!stop) begin
                if(PC[2]==0) begin
                    if((br_flag_pre&br_flag1)|jump_flag1)
                        NPC<=br_address1;                  
                    else if((br_flag_pre & br_flag2)|jump_flag2)
                        NPC<=br_address2;
                    else 
                        NPC<=PC+8;
                end
                else begin//第一条指令不执行
                    if((br_flag_pre & br_flag2)|jump_flag2)
                        NPC<=br_address2;
                    else 
                        NPC<=PC+4;
                end
            end
            else
                NPC<=PC;  
        end
    end

    //always@(posedge clk,posedge rst)
    always @ (posedge clk)
    begin
        if(rst) 
            //PC<=32'h0000_0000
            PC <= `PC_INITIAL;
        else 
            PC<=NPC;
    end

    always@(*)
    begin
        if(PC[2]==1)
            issue=2'b01;
        else begin
            if((br_flag_pre&br_flag1)|jump_flag1)
                issue=2'b10;
            else 
                issue=2'b11;
        end
    end

    //下一条取指指令的PC
    always@(*)
    begin
        if(PC[2]==1'b1)
            if((br_flag_pre & br_flag2)|jump_flag2)//只执行第二条指令且发生跳转
            begin
                npc1<= `NPC_INITIAL;
                npc2<=NPC;
            end
            else 
            begin
                npc1<= `NPC_INITIAL;
                npc2<=PC+4;
            end
        else
            if((br_flag_pre & br_flag1)|jump_flag1)//第一条指令发生跳转
            begin
                npc1<=NPC;
                npc2<= `NPC_INITIAL;
            end
            else if((br_flag_pre & br_flag2)|jump_flag2)
            begin
                npc1<=PC+4;
                npc2<=NPC;
            end
            else
            begin
                npc1<=PC+4;
                npc2<=PC+8; 
            end     
    end
    assign inst_addr_out=PC;//在总线中取{PC[31:3],3'b000}
    assign out1_pc=PC[2]?PC-4:PC;//PC[2]=1时，第一条指令不执行，PC为第二条指令的PC
    assign out2_pc=PC[2]?PC:PC+4;  
    assign out1_inst=inst_in[63:32];
    assign out2_inst=inst_in[31:0];
    assign out1_npc=npc1;
    assign out2_npc=npc2;
endmodule


//模块名：MINI_DECODE
//部分解码，产生立即数，用于分支预测
//完全由组合数构成
//只产生

module MINI_DECODE(
    input [`INST_BUS] inst,
    input [`PC_BUS] PC,
    output reg br_flag,
    output reg jump_flag,
    output reg [`PC_BUS] br_address
);
    //reg br_flag;
    //reg [`PC_BUS] br_address;
    always@(*)
    begin
        if(inst[6:0]==7'b1100011) begin//btype
            br_flag<=1'b1;
            jump_flag<=1'b0;
            br_address<=PC+{{{32-13}{inst[31]}},{inst[31],inst[7],inst[30:25],inst[11:8]}, 1'b0};
        end
        else if(inst[6:0]==7'b1101111) begin//jal
            br_flag<=1'b0;
            jump_flag<=1'b1;
            br_address<=PC+{{{32-21}{inst[31]}},{inst[31],inst[19:12],inst[20],inst[30:21]}, 1'b0};
        end
        else begin//not jump
            br_flag<=1'b0;
            jump_flag<=1'b0;
            br_address <= `PC_INITIAL;
        end
    end

endmodule


//模块名：BRANCH_PREDICT
//用于分支预测
module BRANCH_PREDICT(
    input clk,
    input branch_flag,//预测是否正确
    input isbranch_pre,
    //branch_flag, branch_pre_re显示之前的预测结果是否正确，用于分支预测
    output br_flag_pre//产生一个信号,用于预测跳转是否发生
);

    reg [1:0] br_pre;
    initial br_pre =2'b01;
    always@(posedge clk)
    begin
        if(isbranch_pre) begin
            if(branch_flag) begin
                if(br_pre==2'b00)
                    br_pre=2'b01;
                else if(br_pre==2'b01)
                    br_pre=2'b10;
                else if(br_pre==2'b10)
                    br_pre=2'b11;
                else 
                    br_pre=2'b11;
            end
            else begin
                if(br_pre==2'b00)
                    br_pre=2'b00;
                else if(br_pre==2'b01)
                    br_pre=2'b00;
                else if(br_pre==2'b10)
                    br_pre=2'b01;
                else 
                    br_pre=2'b10;
            end
        end
    end
    //assign br_flag_pre=br_pre[1];
    assign br_flag_pre = 1'b0;//TODO:此时为测试用
endmodule