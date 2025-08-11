`timescale 1ns / 1ps

module PCSrc_MUX(
    input wire [31:0] PC_src1,            
    input wire [31:0] PC_plus4,           
    input wire PCSrc,                     
    output reg [31:0] PC1                
);

    always @(*) begin
    
        if (PCSrc) 
            PC1 = PC_src1;     
        else 
            PC1 = PC_plus4;    
    end

endmodule