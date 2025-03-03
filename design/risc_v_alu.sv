/*
 * This file contains the ALU implementation for MIPS architecture
 * ALU can perform ADD, SUB, AND, OR, SLT
 */

module and_32bit(input logic [31:0] A,B,
                 output logic [31:0] Y);
    assign Y = A & B;
endmodule

module or_32bit(input logic [31:0] A,B,
                 output logic [31:0] Y);
    assign Y = A | B;
endmodule

module mux5to1(input logic [31:0] D0, D1, D2, D3, D4,
               input logic [2:0] S,
               output logic [31:0] Y);

    always_comb
        begin : ALU_output_block
            case (S)
                3'b000: Y = D0; 
                3'b001: Y = D1;
                3'b010: Y = D2;
                3'b011: Y = D3;
                3'b101: Y = D4;
                default: Y = 32'bx;
            endcase
        end

endmodule

module overflow(
	input logic A,B,
	input logic [2:0] F,
	input logic S,
	output logic OF,SLT);
	logic X1,Xn1,check,OF_int;
	logic [31:0] D2;
	//assign nB = F[2] ? (~B):B;
	//ppa_32bit adder1(A, B, F[2], D2, Cout);
	//assign S = D2;
	assign  check =  ~F[1];
	assign Xn1 = ~(F[0] ^ A ^ B);
	assign X1 = S ^ A;
	assign OF_int =  X1 & Xn1;
	assign OF = OF_int & check;
	assign SLT= (S ^ OF_int );
endmodule

module risc_v_alu(input logic [31:0]  A, B,
                  input logic [2:0]   ALUControl,
                  output logic [31:0] Y,
                  output logic        Zero,OF);

    logic [31:0] D0, D1, D2, D3, D4;
    logic [31:0] negated_B, sum;
    logic Cout;
    logic SLT;

    assign negated_B = ALUControl[0] ? (~B):B;
    assign D0 = sum;
    assign D1 = sum;
    assign D4 = {31'b0, SLT}; 
    assign Zero = (Y == 32'b0) ? 1'b1 : 1'b0;

    //instantiate and module
    and_32bit and_circ(A, B, D2);
    //instantiate or module
    or_32bit or_circ(A, B, D3);
    //instantiate adder
    ppa_32bit adder(A, negated_B, ALUControl[0], sum, Cout);

    //get the output of the ALU
    mux5to1 multiplexer(D0, D1, D2, D3, D4, ALUControl, Y);
    overflow of(A[31], B[31], ALUControl, D2[31], OF, SLT);
    
    
endmodule 
