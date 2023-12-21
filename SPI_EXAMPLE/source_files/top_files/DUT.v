module DUT (
	reset,
	clk,
	miso,
	mosi,
	sck,
	cs_,
	first_byte,
	second_byte,
	third_byte,
	forth_byte
);
input		reset;	// System reset
input		clk;		// system clock
input		miso;		// Spi master input slave output
output	mosi;		// Spi master output slave input
output	sck;		// Spi clock
output	cs_;		// Spi chip select
output [7:0] first_byte;
output [7:0] second_byte;
output [7:0] third_byte;
output [7:0] forth_byte;
//
//---------------------------------//

//##### Wire's, reg's etc #####
//---------------------------//
// SPI core
reg [1:0]	spibr;
reg [2:0]	spicr;
reg [7:0]	data_to_spi;
wire [7:0]	data_from_spi;

reg			write_to_spi;
reg			read_from_spi;
// Control and storage
reg [7:0]	first_byte;
reg [7:0]	second_byte;
reg [7:0]	third_byte;
reg [7:0]	forth_byte;

wire			ready_to_read;
wire			out_pll;
//---------------------------------//

// State machine
reg		[3:0]	state;
parameter		idle					= 0;
parameter		write_first_byte	= 1;
parameter		write_second_byte	= 2;
parameter		waiting_data		= 3;
parameter		read_first_byte	= 4;
parameter		waiting_data_two	= 5;
parameter		read_second_byte	= 6;
parameter		end_state			= 7;

parameter		write_third_byte	= 8;
parameter		write_forth_byte	= 9;

parameter		waiting_data_three = 10;
parameter		read_third_byte	= 11;
parameter		waiting_data_four	= 12;
parameter		read_fourth_byte	= 13;

//
// Reg's for reset synchronizing external reset from input port
reg				reset_sync1;
reg				reset_sync2;
//---------------------------------//

//##### Assignments #####

//---------------------------------//

//	Logic for synchronize of external reset //
//-----------------------------------------//
always @ (posedge clk)
begin
	if (clk)
	begin
		reset_sync1	<= reset;
		reset_sync2	<= reset_sync1;
	end
	else
	begin
		reset_sync1	<= reset_sync1;
		reset_sync2	<= reset_sync2;
	end
end
//---------------------------------//

//##### Control state machine #####
always @ (posedge clk or negedge reset_sync2)
begin
	if (!reset_sync2)
		state	<= idle;
	else
		case (state)
		//	Idle state
		idle: begin
			spibr [1:0]			<= 2'b00;
			spicr	[2:0]			<= 3'b000;
			data_to_spi [7:0]	<= 8'b10011111;
			
			write_to_spi		<= 0;
			read_from_spi		<= 0;
			
			first_byte			<= 0;
			second_byte			<= 0;
			third_byte			<= 0;
			forth_byte			<= 0;
			
			state					<= write_first_byte;
		end
		// Write first byte state
		write_first_byte: begin
			write_to_spi		<= 1;
			
			state					<= write_second_byte;
		end
		// Write second byte state
		write_second_byte: begin
			data_to_spi	[7:0]	<= 8'b01110110;		
			write_to_spi		<= 1;
			
			state					<= write_third_byte;
		end
		// Write third byte state
		write_third_byte: begin
			data_to_spi	[7:0]	<= 8'b11110010;		
			write_to_spi		<= 1;

			state					<= write_forth_byte;
		end
		// Write forth byte state
		write_forth_byte: begin
			data_to_spi	[7:0]	<= 8'b01110011;		
			write_to_spi		<= 1;

			state					<= waiting_data;
		end		
		// Waiting data byte state
		waiting_data: begin
			write_to_spi		<= 0;
			
			if (ready_to_read)
			begin
				read_from_spi	<= 1;
				state				<= read_first_byte;
			end
			else
				state				<= state;
		end
		// Read first byte state 
		read_first_byte: begin
			read_from_spi		<= 0;			
			state					<= waiting_data_two;
		end
		// Waiting second data byte state
		waiting_data_two: begin
			first_byte [7:0]	<= data_from_spi [7:0];
		
			if (ready_to_read)
			begin
				read_from_spi	<= 1;
				state				<= read_second_byte;
			end
			else
				state				<= state;
		end
		// Read second byte state
		read_second_byte: begin
			read_from_spi		<= 0;
			state					<= waiting_data_three;
		end
		// Waiting_data_three byte state
		waiting_data_three: begin
			second_byte [7:0]	<= data_from_spi [7:0];
			
			if (ready_to_read)
			begin
				read_from_spi	<= 1;
				state				<= read_third_byte;
			end
			else
				state				<= state;			
		end
		// Read third byte state
		read_third_byte: begin
			read_from_spi		<= 0;
			state					<= waiting_data_four;
		end
		// Waiting_data_four byte state
		waiting_data_four: begin
			third_byte [7:0] <= data_from_spi [7:0];
			
			if (ready_to_read)
			begin
				read_from_spi	<= 1;
				state				<= read_fourth_byte;
			end
			else
				state				<= state;			
		end
		// Read forth byte state
		read_fourth_byte: begin
			read_from_spi		<= 0;			
			state					<= end_state;
		end
		// End state
		end_state: begin
			forth_byte [7:0]	<= data_from_spi [7:0];
			state					<= state;
		end
		endcase
end

//---------------------------------//
// Instatiations
SPI spi_core_under_test (   
	.clk(clk),
	.cs_(cs_),
	.cs_sel(  ),
	.data_in(data_to_spi),
	.data_out(data_from_spi),
	.miso(miso),
	.mosi(mosi),
	.read_byte(read_from_spi),
	.ready_to_read(ready_to_read),
	.reset(reset_sync2),
	.sck(sck),
	.spibr(spibr),
	.spicr(spicr),
	.spisr(  ),
	.wr_settings(  ),
	.write_byte(write_to_spi)
);
//
endmodule 