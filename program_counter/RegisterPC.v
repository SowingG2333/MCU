`timescale 1ns / 1ps

module RegisterPC (
    input  wire        clk,     
    input  wire [31:0] PC1,      
    input  wire        rst,      
    output reg  [31:0] PC         
);

initial begin               
        PC = 32'b0;              
    end
    
    always @(posedge clk) begin
        if (rst) begin
            PC <= 32'b0;         
        end else begin
            PC <= PC1;             
        end
    end

endmodule