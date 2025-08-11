`timescale 1ns / 1ps

module decoder (
    input  wire [31:0] Instr,
    output reg [1:0]   FlagW,
    output reg         PCS,
    output reg         RegW,
    output reg         MemW,
    output reg         MemtoReg,
    output reg         ALUSrc,
    output reg [1:0]   ImmSrc,
    output reg [1:0]   RegSrc,
    output reg [2:0]   ALUControl
);

    wire [1:0] Op      = Instr[27:26];
    wire [3:0] Funct   = Instr[24:21];
    wire       I_bit   = Instr[25];
    wire       S_bit   = Instr[20];
    wire       L_bit   = Instr[20];
    wire       BL_bit  = Instr[24];

    localparam OP_DP     = 2'b00, OP_MEM   = 2'b01, OP_B     = 2'b10;
    localparam ALU_ADD   = 3'b010, ALU_SUB  = 3'b011, ALU_AND  = 3'b000, ALU_ORR  = 3'b001, ALU_MOV  = 3'b100;
    localparam FUNCT_ADD = 4'b0100, FUNCT_SUB = 4'b0010, FUNCT_AND = 4'b0000, FUNCT_ORR = 4'b1100, FUNCT_MOV = 4'b1101, FUNCT_CMP = 4'b1010;

    always @(*) begin
        FlagW      = 2'b00;
        PCS        = 1'b0;
        RegW       = 1'b0;
        MemW       = 1'b0;
        MemtoReg   = 1'b0;
        ALUSrc     = 1'b0;
        ImmSrc     = 2'b00;
        RegSrc     = 2'b00;
        ALUControl = ALU_ADD;

        case (Op)
            OP_DP: begin
                RegW       = 1'b1;
                ALUSrc     = I_bit;
                if (S_bit) FlagW = 2'b11;
                if (I_bit) ImmSrc = 2'b00;
                
                case (Funct)
                    FUNCT_ADD: ALUControl = ALU_ADD;
                    FUNCT_SUB: ALUControl = ALU_SUB;
                    FUNCT_AND: ALUControl = ALU_AND;
                    FUNCT_ORR: ALUControl = ALU_ORR;
                    FUNCT_MOV: ALUControl = ALU_MOV;
                    FUNCT_CMP: begin ALUControl=ALU_SUB; RegW=0; FlagW=2'b11; end
                    default: ;
                endcase
            end
            OP_MEM: begin
                ALUSrc=1; ALUControl=ALU_ADD; ImmSrc=2'b01;
                if (L_bit) begin // LDR
                    RegW=1; MemtoReg=1; RegSrc=2'b00;
                end else begin // STR
                    MemW=1; RegSrc=2'b10;
                end
            end
            OP_B: begin
                PCS=1; ALUSrc=1; ALUControl=ALU_ADD; ImmSrc=2'b10; RegSrc=2'b01;
                if (BL_bit) RegW = 1'b1;
            end
            default: ;
        endcase
    end
endmodule