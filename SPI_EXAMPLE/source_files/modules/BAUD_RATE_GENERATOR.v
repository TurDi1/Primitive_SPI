module BAUD_RATE_GENERATOR (
	reset,
	fsm_rst,
	clk,
	clk_en,
	spibr,
	baud_rate
);
// Port assignments
input 			reset;		// reset input
input				fsm_rst;		// reset from control state machine from control module
input				clk;			//	system clk
input				clk_en;		// enable input
input	[1:0]	 	spibr;		// input bus of selection baud rate
output 			baud_rate;	// baud rate clock output
//######################

// Wire's, regs and etc.
reg [3:0]	counter;	
reg			baud;

assign	baud_rate = baud;
//##############################
// Baud rate selector comb block
always @ (spibr, counter)
begin
	case (spibr)
		2'b00:	baud <= counter[0];	// /2 	---> 25 MHz
		2'b01:	baud <= counter[1];	// /4 	---> 12.5 MHz
		2'b10:	baud <= counter[2];	// /8		---> 6.25 MHz
		2'b11:	baud <= counter[3];	// /16 	---> 3.125 MHz
	endcase	
end
//##############
// Counter logic
always @ (posedge clk or negedge reset or negedge fsm_rst)
begin
	if (!reset || !fsm_rst)
		counter	<= 0;
	else if (clk_en)
		counter	<= counter + 1;
	else
		counter	<= counter;
end
//
endmodule 