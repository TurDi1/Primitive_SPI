module BAUD_RATE_GENERATOR (
	resetn,
	fsm_rstn,
	clk,
	clk_en,
	spibr,
	baud_rate
);
//==================================
//             PORTS
//==================================
input               resetn;     // System reset input
input               fsm_rstn;   // External reset input from FSM of control module
input               clk;        // System clock input
input               clk_en;     // Enable clock input
input   [1:0]       spibr;      // Baud rate selector input bus: 00 - clk/2, 01 - clk/4, 10 - clk/8, 11 - clk/16
output              baud_rate;  // Baud rate clock output

//==================================
//      WIRE'S, REG'S AND ETC 
//==================================
reg    [3:0]        counter;

//==================================
//           ASSIGNMENTS
//==================================
// Baud rate selector
assign baud_rate = counter[spibr];

// Counter logic
always @ (posedge clk or negedge resetn)
begin
	if (!resetn)
		counter	<= 0;
	else if (!fsm_rstn)
		counter	<= 0;
	else if (clk_en)
		counter	<= counter + 1;
end
endmodule 