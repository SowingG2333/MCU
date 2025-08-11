`timescale 1ns / 1ps

module extend (
    input wire [31:0] instruction,
    input wire [1:0] imm_src, 
    output reg [31:0] extended_imm
);

    // 循环右移函数
    function [31:0] rotate_right;
        input [31:0] data;
        input [4:0] shift; // 将位宽扩大到5位以容纳最大值30

        // 使用位运算替代循环，高效且可综合
        rotate_right = (data >> shift) | (data << (32 - shift));
    endfunction

    always @(*) begin
        case (imm_src)
            2'b00: extended_imm = rotate_right({24'b0, instruction[7:0]}, 2 * instruction[11:8]);
            
            2'b01: extended_imm = {20'b0, instruction[11:0]}; //Load/Store
            
            2'b10: extended_imm = {{6{instruction[23]}}, instruction[23:0], 2'b00}; //Branch
            
            default: extended_imm = 32'b0;
        endcase
    end

endmodule