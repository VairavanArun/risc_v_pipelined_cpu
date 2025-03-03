/*
 This file designs the instruction execute unit for the pipelined processor
 */

module instruction_execute(
    input logic [31:0] PCE, PCPlus4E, ImmExtE,
    input logic [31:0] RD1E, RD2E,
    input logic [4:0] RdE, 
    input logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
    input logic [1:0] ResultSrcE,
    input logic [2:0] ALUControlE,
    output logic PCSrcE, RegWriteM, MemWriteM,
    output logic [1:0] ResultSrcM,
    output logic [4:0] RdM,
    output logic [31:0] ALUResultM, WriteDataM, PCPlus4M
);

endmodule