`timescale 1ns / 1ns

module ppc_tb ();
//==================================
//           PARAMETERS
//==================================
parameter CLK_PULSE_WIDTH = 10ns;   // Freq - 50 MHz

int unsigned rst_time;              // Time variable for reset

//==================================
//      WIRE'S, REG'S and etc
//==================================
reg                     sys_rst_reg; // reg for system rst sim
reg                     fsm_rst_reg; // reg for fsm rst sim
reg                     sys_clk_reg;

reg                     clk_en_reg;
reg    [1:0]            spibr_reg;
reg    [2:0]            spicr_reg;

wire                    baud_rate_wire;
reg    [1:0]            spibr_for_bd;
reg    [2:0]            spicr_for_ppc;
//wire                    sample_clk_wire;
//wire                    shift_clk_wire;

//==================================
//          SYSTEM CLOCK
//==================================
initial
begin
    forever
    begin
        #CLK_PULSE_WIDTH sys_clk_reg = ~sys_clk_reg;    
    end
end

//==================================
//          INSTATIATIONS
//==================================
BAUD_RATE_GENERATOR baud_rate_gen (
    .resetn     ( ~sys_rst_reg ),
    .fsm_rstn   ( ~fsm_rst_reg ),
    .clk        ( sys_clk_reg ),
    .clk_en     ( clk_en_reg ),
    .spibr      ( spibr_for_bd ),
    .baud_rate  ( baud_rate_wire )
);

PPC ppc (
	.resetn     ( ~sys_rst_reg ),
	.fsm_rstn   ( ~fsm_rst_reg ),
	.clk        ( sys_clk_reg ),
	.baud_clk   ( baud_rate_wire ),
	.spicr      ( spicr_for_ppc ),
	.sample_clk (  ),
	.shift_clk  (  )
);

//==================================
//         TESTBENCH TASKS
//==================================
task system_reset;
begin
    sys_rst_reg = 1;
    $display("----------------------------");
    $display("[TB INFO]  RESET SETTED!");
    $display("TIME:  %0t", $realtime);
    $display("----------------------------");

    // Set random time in range between some range of ns
    rst_time = $urandom_range(20ns, 60ns);
    
    #rst_time sys_rst_reg = 0;
    $display("----------------------------");
    $display("[TB INFO]  RESET RELEASED!");
    $display("TIME:  %0t", $realtime);
    $display("----------------------------");
    $display("");
end
endtask

// Task for change baud rate settings
task change_bd_settings;
input [1:0] spibr_value;

begin
    $display("--------------------------------------------------------");
    $display("[TB INFO]  CHANGE SETTING OF GEN THROUGH spibr BUS!");
    $display("TIME:  %0t", $realtime);
    $display("--------------------------------------------------------");
    @(posedge sys_clk_reg);
    clk_en_reg = 0;
    spibr_for_bd = spibr_value;
    
    $display("[TB INFO]  VALUE IN HEX -> %h", spibr_for_bd);
    @(posedge sys_clk_reg);
    clk_en_reg = 1;
end
endtask

// Task for change ppc module settings
task change_ppc_settings;
input [2:0] spicr_value;

begin
    $display("--------------------------------------------------------");
    $display("[TB INFO]  CHANGE SETTING OF PPC THROUGH spicr BUS!");
    $display("TIME:  %0t", $realtime);
    $display("--------------------------------------------------------");
    @(posedge sys_clk_reg);
    spicr_for_ppc = spicr_value;

    $display("[TB INFO]  VALUE IN HEX -> %h", spicr_for_ppc);
    @(posedge sys_clk_reg);
end
endtask

// Task for check sample_ and shift_ signals of ppc
task chk_ppc;
begin
    $display("--------------------------------------------------------");
    $display("[TB INFO]  CHECK SAMPLE_ & SHIFT_ OUTPUTS OF PPC");
    $display("TIME:  %0t", $realtime);
    $display("--------------------------------------------------------");

    repeat (5)
    begin
        if (ppc.spicr == 3'b000) // CPOL bit 1 = 0
        begin
            @(posedge baud_rate_wire);
            if (ppc.sample_clk && (!ppc.shift_clk))
            begin
               $display("[TB INFO]  SAMPLE AND SHIFT CLK ENABLES ARE CORRECT FOR CPOL = 0 AT RISING EDGE OF BAUD CLK");
               $display("SAMPPLE VALUE = %0h, SHIFT VALUE = %0h", ppc.sample_clk, ppc.shift_clk);
               $display("TIME:  %0t", $realtime); 
               $display("--------------------------------------------------------");
            end
            else
            begin
                $error("[TB ERROR]  SAMPLE AND SHIFT CLK ENABLES ARE NOT CORRECT AT RISING EDGE OF BAUD CLK");
                $finish;
            end
            // CODE NOT COMPELETED!
        end
        
        // else
        // begin
            
        // end

        //@(negedge baud_rate_wire);
        
    end
end
endtask

//==================================
//      Main block of testbench
//==================================
initial
begin
    sys_clk_reg = 0;
    clk_en_reg  = 0;
    fsm_rst_reg = 0;
    spibr_reg   = 0;
    spicr_reg   = 0;

    $display("---------------------------------------------------------");
    $display("[TB INFO]  STARTING SIMULATION OF PPC");
    $display("---------------------------------------------------------");
    $display("");

    system_reset();
        
    spibr_reg = 2'b01;             // BAUD RATE - CLK/4
    spicr_reg = 3'b000;            // Mode 0;
    change_bd_settings(spibr_reg);
    change_ppc_settings(spicr_reg);
    
    chk_ppc();
    $finish;
end
endmodule