module Control_and_shifter (
	reset,
	fsm_rst,
	clk,
	clk_en,
	shift_clk,
	sample_clk,
	baud_rate,
	sck,
	mosi,
	miso,
	cs_,
	data_tx,
	data_rx,
	read_rq,
	write_rq,
	empty_tx
);
//##### Port assignments #####
input          reset;		// system reset
output			fsm_rst;		// Finite state machine reset output for other modules
input          clk;			// system clk
output			clk_en;		// enable signal to PPC module
input          shift_clk;	// clk from PPC module for shift register
input          sample_clk;	// clk from PPC module for latching on miso and mosi
input				baud_rate;	// 
output			sck;			// master clock output
output         mosi;			// master output slave input
input          miso;			// master input slave output
output 			cs_;			// chip select port
input		[7:0]	data_tx;		// data bus from FIFO TX
output	[7:0]	data_rx;		// data bus to FIFO RX
output			read_rq;		// read request to FIFO TX
output			write_rq;	// write request to FIFO RX
input				empty_tx;	// empty signal from FIFO TX

//##### Wire's, reg's etc #####
//---------------------------//
reg				fsm_reset;					// Stupid reset for baud gen module because i'm not really qualified...
reg 				mosi_reg;					// mosi reg for storage value 
reg 				miso_reg;					// miso reg for storage value

reg		[7:0]	shift_register;
reg		[3:0] shifter_counter;			// counter of shifted bit's in shifter

reg		[7:0]	data_buffer;				// buffer for storage received byte before write it to FIFO RX
reg		[1:0]	hold_counter;				// Hold counter for Minimum leading time before the first SCK edge
													// and Minimum trailing time after the last SCK edge

reg				enable;						// Enable reg for shift register, shift counter and latch logic
reg				hold_enable;				// Enable reg for hold counter
reg				load_to_holder;			// Reg with value of flag for hold counter load logic 
reg				fifo_read_requst;			// FIFO TX read request flag
reg				fifo_write_request;		// FIFO RX write request flag
reg				chip_select;				// CS reg for storage value

reg				load_to_shifter;			//	Reg with value of flag for shift register load logic 

reg				baud_clock_enable;		// Enable reg for baud gen module 
wire				sample_clock;				 
wire				shift_clock;				 

reg				tx_data_ready_to_load; 	// Reg with flag that next data fro shift register are ready
//---------------------------------//

// State machine
reg		[2:0]	state;
parameter		idle					= 0;
parameter		prehold				= 1;
parameter		write_to_shifter	= 2;
parameter		fifo_tx_checker	= 3;
parameter		shifter_busy		= 4;
parameter		write_fifo_rx		= 5;
parameter		posthold				= 6;
//---------------------------------//

//---------------------------------//

//##### Assignments #####
assign clk_en = baud_clock_enable;
assign shift_clock = enable & shift_clk;
assign sample_clock = enable & sample_clk;
assign sck = enable & baud_rate;
//
assign mosi			= shift_register[7];
assign read_rq 	= fifo_read_requst;
assign write_rq 	= fifo_write_request;
assign cs_ 			= chip_select;
assign fsm_rst		= fsm_reset;
//
assign data_rx[7:0]	= data_buffer[7:0];
//---------------------------------//

//##### Latch logic instantiation #####
always @ (posedge sample_clock or negedge reset)
begin
	if (!reset)
		mosi_reg	<= 0;
	else
		mosi_reg	<= shift_register[7];
end
//---------------------------------//
always @ (posedge sample_clock or negedge reset)
begin
	if (!reset)
		miso_reg	<= 0;
	else
		miso_reg	<= miso;
end
//---------------------------------//

