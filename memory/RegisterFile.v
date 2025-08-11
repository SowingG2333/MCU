`timescale 1ns / 1ps

module RegisterFile (
    input wire clk,
    input wire rst,
    input wire [3:0] read_reg1,
    input wire [3:0] read_reg2,
    input wire [3:0] write_reg,
    input wire [31:0] write_data,
    input wire reg_write,
    input wire [31:0] pc_plus_8, 
    output reg [31:0] read_data1,
    output reg [31:0] read_data2
);

    reg [31:0] reg_file [0:15]; 
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 15; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end else begin
            if (reg_write && write_reg != 4'd15) begin
                reg_file[write_reg] <= write_data;
            end
        end
    end

    always @(*) begin
        if (read_reg1 == 4'd15) begin
            read_data1 = pc_plus_8;
        end else begin
            read_data1 = reg_file[read_reg1];
        end

        if (read_reg2 == 4'd15) begin
            read_data2 = pc_plus_8;
        end else begin
            read_data2 = reg_file[read_reg2];
        end
    end

endmodule