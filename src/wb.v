//////////////////////////
//
//文件名：wb.v
//模块名：WB
//
//创建日期：2022-7-4
//最后修改日期: 2022-7-4
//
//wb阶段
//产生写入regfile 的信号
//判断、选择执行模块产生的信号
//////////////////////////
`include "def.vh"
module WB(
    input num_in1,
    input rfwe_in1,
    input [`REG_ADDR_BUS] rfwaddr_in1,
    input num_in2,
    input rfwe_in2,
    input [`REG_ADDR_BUS]rfwaddr_in2,
    output reg rfwe_out1,
    output reg rfwe_out2
);

//使用1位num判断前提时两条指令一直是并行的

    always @ (*)
    begin
        if(rfwe_in1 & rfwe_in2 & (rfwaddr_in1 == rfwaddr_in2))
        begin
            rfwe_out1 <= num_in1;
            rfwe_out2 <= num_in2;
        end
        else
        begin
            rfwe_out1 <= rfwe_in1;
            rfwe_out2 <= rfwe_in2;
        end
    end

endmodule
