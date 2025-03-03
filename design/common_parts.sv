/*
 This file contains the common parts used in the processor design.
 The common parts include:
 Register file
 Adder
 Flip Flop with reset
 Flip flop with reset and enable
 Mux2
 Sign extension
 memory
 */

module register_file #(
    parameter  ADDR_WIDTH = 5,
    parameter  WORD_WIDTH = 32) (
    input logic clk, we3,
    input logic [ADDR_WIDTH - 1 : 0] ra1, ra2, wa3,
    input logic [WORD_WIDTH - 1 : 0] wd3,
    output logic [WORD_WIDTH - 1 : 0] rd1, rd2
);
    logic [WORD_WIDTH - 1 : 0] rf [(1 << ADDR_WIDTH) - 1 : 1];

    always_ff @( posedge clk ) 
        begin : rf_write_block
            if (we3) rf[wa3] <= wd3; 
        end
    
    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;

endmodule

module adder #(
    parameter WIDTH = 32
) (
    input logic [WIDTH - 1 : 0] a, b,
    output logic [WIDTH - 1 : 0] sum
);
    assign sum = a + b;
endmodule

module signext(input logic [24:0] a,
               output logic [31:0] y);

    assign y = {{7{a[24]}}, a};

endmodule

module flopr #(
    parameter WIDTH = 32
) (
    input logic clk, reset,
    input logic [WIDTH - 1 : 0] d,
    output logic [WIDTH - 1 : 0] q
);

    always_ff @ (posedge clk, negedge reset)
        if (~reset) q <= 0;
        else q <= d;

endmodule

module flopenr #(
    parameter WIDTH = 32
) (
    input logic clk, reset, enable,
    input logic [WIDTH - 1 : 0] d,
    output logic [WIDTH - 1 : 0] q
);

    always_ff @ (posedge clk, negedge reset)
        if (~reset) q <= 0;
        else if (enable) q <= d;

endmodule

module mux2 #(
    parameter WIDTH = 32
) (
    input logic sel,
    input logic [WIDTH - 1 : 0] a, b,
    output logic [WIDTH - 1 : 0] y
);

    assign y = sel ? b : a;

endmodule