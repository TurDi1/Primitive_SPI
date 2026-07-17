// Phase and Polarity control (template for future upgrade)
module PPC (
	resetn,
	fsm_rstn,
	clk,
	baud_clk,
	spicr,
	sample_clk,
	shift_clk
);
//==================================
//             PORTS
//==================================
input             resetn;		// System reset
input             fsm_rstn;     // External reset input from FSM of control module
input             clk;			// System clk
input             baud_clk;		// Input clk from baud generator
input    [2:0]    spicr;		// Input with PPC settings
output            sample_clk;	// Output sample clk for latch logic
output            shift_clk;	// Output shift clk for shift register

//==================================
//      WIRE'S, REG'S AND ETC 
//==================================
reg    flip_flop;

//==================================
//           ASSIGNMENTS
//==================================
// Logic of switch polarity with value of CPOL bit of SPICR register 
assign sample_clk = (spicr[1] == 1'b0) ? (!flip_flop & baud_clk) : (flip_flop & !baud_clk); 
assign shift_clk  = (spicr[1] == 1'b0) ? (flip_flop & !baud_clk) : (!flip_flop & baud_clk);

// Pulse generator based on edge detection scheme for sample_clk & shift_clk
always @ (negedge resetn or posedge clk)
begin
	if (!resetn)
		flip_flop	<= 0;
	else if (!fsm_rstn)
		flip_flop   <= 0;
	else
		flip_flop	<= baud_clk;
end
endmodule