`include "ctrl_encode_def.vh"

module ALU(
   input signed [31:0] A,
   input signed [31:0] B,
   input [4:0] ALUop,
	input [31:0] PC,
   output reg signed [31:0] C,
   output Zero
);
   //integer    i;
       
    always @(*)
    begin
        case ( ALUop )
            `ALUOP_nop:   C <= A;
            `ALUOP_lui:   C <= B;
            `ALUOP_auipc: C <= PC+B;
            `ALUOP_add:   C <= A+B;
            `ALUOP_sub:   C <= A-B;
            `ALUOP_beq:   C <= A-B;
            `ALUOP_bne:   C <= {31'b0,(A==B)};
            `ALUOP_blt:   C <= {31'b0,(A>=B)};
            `ALUOP_bge:   C <= {31'b0,(A<B)};
            `ALUOP_bltu:  C <= {31'b0,($unsigned(A)>=$unsigned(B))};
            `ALUOP_bgeu:  C <= {31'b0,($unsigned(A)<$unsigned(B))};
            `ALUOP_slt:   C <= {31'b0,(A<B)};
            `ALUOP_sltu:  C <= {31'b0,($unsigned(A)<$unsigned(B))};
            `ALUOP_xor:   C <= A^B;
            `ALUOP_or:    C <= A|B;
            `ALUOP_and:   C <= A&B;
            `ALUOP_sll:   C <= A<<B;
            `ALUOP_srl:   C <= A>>B;
            `ALUOP_sra:   C <= A>>>B;
            default:      C <= 32'b0;
        endcase
    end //end always
   
   assign Zero = (C == 32'b0);

endmodule
    
