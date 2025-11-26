// ============================================
// TESTBENCH 7: ALU
// ============================================
module tb_alu;
    reg [31:0] operand_a, operand_b;
    reg [3:0] alu_ctrl;
    wire [31:0] result;
    wire zero, negative, carry, overflow;
    
    alu uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );
    
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);
        
        operand_a = 32'd15;
        operand_b = 32'd10;
        
        // ADD
        alu_ctrl = 4'b0000;
        #10 $display("ADD: %d + %d = %d", operand_a, operand_b, result);
        
        // SUB
        alu_ctrl = 4'b0001;
        #10 $display("SUB: %d - %d = %d", operand_a, operand_b, result);
        
        // AND
        alu_ctrl = 4'b1001;
        #10 $display("AND: %h & %h = %h", operand_a, operand_b, result);
        
        // OR
        alu_ctrl = 4'b1000;
        #10 $display("OR: %h | %h = %h", operand_a, operand_b, result);
        
        // XOR
        alu_ctrl = 4'b0101;
        #10 $display("XOR: %h ^ %h = %h", operand_a, operand_b, result);
        
        // SLL
        operand_a = 32'h00000001;
        operand_b = 32'd4;
        alu_ctrl = 4'b0010;
        #10 $display("SLL: %h << %d = %h", operand_a, operand_b, result);
        
        // SRL
        operand_a = 32'h80000000;
        alu_ctrl = 4'b0110;
        #10 $display("SRL: %h >> %d = %h", operand_a, operand_b, result);
        
        // SRA
        alu_ctrl = 4'b0111;
        #10 $display("SRA: %h >>> %d = %h", operand_a, operand_b, result);
        
        // SLT
        operand_a = 32'd5;
        operand_b = 32'd10;
        alu_ctrl = 4'b0011;
        #10 $display("SLT: %d < %d = %d", operand_a, operand_b, result);
        
        // SLTU
        operand_a = 32'hFFFFFFFF;
        operand_b = 32'h00000001;
        alu_ctrl = 4'b0100;
        #10 $display("SLTU: %h < %h = %d", operand_a, operand_b, result);
        
        #10 $finish;
    end
endmodule