//##### Control state machine #####
always @ (posedge clk or negedge reset)
begin
	if (!reset)
	begin
		state <= idle;
	end
	else
		case (state)
		//---- Idle state
		idle: begin
			fsm_reset				<= 1;
			load_to_holder			<= 0;
			enable 					<= 0;
			baud_clock_enable		<= 0;
			hold_enable				<= 0;
			//
			fifo_read_requst		<= 0;
			fifo_write_request	<= 0;
			chip_select				<= 1;
			//
			load_to_shifter		<= 0;
			//
			tx_data_ready_to_load<= 0;
			//
			data_buffer				<= 0;
			
			if (!empty_tx)
			begin
				load_to_holder		<= 1;
				fifo_read_requst	<= 1;
				state	<= prehold;
			end
			else
				state	<= idle;
		end
		//---- State for launch "holder"
		prehold: begin
			load_to_holder			<= 0;
			hold_enable				<= 1;
			baud_clock_enable		<= 1;
			//
			fifo_read_requst		<= 0;
			chip_select				<= 0;
			//
			if (hold_counter == 2'b10)
				state					<= write_to_shifter;
			else
				state					<= prehold;
		end
		//---- State for load data to shifter
		write_to_shifter: begin
				fsm_reset			<= 0;
				hold_enable			<= 0;
				enable				<= 0;
				load_to_shifter	<= 1;
				
				fifo_write_request<= 0;
				
				state					<= fifo_tx_checker;
		end
		//---- FIFO TX check state
		fifo_tx_checker: begin
			fsm_reset				<= 1;
			enable					<= 1;
			load_to_holder			<= 0;
			load_to_shifter		<= 0;
			if (!empty_tx)
			begin
				fifo_read_requst			<= 1;
				tx_data_ready_to_load	<= 1;
				state							<= shifter_busy;
			end
			else
			begin
				fifo_read_requst			<= 0;
				tx_data_ready_to_load	<= 0;
				state							<= shifter_busy;
			end
		end
		//---- Shifter busy state
		shifter_busy: begin
			fifo_read_requst		<= 0;
			
			if (shifter_counter == 8)
			begin
				data_buffer[7:0]	<= shift_register[7:0];
				enable				<= 0;
				state					<= write_fifo_rx;
			end
			else
			begin
				state					<= shifter_busy;
			end
		end
		//---- write data byte from slave state
		write_fifo_rx: begin
			fifo_write_request	<= 1;
			
			if (tx_data_ready_to_load)
				state					<= write_to_shifter;
			else
			begin
				load_to_holder		<= 1;
				hold_enable			<= 1;
				state					<= posthold;
			end
		end
		//---- State for launch posthold
		posthold: begin
			enable					<= 0;
			fifo_write_request	<= 0;
			load_to_holder			<= 0;
			
			if (hold_counter == 2'b10)
			begin
				chip_select		<= 1;
				fsm_reset		<= 0;
				state				<= idle;
			end
			else
			begin
				chip_select		<= 0;
				state				<= posthold;
			end
		end
		endcase
end

//---------------------------------//
//##### Shift register logic #####
always @ (posedge shift_clock or negedge reset or posedge load_to_shifter)
begin
	if (!reset)
		shift_register	<= 0;
	else if (load_to_shifter)
		shift_register[7:0] <= data_tx[7:0];
	else if (enable)
	begin
		if (shift_clock)
			shift_register[7:0] <= {shift_register[6:0], miso_reg};
	end
	else
		shift_register <= shift_register;		
end

//---------------------------------//
//##### Shift register counter logic #####
always @ (posedge shift_clock or negedge reset or posedge load_to_shifter)
begin
	if (!reset)
		shifter_counter	<= 0;
	else if (load_to_shifter)
		shifter_counter	<= 0;
	else if (enable)
	begin
		if (shift_clock)
			shifter_counter	<= shifter_counter + 1;	
	end
	else
		shifter_counter	<= shifter_counter;
end

//---------------------------------//
//##### Hold counter logic for prehold and posthold
always @ (posedge sample_clk or negedge reset or posedge load_to_holder)
begin
	if (!reset)
		hold_counter	<= 0;
	else if (load_to_holder)
		hold_counter	<= 0;
	else if (hold_enable)
	begin
		if (hold_counter != 2'b10)
			hold_counter	<= hold_counter + 1;	
	end
	else
		hold_counter	<= hold_counter;
end
//---------------------------------//
//
endmodule 