/*
 This file implements the hazard detection unit for RISC-V pipelined CPU
 */

module hazard_detection_check(
    input logic [4:0] RSE, RSM, RSW, 
    input logic RegWriteM, RegWriteW,
    output logic [1:0] ForwardE
    );

    always_comb begin : hazard_detection_block
        //check if execute and memory stage have the same registers
        if (((RSE == RSM) && RegWriteM) && (RSE != 0)) ForwardE = 2'b10;
        else if (((RSE == RSW) && RegWriteW) && (RSE != 0)) ForwardE = 2'b01;
        else ForwardE = 2'b00;
    end

endmodule

module load_stall_detection(
    input logic ResultSrcE0,
    input logic [4:0] RS1D, RS2D, RdE,
    output logic StallF, StallD, FlushE
);

    logic lw_stall;

    always_comb
        begin
            if ((ResultSrcE0 == 1'b1) && ((RS1D == RdE) || (RS2D == RdE))) begin
                lw_stall = 1'b1;
            end
            else lw_stall = 1'b0;
        end
    
    assign StallF = lw_stall;
    assign StallD = lw_stall;
    assign FlushE = lw_stall;

endmodule

module hazard_detection(
    input logic [4:0] RS1E, RS2E,
    input logic [4:0] RdM, RdW, 
    input logic [4:0] RS1D, RS2D,
    input logic [4:0] RdE,
    input logic RegWriteM, RegWriteW, ResultSrcE0,
    output logic [1:0] ForwardAE, ForwardBE,
    output logic StallF, StallD, FlushE
);

    hazard_detection_check rs1_check (.RSE(RS1E), .RSM(RdM), .RSW(RdW), .RegWriteM(RegWriteM),
                                      .RegWriteW(RegWriteW), .ForwardE(ForwardAE));

    hazard_detection_check rs2_check (.RSE(RS2E), .RSM(RdM), .RSW(RdW), .RegWriteM(RegWriteM),
                                      .RegWriteW(RegWriteW), .ForwardE(ForwardBE));

    load_stall_detection lw_stall_check (.ResultSrcE0(ResultSrcE0), .RS1D(RS1D), .RS2D(RS2D), .RdE(RdE),
                                         .StallD(StallD), .StallF(StallF), .FlushE(FlushE));


endmodule