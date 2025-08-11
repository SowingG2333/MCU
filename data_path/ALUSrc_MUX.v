`timescale 1ns / 1ps

module ALUSrc_MUX(
    input wire [31:0] ReadData2,       
    input wire [31:0] ExtImm,          
    input wire ALUSrc,                 
    output reg [31:0] ALU_input2       
);

    always @(*) begin
        if (ALUSrc) 
            ALU_input2 = ExtImm;      
        else 
            ALU_input2 = ReadData2;    
    end

endmodule