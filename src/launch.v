//////////////////////////
//
//文件名：launch.v
//模块名：LAUNCH
//
//创建日期：2022-7-2
//最后修改日期: 2022-7-4
//
//用于判断是否将解码后的两个指令送入执行模块，以及送入哪个执行模块
//////////////////////////
`include "def.vh"
module LAUNCH_SELECT(

    input [`PC_BUS] in1_pc,
    input [`PC_BUS] in1_npc,
    input [`DECODEOUT_BUS] in1_decodeout,
    input receive_flag1,
    
    input [`PC_BUS] in2_pc,
    input [`PC_BUS] in2_npc,
    input [`DECODEOUT_BUS] in2_decodeout,
    input receive_flag2,

    input [`DATA_BUS] rfrd1,
    input [`DATA_BUS] rfrd2,
    input [`DATA_BUS] rfrd3,
    input [`DATA_BUS] rfrd4,

    //用于数据冒险
    //1,2,3,4,编号越小对应指令的次序越后
    input [`RFW_BUS] rfw1,
    input [`RFW_BUS] rfw2,
    input [`RFW_BUS] rfw3,
    input [`RFW_BUS] rfw4,


//传给第一个执行模块的输出
//算数 or 跳转
    output out1_num,
    output [`PC_BUS] out1_pc,
    output [`PC_BUS] out1_npc,
    output [`DECODEOUT_BUS] out1_decodeout,
    output [`DATA_BUS] out1_rfrdata1,
    output [`DATA_BUS] out1_rfrdata2,

    
    output out2_num,
    output [`PC_BUS] out2_pc,
    output [`PC_BUS] out2_npc,
    output [`DECODEOUT_BUS] out2_decodeout,
    output [`DATA_BUS] out2_rfrdata1,
    output [`DATA_BUS] out2_rfrdata2,

    output reg [3:0]launch_flag //用于展示是否送入执行模块以及送入那个执行模块，待改变

);

    wire [1:0] inst1_type = in1_decodeout[`DC_INSTTYPE];
    wire [`REG_ADDR_BUS] inst1_rs = in1_decodeout[`DC_RS];
    wire [`REG_ADDR_BUS] inst1_rt = in1_decodeout[`DC_RT];
    wire inst1_rs_v = in1_decodeout[`DC_RSV];
    wire inst1_rt_v = in1_decodeout[`DC_RTV];

    wire [1:0] inst2_type = in2_decodeout[`DC_INSTTYPE];
    wire [`REG_ADDR_BUS] inst2_rs = in2_decodeout[`DC_RS];
    wire [`REG_ADDR_BUS] inst2_rt = in2_decodeout[`DC_RT];
    wire inst2_rs_v = in2_decodeout[`DC_RSV];
    wire inst2_rt_v = in2_decodeout[`DC_RTV];

    wire inst1_c;
    reg inst1_rs_c;
    reg inst1_rt_c;
    wire inst2_c;
    reg inst2_rs_c;
    reg inst2_rt_c;

    reg [`DATA_BUS] inst1_rfrdata1;
    reg [`DATA_BUS] inst1_rfrdata2;
    reg [`DATA_BUS] inst2_rfrdata1;
    reg [`DATA_BUS] inst2_rfrdata2;


    //先判断寄存器读的数据
    always @ (*)
    begin
        //inst1_rs
        if(inst1_rs_v)
        begin
            if(rfw1[`RFWE] && (inst1_rs == rfw1[`RFWA]))
            begin
                inst1_rs_c <= rfw1[`RFWC];
                inst1_rfrdata1 = rfw1[`RFWD];
            end
            else if(rfw2[`RFWE] && (inst1_rs == rfw2[`RFWA]))
            begin
                inst1_rs_c <= rfw2[`RFWC];
                inst1_rfrdata1 = rfw2[`RFWD];
            end
            else if(rfw3[`RFWE] && (inst1_rs == rfw3[`RFWA]))
            begin
                inst1_rs_c <= rfw3[`RFWC];
                inst1_rfrdata1 = rfw3[`RFWD];
            end
            else if(rfw4[`RFWE] && (inst1_rs == rfw4[`RFWA]))
            begin
                inst1_rs_c <= rfw4[`RFWC];
                inst1_rfrdata1 = rfw4[`RFWD];
            end
            else 
            begin
                inst1_rs_c <= 1'b1;
                inst1_rfrdata1 <= rfrd1;
            end
        end
        else
        begin
            inst1_rs_c = 1'b1;
            inst1_rfrdata1 <= `DATA_INITIAL;
        end

        //inst1_rt
        if(inst1_rt_v)
        begin
            if(rfw1[`RFWE] && (inst1_rt == rfw1[`RFWA]))
            begin
                inst1_rt_c <= rfw1[`RFWC];
                inst1_rfrdata2 = rfw1[`RFWD];
            end
            else if(rfw2[`RFWE] && (inst1_rt == rfw2[`RFWA]))
            begin
                inst1_rt_c <= rfw2[`RFWC];
                inst1_rfrdata2 = rfw2[`RFWD];
            end
            else if(rfw3[`RFWE] && (inst1_rt == rfw3[`RFWA]))
            begin
                inst1_rt_c <= rfw3[`RFWC];
                inst1_rfrdata2 = rfw3[`RFWD];
            end
            else if(rfw4[`RFWE] && (inst1_rt == rfw4[`RFWA]))
            begin
                inst1_rt_c <= rfw4[`RFWC];
                inst1_rfrdata2 = rfw4[`RFWD];
            end
            else 
            begin
                inst1_rt_c <= 1'b1;
                inst1_rfrdata2 <= rfrd2;
            end
        end
        else
        begin
            inst1_rt_c = 1'b1;
            inst1_rfrdata2 <= `DATA_INITIAL;
        end
        
        //inst2_rs
        if(inst2_rs_v)
        begin
            if(rfw1[`RFWE] && (inst2_rs == rfw1[`RFWA]))
            begin
                inst2_rs_c <= rfw1[`RFWC];
                inst2_rfrdata1 = rfw1[`RFWD];
            end
            else if(rfw2[`RFWE] && (inst2_rs == rfw2[`RFWA]))
            begin
                inst2_rs_c <= rfw2[`RFWC];
                inst2_rfrdata1 = rfw2[`RFWD];
            end
            else if(rfw3[`RFWE] && (inst2_rs == rfw3[`RFWA]))
            begin
                inst2_rs_c <= rfw3[`RFWC];
                inst2_rfrdata1 = rfw3[`RFWD];
            end
            else if(rfw4[`RFWE] && (inst2_rs == rfw4[`RFWA]))
            begin
                inst2_rs_c <= rfw4[`RFWC];
                inst2_rfrdata1 = rfw4[`RFWD];
            end
            else 
            begin
                inst2_rs_c <= 1'b1;
                inst2_rfrdata1 <= rfrd3;
            end
        end
        else
        begin
            inst2_rs_c = 1'b1;
            inst2_rfrdata1 <= `DATA_INITIAL;
        end

        //inst2_rt
        if(inst2_rt_v)
        begin
            if(rfw1[`RFWE] && (inst2_rt == rfw1[`RFWA]))
            begin
                inst2_rt_c <= rfw1[`RFWC];
                inst2_rfrdata2 = rfw1[`RFWD];
            end
            else if(rfw2[`RFWE] && (inst2_rt == rfw2[`RFWA]))
            begin
                inst2_rt_c <= rfw2[`RFWC];
                inst2_rfrdata2 = rfw2[`RFWD];
            end
            else if(rfw3[`RFWE] && (inst2_rt == rfw3[`RFWA]))
            begin
                inst2_rt_c <= rfw3[`RFWC];
                inst2_rfrdata2 = rfw3[`RFWD];
            end
            else if(rfw4[`RFWE] && (inst2_rt == rfw4[`RFWA]))
            begin
                inst2_rt_c <= rfw4[`RFWC];
                inst2_rfrdata2 = rfw4[`RFWD];
            end
            else 
            begin
                inst2_rt_c <= 1'b1;
                inst2_rfrdata2 <= rfrd4;
            end
        end
        else
        begin
            inst2_rt_c = 1'b1;
            inst2_rfrdata2 <= `DATA_INITIAL;
        end
    end
    

    assign inst1_c = inst1_rs_c && inst1_rt_c && receive_flag1;
    assign inst2_c = inst1_c && inst2_rs_c && inst2_rt_c && receive_flag2;
    

////////////////////////////////////
//
// launch_flag  | exc1 | exc2
//      inst1   | [3]  |  [2]
//      inst2   | [1]  |  [0]
//
////////////////////////////////////


    //再决定顺序
    //产生luanch_flag
    always @ (*)
    case ({inst1_c,inst2_c})
        2'b11:
        begin

        end
        2'b10:
        begin
            if(inst1_type == `INSTTYPE_AG)
                launch_flag <= 4'b0100;
            else
                launch_flag <= 4'b1000;
        end
        2'b01:
        begin
            if(inst2_type == `INSTTYPE_AG)
                launch_flag <= 4'b0001;
            else
                launch_flag <= 4'b0010;
        end
        2'b00: 
        begin
            launch_flag <= 4'b0000;
        end

    endcase



    assign {out1_num,out1_pc,out1_npc,out1_decodeout,out1_rfrdata1,out1_rfrdata2}
        = ({196{launch_flag[3]}} & {1'b0,in1_pc,in1_npc,in1_decodeout,inst1_rfrdata1,inst1_rfrdata2})
        & ({196{launch_flag[1]}} & {1'b1,in2_pc,in2_npc,in2_decodeout,inst2_rfrdata1,inst2_rfrdata2});

    assign {out2_num,out2_pc,out2_npc,out2_decodeout,out2_rfrdata1,out2_rfrdata2}
        = ({196{launch_flag[2]}} & {1'b0,in1_pc,in1_npc,in1_decodeout,inst1_rfrdata1,inst1_rfrdata2})
        & ({196{launch_flag[0]}} & {1'b1,in2_pc,in2_npc,in2_decodeout,inst2_rfrdata1,inst2_rfrdata2});

endmodule