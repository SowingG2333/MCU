`timescale 1ns / 1ps

module PC_4Adder (
    input  wire [31:0] PC,      
    output wire [31:0] PC_plus4 
);

    assign PC_plus4 = PC + 32'd4; 

endmodule