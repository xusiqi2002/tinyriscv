////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: hazard_ctrl.v
//
//控制冒险
//数据冒险的阻塞信号
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"
module HAZARD_CTRL(

    input reset,

    input id_branch_flag,
    input [31:0] id_branch_address,
    
    input ex_branch_flag,
    input [31:0] ex_branch_address,

    input id_stall,

    output reg branch_flag,
    output reg [31:0] branch_address,

    output reg if_stop,
    output reg id_rst,
    output reg id_stop,
    output reg ex_rst,
    output reg ex_stop,
    output reg mem_rst,
    output reg mem_stop,
    output reg wb_rst,
    output reg wb_stop

);

    always @ (*)
        if(reset)
        begin
            branch_flag <= `DISABLE;
            branch_address <= `PC_INITIAL;
            id_rst <= `ENABLE;
            ex_rst <= `ENABLE;
            mem_rst <= `ENABLE;
            wb_rst <= `ENABLE;
            if_stop <= `DISABLE;
            id_stop <= `DISABLE;
            ex_stop <= `DISABLE;
            mem_stop <= `DISABLE;
            wb_stop <= `DISABLE;
        end
        else
        begin
            if(ex_branch_flag)
            begin
                branch_flag <= ex_branch_flag;
                branch_address <= ex_branch_address;
                id_rst <= `ENABLE;
                ex_rst <= `ENABLE;
                if_stop <= `DISABLE;
                id_stop <= `DISABLE;
                ex_stop <= `DISABLE;
            end
            else if(id_branch_flag)
            begin
                if(id_stall)
                begin
                    branch_flag <= id_branch_flag;
                    branch_address <= id_branch_address;
                    if_stop <= `ENABLE;
                    id_rst <= `DISABLE;
                    id_stop <= `ENABLE;
                    ex_rst <= `ENABLE;
                    ex_stop <= `DISABLE;
                end
                else
                begin
                    branch_flag <= id_branch_flag;
                    branch_address <= id_branch_address;
                    if_stop <= `DISABLE;
                    id_rst <= `ENABLE;
                    id_stop <= `DISABLE;
                    ex_rst <= `DISABLE;
                    ex_stop <= `DISABLE;
                end
            end
            else
            begin
                branch_flag <= `DISABLE;
                branch_address <= `PC_INITIAL;
                if(id_stall)
                begin
                    if_stop <= `ENABLE;
                    id_stop <= `ENABLE;
                    id_rst <= `DISABLE;
                    ex_stop <= `DISABLE;
                    ex_rst <= `ENABLE;
                end
                else
                begin
                    if_stop <= `DISABLE;
                    id_stop <= `DISABLE;
                    id_rst <= `DISABLE;
                    ex_stop <= `DISABLE;
                    ex_rst <= `DISABLE;
                end
            end
            mem_rst <= `DISABLE;
            wb_rst <= `DISABLE;
            mem_stop <= `DISABLE;
            wb_stop <= `DISABLE;
        end

endmodule