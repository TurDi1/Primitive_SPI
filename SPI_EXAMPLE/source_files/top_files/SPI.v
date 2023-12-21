module SPI (
	reset,
	clk,
	wr_settings,
	spibr,
	spisr,
	spicr,
	data_in,
	data_out,
	read_byte,
	ready_to_read,
	write_byte,
	miso,
	mosi,
	sck,
	cs_sel,
	cs_
);
// Port assignments
input 			reset;			// System reset
input 			clk;				// System clock
input				wr_settings;	// Write settings signal (BAUD_RATE, POLARITY, PHASE) 
input	[1:0]		spibr;			// Baud rate selector bus
output[2:0]		spisr;			// SPI Status Register
input [2:0]		spicr;			// SPI control register
input [7:0]		data_in;			// Bus with data for transmit
output[7:0]		data_out;		// Bus with data that received
input				read_byte;		// Request input for read received byte
output			ready_to_read;	// Ready to read flag output from RX FIFO 
input 			write_byte;		// Request input for write byte to transmit
input				miso;				// Master input Slave output 
output			mosi;				// Master output Slave input
output			sck;				// Interface clock output
input  [0:0]	cs_sel;			// Chip selector input (with capability for upgrading this IP)
output [1:0]	cs_;				// Chip select output bus

//----------------------------------//
// FIFO internal signals
wire				empty_tx;				// 
wire				empty_rx;				// 
wire				read_from_tx;			// 
wire				write_to_rx;			// 
wire	[7:0]		fifo_tx_data_in;		// Length of bus more than 8 bits. Correct this section
wire	[7:0]		data_out_fifo_rx;		// 
wire	[7:0]		usedw_rx;				// Bus of amount data bytes storage in RX fifo
//----------------------------------// 
// reg's for SPICR
// bit 2 - end of pack bit for receiver, bit 1 - CPOL, bit 0 - CPHA
reg	[2:0]		SPICR;					// Internal reg for storing polarity, phase mode settings and flag of end packed for receiver
//----------------------------------// 
// Baud generator reg's and wire's
reg	[1:0]		SPI_BAUD_REGISTER;	// Internal reg for storing baud_rate settings 
wire				baud_rate;				// Internal wire with baud_rate clock
wire				baud_clock_en;			// 
//----------------------------------// 
// Phase and polarity reg's and wire's 
wire				sample_clk;				// 
wire				shift_clk;				// 
wire				fsm_rst;					// Reset signal from control module to baud benerator
//----------------------------------// 

// Assignments
//----------------------------------//
assign ready_to_read = ~empty_rx;

//-----------------------------------------//
// Logic for storing settings of IP//
always @ (posedge clk or negedge reset)
begin
	if (!reset)
		SPI_BAUD_REGISTER	[1:0]	<= 2'b00;
	else if (clk)
		SPI_BAUD_REGISTER [1:0]	<= spibr [1:0];
	else
		SPI_BAUD_REGISTER	[1:0]	<= SPI_BAUD_REGISTER	[1:0];
end
//-----------------------------------------//
always @ (posedge clk or negedge reset)
begin
	if (!reset)
		SPICR	[2:0]	<= 3'b000;
	else if (clk)
		SPICR	[2:0]	<= spicr [2:0];
	else
		SPICR	[2:0]	<= SPICR	[2:0];
end
//-----------------------------------------//
// Instatiations
BAUD_RATE_GENERATOR	BAUD_RATE(
	.reset		( reset ),
	.fsm_rst		( fsm_rst ),
	.clk			( clk ),
	.clk_en		( baud_clock_en ),
	.spibr		( SPI_BAUD_REGISTER ),
	.baud_rate	( baud_rate )
);
//
FIFO_TX	FIFO_TX (
	.clock		( clk ),
	.data			( data_in ),
	.rdreq		( read_from_tx ),
	.sclr			( !reset ), //?
	.wrreq		( write_byte ),
	.empty		( empty_tx ),
	.full			(  ),
	.q				( fifo_tx_data_in )
);
//
FIFO_RX	FIFO_RX (
	.clock		( clk ),
	.data			( data_out_fifo_rx ),
	.rdreq		( read_byte ),
	.sclr			( !reset ), //?
	.wrreq		( write_to_rx ),
	.empty		( empty_rx ),
	.full			(  ),
	.q 			( data_out ),
	.usedw 		( usedw_rx )
);
//
PPC	Phase_and_polarity (
	.reset		( reset ),
	.clk			( clk ),
	.baud_clk	( baud_rate ),
	.spicr		( SPICR ),
	.sample_clk	( sample_clk ),
	.shift_clk	( shift_clk )
);
//
Control_and_shifter ctrl_shifter (
	.reset		( reset ),
	.fsm_rst		( fsm_rst ),
	.clk			( clk ),
	.clk_en		( baud_clock_en ),
	.shift_clk	( shift_clk ),
	.sample_clk	( sample_clk ),
	.baud_rate	( baud_rate ),
	.sck			( sck ),
	.mosi			( mosi ),
	.miso			( miso ),
	.cs_			( cs_[0] ),
	.data_tx		( fifo_tx_data_in ),
	.data_rx		( data_out_fifo_rx ),
	.read_rq		( read_from_tx ),
	.write_rq	( write_to_rx ),
	.empty_tx	( empty_tx )
);
//	
endmodule 