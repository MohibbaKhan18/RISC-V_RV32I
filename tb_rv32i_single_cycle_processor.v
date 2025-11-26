// ============================================
// TESTBENCH FOR RV32I SINGLE-CYCLE PROCESSOR
// ============================================


module tb_rv32i_single_cycle_processor;
    
    // Clock and reset
    reg clk;
    reg rst;
    
    // Debug outputs
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_reg_write_data;
    
    // Instantiate processor
    rv32i_single_cycle_processor DUT (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_reg_write_data(debug_reg_write_data)
    );
    
    // Clock generation (100MHz = 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $dumpfile("rv32i_processor.vcd");
        $dumpvars(0, tb_rv32i_single_cycle_processor);
        
        // Dump all registers for debugging
        $dumpvars(1, DUT.REGFILE.registers[0]);
        $dumpvars(1, DUT.REGFILE.registers[1]);
        $dumpvars(1, DUT.REGFILE.registers[2]);
        $dumpvars(1, DUT.REGFILE.registers[3]);
        $dumpvars(1, DUT.REGFILE.registers[4]);
        $dumpvars(1, DUT.REGFILE.registers[5]);
        $dumpvars(1, DUT.REGFILE.registers[6]);
        $dumpvars(1, DUT.REGFILE.registers[7]);
        $dumpvars(1, DUT.REGFILE.registers[8]);
        $dumpvars(1, DUT.REGFILE.registers[9]);
        $dumpvars(1, DUT.REGFILE.registers[10]);
        
        $display("\n========================================");
        $display("RV32I Single-Cycle Processor Test");
        $display("========================================\n");
        
        // Initialize instruction memory with test program
        load_test_program();
        
        // Reset processor
        rst = 1;
        #20;
        rst = 0;
        
        $display("Time=%0t: Processor reset released", $time);
        $display("Starting execution...\n");
        
        // Run for enough cycles to execute test program
        repeat(30) begin
            @(posedge clk);
            #1; // Small delay for signal stabilization
            display_state();
        end
        
        // Display final results
        #10;
        display_final_results();
        
        // Check results
        verify_results();
        
        $display("\n========================================");
        $display("Simulation Complete!");
        $display("========================================\n");
        
        $finish;
    end
    
    // Load test program into instruction memory
    task load_test_program;
        begin
            $display("Loading test program into instruction memory...");
            
            // Test Program: Basic arithmetic and memory operations
            // 1. Address 0x00: ADDI x1, x0, 5      (x1 = 5)
            DUT.IMEM.cache_mem[0] = 32'h00500093;
            
            //2.  Address 0x04: ADDI x2, x0, 10     (x2 = 10)
            DUT.IMEM.cache_mem[1] = 32'h00A00113;
            
            //3.  Address 0x08: ADD x3, x1, x2      (x3 = x1 + x2 = 15)
            DUT.IMEM.cache_mem[2] = 32'h002081B3;
            
            //4.  Address 0x0C: SUB x4, x2, x1      (x4 = x2 - x1 = 5)
            DUT.IMEM.cache_mem[3] = 32'h40110233;
            
            //5.  Address 0x10: AND x5, x1, x2      (x5 = x1 & x2)
            DUT.IMEM.cache_mem[4] = 32'h0020F2B3;
            
            //6.  Address 0x14: OR x6, x1, x2       (x6 = x1 | x2)
            DUT.IMEM.cache_mem[5] = 32'h0020E333;
            
            //7.  Address 0x18: XOR x7, x1, x2      (x7 = x1 ^ x2)
            DUT.IMEM.cache_mem[6] = 32'h0020C3B3;
            
            //8.  Address 0x1C: SW x3, 0(x0)        (Mem[0] = x3 = 15)
            DUT.IMEM.cache_mem[7] = 32'h00302023;
            
            //9.  Address 0x20: LW x8, 0(x0)        (x8 = Mem[0] = 15)
            DUT.IMEM.cache_mem[8] = 32'h00002403;
            
            //10.  Address 0x24: ADDI x9, x0, 20     (x9 = 20)
            DUT.IMEM.cache_mem[9] = 32'h01400493;
            
            //11. Address 0x28: BEQ x1, x1, 8       (Branch to 0x30, always taken)
            DUT.IMEM.cache_mem[10] = 32'h00108463;
                        
            //13. Address 0x30: ADDI x10, x0, 100   (x10 = 100, should execute)
            DUT.IMEM.cache_mem[12] = 32'h06400513;
            
            //14. Address 0x34: NOP (endless loop for halt)
            DUT.IMEM.cache_mem[13] = 32'h00000013;
            DUT.IMEM.cache_mem[14] = 32'h00000013;
            
            $display("Test program loaded successfully!\n");
        end
    endtask
    
    // Display current processor state
    task display_state;
        begin
            $display("PC=%h | Instr=%h | ALU=%h | WB=%h", 
                     debug_pc, debug_instruction, debug_alu_result, debug_reg_write_data);
        end
    endtask
    
    // Display final register and memory contents
    task display_final_results;
        begin
            $display("\n========================================");
            $display("Final Processor State");
            $display("========================================");
            $display("Register File Contents:");
            $display("x0  = %h (should be 00000000)", DUT.REGFILE.registers[0]);
            $display("x1  = %h (should be 00000005)", DUT.REGFILE.registers[1]);
            $display("x2  = %h (should be 0000000A)", DUT.REGFILE.registers[2]);
            $display("x3  = %h (should be 0000000F)", DUT.REGFILE.registers[3]);
            $display("x4  = %h (should be 00000005)", DUT.REGFILE.registers[4]);
            $display("x5  = %h (should be 00000000 - AND)", DUT.REGFILE.registers[5]);
            $display("x6  = %h (should be 0000000F - OR)", DUT.REGFILE.registers[6]);
            $display("x7  = %h (should be 0000000F - XOR)", DUT.REGFILE.registers[7]);
            $display("x8  = %h (should be 0000000F - LW)", DUT.REGFILE.registers[8]);
            $display("x9  = %h (should be 00000014)", DUT.REGFILE.registers[9]);
            $display("x10 = %h (should be 00000064)", DUT.REGFILE.registers[10]);
            
            $display("\nData Memory Contents:");
            $display("Mem[0] = %h (should be 0000000F)", DUT.DMEM.cache_mem[0]);
        end
    endtask
    
    // Verify test results
    task verify_results;
        integer errors;
        begin
            errors = 0;
            
            $display("\n========================================");
            $display("Verification Results");
            $display("========================================");
            
            if (DUT.REGFILE.registers[0] !== 32'h00000000) begin
                $display("ERROR: x0 = %h, expected 00000000", DUT.REGFILE.registers[0]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[1] !== 32'h00000005) begin
                $display("ERROR: x1 = %h, expected 00000005", DUT.REGFILE.registers[1]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[2] !== 32'h0000000A) begin
                $display("ERROR: x2 = %h, expected 0000000A", DUT.REGFILE.registers[2]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[3] !== 32'h0000000F) begin
                $display("ERROR: x3 = %h, expected 0000000F", DUT.REGFILE.registers[3]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[4] !== 32'h00000005) begin
                $display("ERROR: x4 = %h, expected 00000005", DUT.REGFILE.registers[4]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[8] !== 32'h0000000F) begin
                $display("ERROR: x8 = %h, expected 0000000F", DUT.REGFILE.registers[8]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[9] !== 32'h00000014) begin
                $display("ERROR: x9 = %h, expected 00000014", DUT.REGFILE.registers[9]);
                errors = errors + 1;
            end
            
            if (DUT.REGFILE.registers[10] !== 32'h00000064) begin
                $display("ERROR: x10 = %h, expected 00000064", DUT.REGFILE.registers[10]);
                errors = errors + 1;
            end
            
            if (DUT.DMEM.cache_mem[0] !== 32'h0000000F) begin
                $display("ERROR: Mem[0] = %h, expected 0000000F", DUT.DMEM.cache_mem[0]);
                errors = errors + 1;
            end
            
            if (errors == 0) begin
                $display("\n*** ALL TESTS PASSED! ***");
            end else begin
                $display("\n*** %0d TESTS FAILED! ***", errors);
            end
        end
    endtask
    
    // Timeout watchdog
    initial begin
        #5000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule


