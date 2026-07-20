`timescale 1ns / 1ns

module ppc_tb ();
//==================================
//           PARAMETERS
//==================================
parameter CLK_PULSE_WIDTH = 10ns;   // Freq - 5 MHz

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
    .spibr      ( spibr_reg ),
    .baud_rate  ( baud_rate_wire )
);

PPC ppc (
	.resetn     ( ~sys_rst_reg ),
	.fsm_rstn   ( ~fsm_rst_reg ),
	.clk        ( sys_clk_reg ),
	.baud_clk   ( baud_rate_wire ),
	.spicr      ( spicr_reg ),
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
task change_settings;
input [1:0] spibr_value;

begin
    $display("--------------------------------------------------------");
    $display("[TB INFO]  CHANGE SETTING OF GEN THROUGH spibr BUS!");
    $display("TIME:  %0t", $realtime);
    $display("--------------------------------------------------------");
    @(posedge sys_clk_reg);
    clk_en_reg = 0;
    spibr_reg = spibr_value;
    
    $display("[TB INFO]  VALUE IN HEX -> %h", spibr_reg);
    @(posedge sys_clk_reg);
    clk_en_reg = 1;
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
        
    spibr_reg = 2'b00;  // CLK/2 - BAUD RATE
    spicr_reg = 3'b000; // Mode 0;
    change_settings(spibr_reg);

    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
    @(posedge ppc.sample_clk);
end
endmodule