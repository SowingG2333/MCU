`timescale 1ns / 1ps

module top(
    input wire clk,
    input wire rst,
    
    output wire [31:0] mem_addr,         
    output wire [31:0] mem_wdata,       
    output wire        mem_we,         
    input  wire [31:0] mem_rdata,      
    // debug
    output wire [31:0] current_pc,
    output wire [31:0] current_instruction,
    output wire        dbg_MemtoReg,
    output wire        dbg_RegWrite,
    output wire [31:0] dbg_WD3
    );
    
    wire [31:0] PC;             
    wire [31:0] PC1;            
    wire [31:0] PC_plus4;       
    wire [31:0] PC_plus8;      
    wire [31:0] extended_imm;   
    wire [31:0] read_data1;     
    wire [31:0] read_data2;        
    wire [3:0]  WriteReg;     
    wire [31:0] instruction;    
    wire [31:0] ALUResult;      
    wire [31:0] rdata;         
    wire [3:0] ra1;             
    wire [3:0] ra2;            
    wire [31:0] b;             
    wire [31:0] WD3;            
    wire [3:0] ALU_flags;

    wire        PCSrc;
    wire        RegWrite;
    wire [1:0]  RegSrc;
    wire        MemtoReg;
    wire        MemWrite;
    wire        ALUSrc;
    wire [2:0]  ALUControl;
    wire [1:0]  ImmSrc;
    
    assign mem_addr = ALUResult;
    assign mem_wdata = read_data2;
    assign mem_we = MemWrite;
    
    // debug
    assign current_pc = PC;
    assign current_instruction = instruction;
    assign dbg_MemtoReg = MemtoReg;
    assign dbg_RegWrite = RegWrite;
    assign dbg_WD3      = WD3;
    
    
    instruction_memory inst_mem (
        .clk(clk),              
        .rst(rst),
        .address(PC),
        .instruction(instruction)
    );
    
    control_logic control_unit(
        .clk(clk),
        .Instr(instruction),
        .ALUFlags(ALU_flags),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .RegSrc(RegSrc),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .ImmSrc(ImmSrc)
    );
    
    RegSrc_mux0 src_mux0(
        .instruction(instruction[19:16]),
        .RegSrc0(RegSrc[0]),
        .result(ra1)
    );
    
    RegSrc_mux1 src_mux1(
        .instruction1(instruction[15:12]),
        .instruction0(instruction[3:0]),
        .RegSrc1(RegSrc[1]),
        .result(ra2)
    );
    
    PC_4Adder adder4(
        .PC(PC),
        .PC_plus4(PC_plus4)
    );
    
    PC_8Adder adder8(
        .PC_plus4(PC_plus4),
        .PC_plus8(PC_plus8)
    );
    
    RegisterFile RF(
        .clk(clk),
        .rst(rst),
        .read_reg1(ra1),
        .read_reg2(ra2),
        .write_reg(instruction[15:12]),
        .write_data(WD3),
        .reg_write(RegWrite),
        .pc_plus_8(PC_plus8),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    ALUSrc_MUX alusrc_mux(
        .ReadData2(read_data2),
        .ExtImm(extended_imm),
        .ALUSrc(ALUSrc),
        .ALU_input2(b)
    );
    
    extend extend1(
        .instruction(instruction),
        .imm_src(ImmSrc),
        .extended_imm(extended_imm)
    );
    
    ALU ALU1(
        .a(read_data1),
        .b(b),
        .ALUOp(ALUControl),
        .result(ALUResult),
        .flags(ALU_flags)
    );
    
//    data_memory data_memory1(
//        .clk(clk),
//        .we(MemWrite),
//        .addr(ALUResult),
//        .wdata(read_data2),
//        .rdata(rdata)
//    ); 
    
    Memtoreg_MUX Memtoreg_MUX1(
        .memory_ReadData(mem_rdata),
        .ALUResult(ALUResult),
        .MemtoReg(MemtoReg),
        .WD3(WD3)
    );
    
    PCSrc_MUX PCSrc_MUX1(
        .PC_src1(ALUResult),
        .PC_plus4(PC_plus4),
        .PCSrc(PCSrc),
        .PC1(PC1)
    );
    
    RegisterPC RegisterPC1(
        .clk(clk),
        .PC1(PC1),
        .rst(rst),
        .PC(PC)
    );
    
endmodule