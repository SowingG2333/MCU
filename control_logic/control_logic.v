`timescale 1ns / 1ps
 
module control_logic (
    input  wire        clk,
    input  wire [31:0] Instr,
    input  wire [3:0]  ALUFlags,
    output wire        PCSrc,
    output wire        RegWrite,
    output wire [1:0]  RegSrc,
    output wire        MemtoReg,
    output wire        MemWrite,
    output wire        ALUSrc,
    output wire [2:0]  ALUControl,
    output wire [1:0]  ImmSrc
);

    wire [1:0]  w_FlagW;
    wire        w_PCS;
    wire        w_RegW;
    wire        w_MemW;
    wire [1:0]  w_FlagWrite_internal;

    decoder u_decoder (
        .Instr      (Instr),
        .FlagW      (w_FlagW),
        .PCS        (w_PCS),
        .RegW       (w_RegW),
        .MemW       (w_MemW),
        .MemtoReg   (MemtoReg),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegSrc     (RegSrc),
        .ALUControl (ALUControl)
    );

    conditional_logic u_cond_logic (
        .clk        (clk),
        .Instr      (Instr),
        .ALUFlags   (ALUFlags),
        .FlagW      (w_FlagW),
        .PCS        (w_PCS),
        .RegW       (w_RegW),
        .MemW       (w_MemW),
        .PCSrc      (PCSrc),
        .RegWrite   (RegWrite),
        .MemWrite   (MemWrite)
    );
endmodule