`timescale 1ns / 1ps

module conditional_logic (
    input  wire        clk,
    input  wire [31:0] Instr, 
    input  wire [3:0]  ALUFlags,
    
    input  wire [1:0]  FlagW,
    input  wire        PCS,
    input  wire        RegW,
    input  wire        MemW,

    output reg         PCSrc,
    output reg         RegWrite,
    output reg         MemWrite
);
    wire [3:0] Cond = Instr[31:28];
    reg  [1:0] FlagWrite;
    reg  [3:0] Flags; // {N, Z, C, V}
    wire       CondEx;


    initial begin
        Flags = 4'b0000;
    end

    assign CondEx =
        (Cond == 4'b0000) ? (Flags[2]) : (Cond == 4'b0001) ? (~Flags[2]) :
        (Cond == 4'b0010) ? (Flags[1]) : (Cond == 4'b0011) ? (~Flags[1]) :
        (Cond == 4'b0100) ? (Flags[3]) : (Cond == 4'b0101) ? (~Flags[3]) :
        (Cond == 4'b0110) ? (Flags[0]) : (Cond == 4'b0111) ? (~Flags[0]) :
        (Cond == 4'b1000) ? (Flags[1] && ~Flags[2]) : (Cond == 4'b1001) ? (~Flags[1] || Flags[2]) :
        (Cond == 4'b1010) ? (Flags[3] == Flags[0]) : (Cond == 4'b1011) ? (Flags[3] != Flags[0]) :
        (Cond == 4'b1100) ? (~Flags[2] && (Flags[3] == Flags[0])) :
        (Cond == 4'b1101) ? (Flags[2] || (Flags[3] != Flags[0])) :
        (Cond == 4'b1110) ? 1'b1 : 1'b0;

    always @(*) begin
        PCSrc        = PCS  && CondEx;
        RegWrite     = RegW  && CondEx;
        MemWrite     = MemW  && CondEx;
        FlagWrite[1] = FlagW[1] && CondEx;
        FlagWrite[0] = FlagW[0] && CondEx;
    end

    always @(posedge clk) begin
        if (FlagWrite[1]) Flags[3:2] <= ALUFlags[3:2]; // N, Z
        if (FlagWrite[0]) Flags[1:0] <= ALUFlags[1:0]; // C, V
    end
endmodule