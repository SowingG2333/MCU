`timescale 1ns / 1ps

module instruction_memory (
    input wire clk,
    input wire rst,
    input wire [31:0] address,
    output wire [31:0] instruction // 将输出改为wire类型
);

    reg [31:0] memory [0:255]; 

    initial begin
        // 从项目内的程序镜像加载指令（相对路径）
        $readmemh("memory/instructions.mem", memory);
    end

    // ===============================================================
    // 用assign语句代替always块，实现异步读取 ==
    // ===============================================================
    assign instruction = memory[address[9:2]];
    // ===============================================================

endmodule