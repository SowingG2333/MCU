`timescale 1ns / 1ps

// =================================================================
// 最终顶层模块 (用于综合和上板)
// =================================================================
module mcu_test_harness(
    input  wire clk, // 来自开发板的主时钟
    input  wire rst, // 来自开发板按键的异步复位信号
    output wire heartbeat_led // 心跳LED，指示FPGA正在运行
);
    
    //----------------------------------------------------------------
    // 信号声明
    //----------------------------------------------------------------
    
    // --- 创建统一的系统工作时钟 ---
    wire clk_sys; // 由IP核生成的、驱动整个系统的工作时钟

    // --- 同步复位逻辑 ---
    // 将外部的异步rst信号，同步到系统时钟域
    reg  rst_sync_r1, rst_sync_r2;
    wire rst_sync;

    always @(posedge clk_sys) begin // 使用新的系统时钟进行同步
        rst_sync_r1 <= rst;
        rst_sync_r2 <= rst_sync_r1;
    end
    assign rst_sync = rst_sync_r2;

    // --- 心跳LED逻辑 ---
    reg [26:0] counter_for_led;
    always @(posedge clk_sys or posedge rst_sync) begin
        if (rst_sync) begin
            counter_for_led <= 0;
        end else begin
            counter_for_led <= counter_for_led + 1;
        end
    end
    assign heartbeat_led = counter_for_led[26];

    // --- CPU和内存接口信号 ---
    reg           cpu_rst;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire        mem_we;
    reg  [31:0] mem_rdata;
    wire [31:0] current_pc;

    // --- 外部存储器IP核接口信号 ---
    wire [7:0]  rom_addr;
    wire [15:0] test_vector_in;
    wire [7:0]  ram_addr;
    wire [15:0] verify_vector_out;
    reg         ram_we;

    // --- 内部数据RAM (dmem) ---
    reg [31:0] internal_ram [0:63]; 

    // --- 新增: 20比特计数器 cnt_test ---
    reg [19:0] cnt_test;
    reg        cnt_en; // 计数器使能信号
    
    //----------------------------------------------------------------
    // 模块例化
    //----------------------------------------------------------------

    // a. 时钟管理IP核例化 (从top模块移到顶层)
    clk_wiz_0 clkwiz_inst (
        .clk_in1(clk),       // 输入来自开发板的100MHz时钟
        .clk_out1(clk_sys)   // 输出统一的系统工作时钟 (例如25MHz)
    );

    // b. CPU核例化
    top uut_mcu (
        .clk(clk_sys),       
        .rst(cpu_rst),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_we(mem_we),
        .mem_rdata(mem_rdata),
        .current_pc(current_pc)
    );

    // c. 外部ROM IP核例化
    blk_mem_gen_0 test_ROM (
        .clka(clk_sys),      
        .addra(rom_addr),
        .douta(test_vector_in)
    );
    
    // d. 外部RAM IP核例化
    blk_mem_gen_1 verify_RAM (
        .clka(clk_sys),      
        .addra(ram_addr),
        .wea(ram_we),
        .dina(verify_vector_out),
        .douta()
    );
    
    //----------------------------------------------------------------
    // 顶层控制状态机 (Mealy FSM)
    //----------------------------------------------------------------
    localparam S_IDLE          = 4'd0, S_LOAD_SET_ADDR   = 4'd1, S_LOAD_WAIT       = 4'd2,
             S_LOAD_GET_DATA = 4'd3, S_CPU_SORT      = 4'd4, S_WRITE_BACK    = 4'd5,
             S_DONE            = 4'd6;

//    localparam CPU_FINISH_PC = 32'h44; 
    localparam CPU_FINISH_PC = 32'h64;    
        
    reg [3:0] state;
    reg [6:0] counter; // 用于控制ROM读取和RAM写入的地址计数器

    // --- 状态转移逻辑 (同步时序逻辑) ---
    always @(posedge clk_sys or posedge rst_sync) begin // **关键修正: 状态机使用新的系统时钟**
        if (rst_sync) begin
            state <= S_IDLE;
            counter <= 0;
            cnt_test <= 0; // 复位计数器
            cnt_en <= 0;   // 复位计数器使能
        end else begin
            case (state)
                S_IDLE:          state <= S_LOAD_SET_ADDR;
                S_LOAD_SET_ADDR: state <= S_LOAD_WAIT;
                S_LOAD_WAIT:     state <= S_LOAD_GET_DATA;
                S_LOAD_GET_DATA: begin
                    cnt_en <= 1; // 在S_LOAD_GET_DATA状态开始计数
                    if (counter == 63) begin
                        state <= S_CPU_SORT;
                    end else begin
                        counter <= counter + 1;
                        state <= S_LOAD_SET_ADDR;
                    end
                end
                S_CPU_SORT: begin
                    if (current_pc == CPU_FINISH_PC) begin
                        state <= S_WRITE_BACK;
                        counter <= 0;
                    end
                end
                S_WRITE_BACK: begin
                    if (counter == 63) begin
                        state <= S_DONE;
                        cnt_en <= 0; // 最后一个verify_vector_out输出完成后停止计数
                    end
                    counter <= counter + 1;
                end
                S_DONE: state <= S_DONE;
            endcase
        end
    end

    // --- 20比特计数器 cnt_test 逻辑 ---
    always @(posedge clk_sys) begin
        if (rst_sync) begin
            cnt_test <= 0;
        end else if (cnt_en) begin // 只有当cnt_en为高时才计数
            cnt_test <= cnt_test + 1;
        end
    end

    // --- 输出生成逻辑 (Mealy型组合逻辑) ---
    always @(*) begin
        cpu_rst = 1;
        ram_we = 0;
        case (state)
            S_CPU_SORT:    cpu_rst = 0;
            S_WRITE_BACK:  ram_we = 1;
        endcase
    end
    
    //----------------------------------------------------------------
    // 数据通路和内存接口逻辑
    //----------------------------------------------------------------
    
    // --- 状态机控制的数据通路 ---
    assign rom_addr = counter[6:0];
    assign ram_addr = counter[6:0];
    assign verify_vector_out = internal_ram[counter][15:0];

    // --- 内部RAM的读写逻辑 ---
    always @(posedge clk_sys) begin 
        if (state == S_LOAD_GET_DATA) begin
            internal_ram[counter] <= {{16{test_vector_in[15]}}, test_vector_in};
        end
        else if (state == S_CPU_SORT && mem_we) begin
            internal_ram[mem_addr[9:2]] <= mem_wdata;
        end
    end

    // --- CPU内存接口逻辑 ---
    always @(*) begin
        if (state == S_CPU_SORT) begin
            mem_rdata = internal_ram[mem_addr[9:2]];
        end else begin
            mem_rdata = 32'hxxxxxxxx;
        end
    end
    
    //----------------------------------------------------------------
    // ILA调试逻辑
    //----------------------------------------------------------------
    ila_0 your_ila_instance (
        .clk(clk_sys),       
        .probe0(cnt_en),
        .probe1(verify_vector_out),
        .probe2(test_vector_in),
        .probe3(cnt_test)
    );

endmodule