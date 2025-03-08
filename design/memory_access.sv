/*
 This file designs the memory access unit for the pipelined processor
 */

 module dmem #(
    parameter WORD_WIDTH = 32
) (
    input logic clk, we,
    input logic [WORD_WIDTH - 1 : 0] a, write_data,
    output logic [WORD_WIDTH - 1 : 0] read_data
);

    logic [WORD_WIDTH - 1 : 0] RAM [127 : 0];

    assign read_data = RAM[a[WORD_WIDTH - 1 : 2]];

    always @ (posedge clk)
        begin
            if (we) RAM[a[WORD_WIDTH - 1 : 2]] <= write_data;
        end

endmodule

 module memory_access(
    input logic clk, reset, 
    input logic RegWriteM, MemWriteM,
    input logic [1:0] ResultSrcM,
    input logic [31:0] ALUResultM, WriteDataM, PCPlus4M,
    input logic [4:0] RdM,
    output logic RegWriteW, 
    output logic [1:0] ResultSrcW,
    output logic [31:0] ReadDataW, ALUResultW, PCPlus4W,
    output logic [4:0] RdW
 );
    
    logic [31:0] ReadDataM;
 
    flopr #(1) RegWriteW_reg(.clk(clk), .reset(reset), .d(RegWriteM), .q(RegWriteW));
    flopr #(2) ResultSrcW_reg(.clk(clk), .reset(reset), .d(ResultSrcM), .q(ResultSrcW));
    flopr #(32) ALUResultW_reg(.clk(clk), .reset(reset), .d(ALUResultM), .q(ALUResultW));
    flopr #(32) ReadDataW_reg(.clk(clk), .reset(reset), .d(ReadDataM), .q(ReadDataW));
    flopr #(5) RdW_reg(.clk(clk), .reset(reset), .d(RdM), .q(RdW));
    flopr #(32) PCPlus4W_reg(.clk(clk), .reset(reset), .d(PCPlus4M), .q(PCPlus4W));

    dmem #(32) data_memory(.clk(clk), .we(MemWriteM), .a(ALUResultM), .write_data(WriteDataM), .read_data(ReadDataM));
    
 endmodule