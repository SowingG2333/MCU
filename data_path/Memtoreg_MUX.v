`timescale 1ns / 1ps

module Memtoreg_MUX(
    input wire [31:0] memory_ReadData,  
    input wire [31:0] ALUResult,        
    input wire        MemtoReg,         
    output reg [31:0] WD3               
);

    always @(*) begin
        if (MemtoReg) begin
            WD3 = memory_ReadData;
        end else begin
            WD3 = ALUResult;
        end
    end

endmodule