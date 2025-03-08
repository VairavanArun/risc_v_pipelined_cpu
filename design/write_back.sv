/*
 This file designs the write back unit for the pipelined processor
 */

module write_back (
    input logic [1:0] ResultSrcW,
    input logic [31:0] ALUResultW, ReadDataW, PCPlus4W,
    output logic [31:0] ResultW
);

    always_comb begin : result_selection_block

        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = ReadDataW;
            2'b10: ResultW = PCPlus4W;
            default: ResultW = 32'bx; 
        endcase

    end

endmodule