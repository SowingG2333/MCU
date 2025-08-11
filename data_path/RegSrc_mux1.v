`timescale 1ns / 1ps

module RegSrc_mux1 (
    input  wire [3:0] instruction1,  
    input  wire [3:0] instruction0, 
    input  wire       RegSrc1,     
    output reg  [3:0] result       
);

    always @(*) begin
        if (RegSrc1)
            result = instruction1;     
        else
            result = instruction0; 
    end

endmodule