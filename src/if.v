//////////////////////////
//
//
//文件名：if.v
//模块名:IF
//
//创建日期：2022-7-22
//最后修改日期: 2022-7-22
//
//取值模块
//
//////////////////////////

module IF(
    output [31:0] inst_addr_out,//取值的地址，与实际地址不同
    input branch_pre_r,//跳转的预测结果，用于分支预测，位数未定

    input branch_flag,
    input [31:0] branch_addr
);


    reg [31:0] PC;

    MINI_DECODE MDECODE1(

    );

    MINI_DECODE MDECODE2(

    );






endmodule

//模块名：MINI_DECODE
//部分解码，产生立即数，用于分支预测

module MINI_DECODE(

);


endmodule