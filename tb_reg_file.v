// ============================================
// TESTBENCH: REGISTER FILE
// ============================================
module tb_register_file;
    reg clk, rst, wr_en;
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [31:0] wr_data;
    wire [31:0] rs1_data, rs2_data;
    
    register_file uut (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .wr_data(wr_data),
        .wr_en(wr_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, tb_register_file);
        
        rst = 1; wr_en = 0;
        #10 rst = 0;
        
        // Write to register 5
        rd_addr = 5; wr_data = 32'hDEADBEEF; wr_en = 1;
        #10;
        
        // Write to register 10
        rd_addr = 10; wr_data = 32'hCAFEBABE;
        #10 wr_en = 0;
        
        // Read registers 5 and 10
        rs1_addr = 5; rs2_addr = 10;
        #10 $display("R5=%h, R10=%h", rs1_data, rs2_data);
        
        // Test x0 (should always be 0)
        rd_addr = 0; wr_data = 32'hFFFFFFFF; wr_en = 1;
        #10 rs1_addr = 0;
        #10 $display("R0=%h (should be 0)", rs1_data);
        
        #10 $finish;
    end
endmodule
