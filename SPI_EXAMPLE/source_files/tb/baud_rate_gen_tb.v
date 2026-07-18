`timescale 1 ns / 1 ns

module baud_rate_gen ();
//==================================
//           PARAMETERS
//==================================
parameter CLK_WIDTH       = 10ns;           // 50 MHz
parameter T               = CLK_WIDTH * 2;

int unsigned rst_time;        // Variable of time for reset
int unsigned success;         // Success simulation variable

//==================================
//      WIRE'S, REG'S and etc
//==================================
// tb required registers
reg                     sys_clk_reg;

reg                     sys_rst_reg; // reg for system rst sim
reg                     fsm_rst_reg; // reg for fsm rst sim

reg                     clk_en_reg;
reg    [1:0]            spibr_wire;

reg    [1:0]            spibr_reg;
reg    [3:0]            edge_cntr;

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
    clk_en_reg = 0;
    spibr_reg  = 0;
    edge_cntr  = 0;

    $display("---------------------------------------------------------");
    $display("[TB INFO]  STARTING SIMULATION OF BAUD RATE GENERATOR");
    $display("---------------------------------------------------------");
    $display("");
    
    system_reset();

    spibr_reg = 2'b00; // CLK/2 - BAUD RATE
    change_settings(spibr_reg);

    edge_detector(spibr_reg);

    

    // $display("-----------------------------------------------");
    // $display("[TB INFO]  WAITING FOR PROGRAM EXECUTION... ");
    // $display("TIME:  %t", $realtime);
    // $display("-----------------------------------------------");

    // fork : waiting_last_instruction
    // begin
    //     wait (riscv_single_cycle.instr_addr_o == LAST_INSTR_ADDR);
    //     $display("-----------------------------------------------");
    //     $display("[TB INFO]  RISCV RECEIVED LAST INSTRUCTION... ");
    //     $display("TIME:  %t", $realtime);
    //     $display("-----------------------------------------------");
    //     $display("");        
    //     @(posedge sys_clk_reg);
    //     disable waiting_last_instruction;
    // end
    
    // begin
    //     #1000;
    //     $display("---------------------------------------------------");
    //     $display("[TB ERROR] TIMEOUT: LAST INSTRUCTION NOT REACHED!");
    //     $display("TIME:  %t", $realtime);
    //     $display("---------------------------------------------------");
    //     $finish;
    // end
    // join_any
    
    // // Checking DPRAM register value with address 0x40
    // if (dual_port_ram.ram[16] == 32'h00000031)
    //     success = 1;
    // else
    //     success = 0;
    
    // $display("");
    // $display("==================== Results of simulation ====================");
    // if (success == 1)
    //     $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS CORRECT, %h ==", dual_port_ram.ram[16]);
    // else
    //     $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS INCORRECT, %h ==", dual_port_ram.ram[16]);
    // $display("===============================================================");
    // $display("");
    // $display("");
    
    $finish;
end

//==================================
//          INSTATIATIONS
//==================================
BAUD_RATE_GENERATOR DUT (
    .resetn     ( ~sys_rst_reg ),
    .fsm_rstn   ( ~fsm_rst_reg ),
    .clk        ( sys_clk_reg ),
    .clk_en     ( clk_en_reg ),
    .spibr      ( spibr_wire ),
    .baud_rate  (  )
);


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

// Task for change baud rate settings
task change_settings;
input [1:0] spibr_value;

begin
    @(posedge sys_clk_reg);
    clk_en_reg = 0;
    spibr_wire = spibr_value;

    @(posedge sys_clk_reg);
    clk_en_reg = 1;
end
endtask

// Monitor task that counting baud rate edges
task edge_detector;
input [1:0] spibr_value;
realtime t_prev_rise, t_curr_rise;

begin
    fork: waiting_edges
        begin
            repeat (4)
            begin
                @(posedge DUT.baud_rate);
                t_prev_rise = $realtime;
                @(posedge DUT.baud_rate);
                t_curr_rise = $realtime;
                
               if (spibr_value == 2'b00)
               begin
                   if ((t_curr_rise - t_prev_rise) / )
               end 
            end

            //disable waiting_edges;
        end

        begin
            
        end

        begin
            #10000
            $display("---------------------------------------------------");
            $display("[TB ERROR] TIMEOUT: BAUD RATE EDGES NOT REACHED!");
            $display("TIME:  %t", $realtime);
            $display("---------------------------------------------------");
            $finish;
        end
    join_any

    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
    @(posedge DUT.baud_rate);
end
endtask
endmodule 