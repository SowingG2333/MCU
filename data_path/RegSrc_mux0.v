`timescale 1ns / 1ps

module RegSrc_mux0 (
    input  wire [3:0] instruction,  
    input  wire       RegSrc0,      
    output reg  [3:0] result        
);

    always @(*) begin
        if (RegSrc0)
            result = 4'b1111;      
        else
            result = instruction;  
    end

endmodule