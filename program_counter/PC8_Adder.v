`timescale 1ns / 1ps

module PC_8Adder (
    input  wire [31:0] PC_plus4,      
    output wire [31:0] PC_plus8    
);

    assign PC_plus8 = PC_plus4 + 32'd4;  

endmodule