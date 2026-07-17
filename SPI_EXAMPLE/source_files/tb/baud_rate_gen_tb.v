`timescale 1 ns / 1 ns

module baud_rate_gen ();
//==================================
//           PARAMETERS
//==================================
parameter CLK_WIDTH       = 10ns;  // 50 MHz

int unsigned rst_time;        // Variable of time for reset
int unsigned success;         // Success simulation variable

//==================================
//      WIRE'S, REG'S and etc
//==================================
// tb required registers
reg                     sys_clk_reg;

reg                     sys_rst_reg; // reg for system rst sim
reg                     fsm_rst_reg; // reg for fsm rst sim

//==================================
//          SYSTEM CLOCK
//==================================
initial
begin
    sys_clk_reg = 0;

    forever
    begin
        #CLK_WIDTH sys_clk_reg = ~sys_clk_reg;
    end
end

//==================================
//      Main block of testbench
//==================================
initial
begin
    $display("---------------------------------------------------------");
    $display("[TB INFO]  STARTING SIMULATION OF BAUD RATE GENERATOR");
    $display("---------------------------------------------------------");
    $display("");
    
    system_reset();

    $display("-----------------------------------------------");
    $display("[TB INFO]  WAITING FOR PROGRAM EXECUTION... ");
    $display("TIME:  %t", $realtime);
    $display("-----------------------------------------------");

    fork : waiting_last_instruction
    begin
        wait (riscv_single_cycle.instr_addr_o == LAST_INSTR_ADDR);
        $display("-----------------------------------------------");
        $display("[TB INFO]  RISCV RECEIVED LAST INSTRUCTION... ");
        $display("TIME:  %t", $realtime);
        $display("-----------------------------------------------");
        $display("");        
        @(posedge sys_clk_reg);
        disable waiting_last_instruction;
    end
    
    begin
        #1000;
        $display("---------------------------------------------------");
        $display("[TB ERROR] TIMEOUT: LAST INSTRUCTION NOT REACHED!");
        $display("TIME:  %t", $realtime);
        $display("---------------------------------------------------");
        $finish;
    end
    join_any
    
    // Checking DPRAM register value with address 0x40
    if (dual_port_ram.ram[16] == 32'h00000031)
        success = 1;
    else
        success = 0;
    
    $display("");
    $display("==================== Results of simulation ====================");
    if (success == 1)
        $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS CORRECT, %h ==", dual_port_ram.ram[16]);
    else
        $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS INCORRECT, %h ==", dual_port_ram.ram[16]);
    $display("===============================================================");
    $display("");
    $display("");
    
    $finish;
end

//==================================
//          INSTATIATIONS
//==================================
BAUD_RATE_GENERATOR (
    .resetn     ( ~sys_rst_reg ),
    .fsm_rstn   (  ),
    .clk        (  ),
    .clk_en     (  ),
    .spibr      (  ),
    .baud_rate  (  )
);

// riscv #(
//     .WIDTH ( WIDTH )
// ) riscv_single_cycle (
//     .clk_i        ( sys_clk_reg     ),
//     .rst_i        ( sys_rst_reg     ),
//     .instr_addr_o ( instr_addr_wire ),
//     .instr_data_i ( instr_data_wire ),
//     .mem_we_o     ( we_wire         ),
//     .mem_addr_o   ( mem_addr_o_wire ),
//     .mem_data_i   ( mem_data_i_wire ),
//     .mem_data_o   ( mem_data_o_wire )
// );

// dpram #(
//     .DATA_WIDTH ( WIDTH ),
//     .ADDR_WIDTH ( WIDTH )
// ) dual_port_ram (
//     .data_a ( 32'b0           ), // Connected to zero for read-only port
//     .data_b ( mem_data_o_wire ),
//     .addr_a ( instr_addr_wire ),
//     .addr_b ( mem_addr_o_wire ),
//     .we_a   ( 1'b0            ), // Write disabled for port A
//     .we_b   ( we_wire         ),
//     .clk    ( sys_clk_reg     ),
//     .q_a    ( instr_data_wire ),
//     .q_b    ( mem_data_i_wire )
// );

//==================================
//         TESTBENCH TASKS
//==================================
task system_reset;
begin
    sys_rst_reg = 1;
    $display("----------------------------");
    $display("[TB INFO]  RESET SETTED!");
    $display("TIME:  %t", $realtime);
    $display("----------------------------");

    // Set random time in range between some range of ns
    rst_time = $urandom_range(20ns, 60ns);
    
    #rst_time sys_rst_reg = 0;
    $display("----------------------------");
    $display("[TB INFO]  RESET RELEASED!");
    $display("TIME:  %t", $realtime);
    $display("----------------------------");
    $display("");
end
endtask
//
endmodule 