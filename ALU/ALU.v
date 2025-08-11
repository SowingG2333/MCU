`timescale 1ns / 1ps

module ALU(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0]  ALUOp,
    
    output reg [31:0] result,
    output reg [3:0]  flags // N, Z, C, V
);

    reg [32:0] temp_result;
    reg        overflow;
    reg        carry_out; // 用于正确处理C标志位的中间信号

    always @(*) begin
        // --- 初始化默认值 ---
        temp_result = 33'b0;
        overflow = 1'b0;
        carry_out = 1'b0; // 默认C位为0

        // --- 根据操作码进行计算 ---
        case (ALUOp)
            3'b000: begin // AND
                result = a & b;
                temp_result = {1'b0, result};
                // 逻辑运算不影响C和V标志位
            end
            
            3'b001: begin // ORR
                result = a | b;
                temp_result = {1'b0, result};
                // 逻辑运算不影响C和V标志位
            end
            
            3'b010: begin // ADD
                temp_result = {1'b0, a} + {1'b0, b};
                result = temp_result[31:0];
                overflow = (a[31] == b[31]) && (result[31] != a[31]);
                carry_out = temp_result[32]; // 对于加法, C是直接的进位
            end
            
            3'b011: begin // SUB
                temp_result = {1'b0, a} - {1'b0, b};
                result = temp_result[31:0];
                overflow = (a[31] != b[31]) && (result[31] != a[31]);
                carry_out = ~temp_result[32]; // 对于减法, C是“非借位”，即借位的反相
            end
            
            3'b100: begin // MOV
                result = b;
                temp_result = {1'b0, result};
                // MOV通常不影响标志位，但如果需要，可以在这里设置
            end
            
            default: begin
                result = 32'h00000000;
                temp_result = 33'b0;
            end
        endcase

        // --- 统一设置标志位 ---
        flags[3] = result[31];          // N
        flags[2] = (result == 32'b0);   // Z 
        flags[1] = carry_out;           // C
        flags[0] = overflow;            // V 
    end

endmodule