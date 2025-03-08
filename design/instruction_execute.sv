/*
 This file designs the instruction execute unit for the pipelined processor
 */

module alu_fwd_data_select(
    input logic [31:0] RSE, ALUResultM, ResultW,
    input logic [1:0] ForwardE,
    output logic [31:0]alu_fwd_data
    );

    always_comb
        begin
            case (ForwardE)
                2'b00: alu_fwd_data = RSE;
                2'b01: alu_fwd_data = ResultW;
                2'b10: alu_fwd_data = ALUResultM;
                default: alu_fwd_data = 32'bxx;
            endcase
        end

endmodule

module instruction_execute(
    input logic clk, reset, 
    input logic [31:0] PCE, PCPlus4E, ImmExtE,
    input logic [31:0] RD1E, RD2E, ResultW,
    input logic [4:0] RdE,
    input logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
    input logic [1:0] ForwardAE, ForwardBE,
    input logic [1:0] ResultSrcE,
    input logic [2:0] ALUControlE,
    output logic PCSrcE, RegWriteM, MemWriteM,
    output logic [1:0] ResultSrcM,
    output logic [4:0] RdM,
    output logic [31:0] ALUResultM, WriteDataM, PCPlus4M, PCTargetE
);

    logic ZeroE, OFE;
    logic [31:0] ALUResultE, SrcBE, SrcAE_fwd, SrcBE_fwd;

    assign PCSrcE = (ZeroE & BranchE) | JumpE;

    alu_fwd_data_select srcae_fwd (.RSE(RD1E), .ALUResultM(ALUResultM), 
                                   .ResultW(ResultW), .ForwardE(ForwardAE), 
                                   .alu_fwd_data(SrcAE_fwd));

    alu_fwd_data_select srcbe_fwd (.RSE(RD2E), .ALUResultM(ALUResultM), 
                                   .ResultW(ResultW), .ForwardE(ForwardBE), 
                                   .alu_fwd_data(SrcBE_fwd));
    
    flopr #(1) RegWriteM_reg(.clk(clk), .reset(reset), .d(RegWriteE), .q(RegWriteM));
    flopr #(2) ResultSrcM_reg(.clk(clk), .reset(reset), .d(ResultSrcE), .q(ResultSrcM));
    flopr #(1) MemWriteM_reg(.clk(clk), .reset(reset), .d(MemWriteE), .q(MemWriteM));

    flopr #(32) ALUResultM_reg(.clk(clk), .reset(reset), .d(ALUResultE), .q(ALUResultM));
    flopr #(32) WriteDataM_reg(.clk(clk), .reset(reset), .d(RD2E), .q(WriteDataM));
    flopr #(5) RdM_reg(.clk(clk), .reset(reset), .d(RdE), .q(RdM));
    flopr #(32) PCPlus4M_reg(.clk(clk), .reset(reset), .d(PCPlus4E), .q(PCPlus4M));

    adder #(32) PCTargetE_adder(.a(PCE), .b(ImmExtE), .sum(PCTargetE));
    mux2 #(32) SrcBE_mux(.sel(ALUSrcE), .a(SrcBE_fwd), .b(ImmExtE), .y(SrcBE));

    risc_v_alu alu(.A(SrcAE_fwd), .B(SrcBE), .ALUControl(ALUControlE), .Y(ALUResultE), .Zero(ZeroE), .OF(OFE));



endmodule