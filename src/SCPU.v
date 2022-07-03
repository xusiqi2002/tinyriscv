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
    output [31:0] inst_addr_out,// TODO: 待修改
    input [63:0] inst_in,     //一次存取两条指令
   


//用于传给RAM
    output mem_w, // output: memory write signal
    output [`MEM_ADDR_BUS] Addr_out,   // ALU output
    input [`DATA_BUS] Data_in,     // data from data memory
    output [`DATA_BUS] Data_out,// data to data memory
    output [3:0] DWea,
    
    input wire INT//中断信号，暂不实现中断和异常
);



//取指：一次取多条
//内置PC,输出PC地址
    IF U_IF(

    );

//指令缓存
//代替IF,ID间的流水线寄存器
    INST_BUF U_INSTBUF(

    );


//解码模块1
    DECODE DECODE_1(

    );

//解码模块2
    DECODE DECODE_2(

    );

//对解码的输出进行选择，送入执行阶段
    LAUNCH_SELECT U_L(

    );


    RLREG_DE_EX PRDEEX1(

    );

    
    RLREG_DE_EX PRDEEX2(

    );
//执行模块1,
//支持运算和跳转
    FAB EXC1(




    );



//执行模块2
//支持运算和fangcun

    FAM EXC2(

    );


//流水线寄存器 执行到写回的流水线寄存器
//TODO: stop和rst信号的选择
    PLREG_WB PRWB1(
        .clk(clk),
        .rst(),
        .stop(),
        .num_in(),
        .num_out(),
        .rfwe_in(),
        .rfwe_out(),
        .rfwaddr_in(),
        .rfwaddr_out(),
        .rfwdata_in(),
        .rfwdata_out()
    );


    PLREG_WB PRWB2(
        .clk(),
        .rst(),
        .stop(),
        .num_in(),
        .num_out(),
        .rfwe_in(),
        .rfwe_out(),
        .rfwaddr_in(),
        .rfwaddr_out(),
        .rfwdata_in(),
        .rfwdata_out()
    );

//写回阶段
    WB U_WB(
        .num_in1(),
        .rfwe_in1(),
        .rfwaddr_in1(),
        .num_in2(),
        .rfwe_in2(),
        .rfwaddr_in2(),
        .rfwe_out1(),
        .rfwe_out2()
    );



//32个通用寄存器
    RF U_RF(
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
        end
        else if(stop)
        begin
            num_out <= num_out;
            pc_out <= pc_out;//pc
            npc_out <= npc_out;//next pc
            decode_out_decode_out_out;
            rfrdata1_out <= rfrdata1_out;
            rfrdata2_out <= rfrdata2_out;
        end
        else
        begin
            num_out <= num_in;
            pc_out <= pc_in;//pc
            npc_out <= npc_in;//next pc
            decode_out_decode_out_in;
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