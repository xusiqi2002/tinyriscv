////////////////////////////////////////////////////
//
//Author: xsq
//Data: 2022-6-25
//
//Project Name: pipeline CPU
//Module Name: pc.v
//
//PC寄存器
//
//
///////////////////////////////////////////////////

`include "ctrl_encode_def.vh"

module PC(
  input clk,
  input rst,
  input stop,
  input branch_flag,
  input [31:0] branch_address,
  output reg [31:0] PC,
  output reg [31:0] NPC
);

  //reg [31:0] NPC;
  always @ (*)
      NPC = PC + 4;

  always @(posedge clk)
    if (rst)
      PC <= `PC_INITIAL;
    else
      if(stop)
        PC <= PC;
      else
        if(branch_flag)
          PC <= branch_address;
        else
          PC <= NPC;
      
endmodule

