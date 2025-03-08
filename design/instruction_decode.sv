/*
 This file designs the instruction decode unit for the pipelined processor
 */

module main_decoder(
    input logic [6:0] op,
    output logic Branch, Jump,
    output logic MemWrite, RegWrite,
    output logic ALUSrc,
    output logic [1:0] ResultSrc, ImmSrc, ALUOp
);

    parameter LW    = 7'b0000011;
    parameter SW    = 7'b0100011;
    parameter RTYPE = 7'b0110011;
    parameter BEQ   = 7'b1100011;
    parameter ADDI  = 7'b0010011;
    parameter JAL   = 7'b1101111;

    logic [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc,
            Branch, ALUOp, Jump} = controls;

    always_comb 
        begin : main_decoder_mux
            case (op)
                LW      : controls = 11'b10010010000;
                SW      : controls = 11'b00111000000;
                RTYPE   : controls = 11'b10000000100;
                BEQ     : controls = 11'b01000001010;
                ADDI    : controls = 11'b10010000100;
                JAL     : controls = 11'b11100100001;
                default : controls = 11'bx;
            endcase
        
        end

endmodule

module alu_decoder (
    input logic op5, funct75,
    input logic [2:0] funct3,
    input logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);

    always_comb
        begin : alu_decoder_mux
            case (ALUOp)
                2'b00: ALUControl = 3'b000;
                2'b01: ALUControl = 3'b001;
                2'b10: case(funct3)
                    3'b000: begin
                        if ({op5, funct75} == 2'b11) ALUControl = 3'b001;
                        else ALUControl = 3'b000;
                    end
                    3'b010: ALUControl = 3'b101;
                    3'b110: ALUControl = 3'b011;
                    3'b111: ALUControl = 3'b010;
                    default: ALUControl = 3'bx;
                endcase
                default: ALUControl = 3'bx;
            endcase
        end

endmodule

module control_unit(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7,
    output logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
    output logic [1:0] ResultSrcD, ImmSrcD,
    output logic [2:0] ALUControlD
);

    logic [1:0] ALUOp;

    main_decoder md(.op(op), .Branch(BranchD), .Jump(JumpD), 
                    .MemWrite(MemWriteD), .RegWrite(RegWriteD), 
                    .ALUSrc(ALUSrcD), .ResultSrc(ResultSrcD), .ImmSrc(ImmSrcD), 
                    .ALUOp(ALUOp));

    alu_decoder alud(.op5(op[5]), .funct75(funct7), .funct3(funct3), 
                     .ALUOp(ALUOp), .ALUControl(ALUControlD));
    
endmodule

module immext (
    input logic [24:0] imm,
    input logic [1:0] ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb
        case (ImmSrc)
            2'b00: ImmExt = {{20{imm[24]}}, imm[24:13]};
            2'b01: ImmExt = {{20{imm[24]}}, imm[24:18], imm[4:0]};
            2'b10: ImmExt = {{20{imm[24]}}, imm[0], imm[23:18], imm[4:1], 1'b0};
            2'b11: ImmExt = {{12{imm[24]}}, imm[12:5], imm[13], imm[23:14], 1'b0};
        endcase

endmodule

module instruction_decode (
    input logic clk, reset,
    input logic [31:0] instruction_decode,
    input logic RegWriteW, 
    input logic [4:0] RdW,
    input logic [31:0] ResultW, PCD, PCPlus4D,
    output logic [31:0] PCE, PCPlus4E, ImmExtE,
    output logic [31:0] RD1E, RD2E,
    output logic [4:0] Rs1E, Rs2E, RdE, 
    output logic [4:0] Rs1D, Rs2D,
    output logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
    output logic [1:0] ResultSrcE,
    output logic [2:0] ALUControlE
);

    logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
    logic [1:0] ResultSrcD, ImmSrcD;
    logic [2:0] ALUControlD;
    logic [4:0] RdD;
    logic [31:0] ImmExtD, RD1D, RD2D;

    assign RdD = instruction_decode[11:7];
    assign Rs1D = instruction_decode[19:15];
    assign Rs2D = instruction_decode[24:20];

    flopr PCE_reg(.clk(clk), .reset(reset), .d(PCD), .q(PCE));
    flopr PCPlus4E_reg(.clk(clk), .reset(reset), .d(PCPlus4D), .q(PCPlus4E));
    flopr ImmExtE_reg(.clk(clk), .reset(reset), .d(ImmExtD), .q(ImmExtE));
    flopr RD1E_reg(.clk(clk), .reset(reset), .d(RD1D), .q(RD1E));
    flopr RD2E_reg(.clk(clk), .reset(reset), .d(RD2D), .q(RD2E));
    flopr #(5) RdE_reg(.clk(clk), .reset(reset), .d(RdD), .q(RdE));
    flopr #(5) Rs1E_reg(.clk(clk), .reset(reset), .d(Rs1D), .q(Rs1E));
    flopr #(5) Rs2E_reg(.clk(clk), .reset(reset), .d(Rs2D), .q(Rs2E));
    flopr #(1) RegWriteE_reg(.clk(clk), .reset(reset), .d(RegWriteD), .q(RegWriteE));
    flopr #(1) MemWriteE_reg(.clk(clk), .reset(reset), .d(MemWriteD), .q(MemWriteE));
    flopr #(1) JumpE_reg(.clk(clk), .reset(reset), .d(JumpD), .q(JumpE));
    flopr #(1) BranchE_reg(.clk(clk), .reset(reset), .d(BranchD), .q(BranchE));
    flopr #(1) ALUSrcE_reg(.clk(clk), .reset(reset), .d(ALUSrcD), .q(ALUSrcE));

    register_file rf(.clk(clk), .we3(RegWriteW), .ra1(instruction_decode[19:15]), 
                     .ra2(instruction_decode[24:20]), .wa3(RdW), .wd3(ResultW), 
                     .rd1(RD1D), .rd2(RD2D));

    control_unit cu(.op(instruction_decode[6:0]), .funct3(instruction_decode[14:12]), .funct7(instruction_decode[30]), 
                    .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .JumpD(JumpD), 
                    .BranchD(BranchD), .ALUSrcD(ALUSrcD), .ResultSrcD(ResultSrcD),
                    .ImmSrcD(ImmSrcD), .ALUControlD(ALUControlD));

    immext extend(.imm(instruction_decode[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

endmodule

