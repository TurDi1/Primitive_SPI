// Phase and Polarity control (template for future upgrade)
module PPC (
	reset,
	clk,
	baud_clk,
	spicr,
	sample_clk,
	shift_clk
);
input			reset;			// system reset
input			clk;				// system clk
input 		baud_clk;		// input clk from baud generator
input [2:0]	spicr;			// input with PPC settings
output		sample_clk;		// output sample clk for latch logic
output		shift_clk;		// output shift clk for shift register

// Reg's, wire's and etc
reg flip_flop;

// Assignments
//############
// Logic of switch polarity with value of CPOL bit of SPICR register 
assign sample_clk = (spicr[1] == 1'b0) ? (!flip_flop & baud_clk) : (flip_flop & !baud_clk); 
assign shift_clk	= (spicr[1] == 1'b0) ? (flip_flop & !baud_clk) : (!flip_flop & baud_clk);

// Pulse generator based on edge detection scheme for sample_clk & shift_clk
always @ (negedge reset or posedge clk)
begin
	if (!reset)
		flip_flop	<= 0;
	else
		flip_flop	<= baud_clk;
end
//
endmodule 