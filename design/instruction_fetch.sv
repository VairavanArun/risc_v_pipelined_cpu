/*
 This file designs the instruction fetch unit for the pipelined processor
 */

module imem #(
    parameter ADDR_WIDTH = 6,
    parameter WORD_WIDTH = 32
) (
    input logic [ADDR_WIDTH - 1 : 0] a,
    output logic [WORD_WIDTH - 1 : 0] instr
);

    logic [WORD_WIDTH - 1 : 0] RAM [(1 << ADDR_WIDTH) - 1 : 0];

    assign instr = RAM[a[ADDR_WIDTH - 1 : 2]];

endmodule

module instruction_fetch #(
    parameter WORD_WIDTH = 32
) (
    input logic PCSrcE, reset, clk, StallF, StallD, FlushD,
    input logic [31:0] PCTargetE,
    output logic [WORD_WIDTH - 1:0] instrD,
    output logic [WORD_WIDTH -1 : 0] PCPlus4D, PCD
);

    logic [31:0] pc_nextF, pc_currentF, next_instr, PCPlus4F;

    flopenr pcregf(.clk(clk), .reset(reset), .enable(StallF), .d(pc_nextF), .q(pc_currentF));
    adder pc_plus_4_adder(.a(pc_currentF), .b(32'd4), .sum(PCPlus4F));
    mux2 pc_select_mux(.sel(PCSrcE), .a(PCPlus4F), .b(PCTargetE), .y(pc_nextF));
    imem imem(.a(pc_currentF[7:2]), .instr(next_instr));
    flopenr instregf(.clk(clk), .reset(FlushD), .enable(StallD), .d(next_instr), .q(instrD));
    flopenr PCPlus4D_reg(.clk(clk), .reset(FlushD), .enable(StallD), .d(PCPlus4F), .q(PCPlus4D));
    flopenr PCD_reg(.clk(clk), .reset(FlushD), .enable(StallD), .d(pc_currentF), .q(PCD));

endmodule