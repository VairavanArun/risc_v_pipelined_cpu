/*
 This file implements the top module for RISC-V pipelined CPU
 */

module risc_v_cpu(
     input logic reset, clk,
     output logic [31:0] ResultW, 
     output logic RegWriteW,
     output logic [4:0] RdW
);

    /* Inputs for Fetch stage */
    logic PCSrcE;
    logic [31:0] PCTargetE;
    logic StallF, StallD, FlushD;

    /* Inputs to Decode stage */
    logic [31:0] InstrD, PCD, PCPlus4D;
    logic FlushE;
    logic [4:0] Rs1D, Rs2D;

    /* Inputs to Execute stage */
    logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
    logic [1:0] ResultSrcE;
    logic [2:0] ALUControlE;
    logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
    logic [4:0] RdE, Rs1E, Rs2E;
    logic [1:0] ForwardAE, ForwardBE;

    /* Inputs to Memory access stage */
    logic RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;
    logic [31:0] ALUResultM, WriteDataM, PCPlus4M;
    logic [4:0] RdM;

    /* Inputs to Write back stage */
    logic [1:0] ResultSrcW;
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;
    


    instruction_fetch fetch_unit (.PCSrcE(PCSrcE), .reset(reset), .clk(clk), .PCTargetE(PCTargetE),
                                  .StallF(StallF), .StallD(StallD), .FlushD(FlushD),
                                  .instrD(InstrD), .PCPlus4D(PCPlus4D), .PCD(PCD));
    
    instruction_decode decode_unit(.clk(clk), .reset(FlushE), .instruction_decode(InstrD),
                                   .RegWriteW(RegWriteW), .RdW(RdW), .ResultW(ResultW), 
                                   .PCD(PCD), .PCPlus4D(PCPlus4D), .PCE(PCE), .PCPlus4E(PCPlus4E), 
                                   .ImmExtE(ImmExtE), .RD1E(RD1E), .RD2E(RD2E), 
                                   .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), 
                                   .Rs1D(Rs1D), .Rs2D(Rs2D),
                                   .RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .JumpE(JumpE), 
                                   .BranchE(BranchE), .ALUSrcE(ALUSrcE), .ResultSrcE(ResultSrcE), 
                                   .ALUControlE(ALUControlE));
    
    instruction_execute execute_unit(.clk(clk), .reset(reset), .PCE(PCE), 
                                     .PCPlus4E(PCPlus4E), .ImmExtE(ImmExtE), .RD1E(RD1E), .RD2E(RD2E),
                                     .RdE(RdE), .RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .ResultW(ResultW),
                                     .JumpE(JumpE), .BranchE(BranchE), .ALUSrcE(ALUSrcE), .ResultSrcE(ResultSrcE),
                                     .ALUControlE(ALUControlE), .PCSrcE(PCSrcE), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
                                     .RegWriteM(RegWriteM), .MemWriteM(MemWriteM),
                                     .ResultSrcM(ResultSrcM), .RdM(RdM),
                                     .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M), .PCTargetE(PCTargetE));

    memory_access memory_access_unit(.clk(clk), .reset(reset), .RegWriteM(RegWriteM), .MemWriteM(MemWriteM),
                                     .ResultSrcM(ResultSrcM), .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M),
                                     .RdM(RdM), .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW), .ReadDataW(ReadDataW), 
                                     .ALUResultW(ALUResultW), .PCPlus4W(PCPlus4W), .RdW(RdW));

    write_back write_back_unit(.ResultSrcW(ResultSrcW), .ALUResultW(ALUResultW), .ReadDataW(ReadDataW), .PCPlus4W(PCPlus4W), .ResultW(ResultW));

    hazard_detection hazard_unit (.RS1E(Rs1E), .RS2E(Rs2E), .RdM(RdM), .RdW(RdW),
                                  .RS1D(Rs1D), .RS2D(Rs2D),
                                  .RdE(RdE), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .ResultSrcE0(ResultSrcE[0]),
                                  .PCSrcE(PCSrcE),
                                  .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
                                  .StallF(StallF), .StallD(StallD), .FlushE(FlushE), .FlushD(FlushD));

endmodule