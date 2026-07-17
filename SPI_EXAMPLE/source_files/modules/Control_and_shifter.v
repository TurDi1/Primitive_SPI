module Control_and_shifter (
    resetn,
    fsm_rstn,
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
//==================================
//             PARAMETERS
//==================================
parameter IDLE          = 0;
parameter PREHOLD       = 1;
parameter WR_TO_SHIFTER = 2;
parameter FIFO_TX_CHKR  = 3;
parameter SHIFTER_BUSY  = 4;
parameter WR_FIFO_RX    = 5;
parameter POSTHOLD      = 6;

//==================================
//             PORTS
//==================================
input             resetn;      // system reset
output            fsm_rstn;    // Finite state machine reset output for other modules
input             clk;         // system clk
output            clk_en;      // enable signal to PPC module
input             shift_clk;   // clk from PPC module for shift register
input             sample_clk;  // clk from PPC module for latching on miso and mosi
input             baud_rate;   // 
output            sck;         // master clock output
output            mosi;        // master output slave input
input             miso;        // master input slave output
output            cs_;         // chip select port
input    [7:0]    data_tx;     // data bus from FIFO TX
output   [7:0]    data_rx;     // data bus to FIFO RX
output            read_rq;     // read request to FIFO TX
output            write_rq;    // write request to FIFO RX
input             empty_tx;    // empty signal from FIFO TX

//==================================
//      WIRE'S, REG'S AND ETC 
//==================================
reg               fsm_resetn;               // Stupid reset for baud gen module because i'm not really qualified...
reg               miso_reg;                 // miso reg for storage value

reg    [7:0]      shift_register;
reg    [3:0]      shifter_counter;          // counter of shifted bit's in shifter

reg    [7:0]      data_buffer;              // buffer for storage received byte before write it to FIFO RX
reg    [1:0]      hold_counter;             // Hold counter for Minimum leading time before the first SCK edge
                                            // and Minimum trailing time after the last SCK edge

reg               enable;                   // Enable reg for shift register, shift counter and latch logic
reg               hold_enable;              // Enable reg for hold counter
reg               load_to_holder;           // Reg with value of flag for hold counter load logic 
reg               fifo_read_requst;         // FIFO TX read request flag
reg               fifo_write_request;       // FIFO RX write request flag
reg               chip_select;              // CS reg for storage value

reg               load_to_shifter;          // Reg with value of flag for shift register load logic

reg               baud_clock_enable;        // Enable reg for baud gen module
// wire              sample_clock;                
// wire              shift_clock;                

reg               tx_data_ready_to_load;    // Reg with flag that next data fro shift register are ready

// State machine
reg    [2:0]      state;

//==================================
//           ASSIGNMENTS
//==================================
assign fsm_rstn     = fsm_resetn;

assign clk_en       = baud_clock_enable;
//assign shift_clock  = enable & shift_clk;
//assign sample_clock = enable & sample_clk;
assign sck          = enable & baud_rate;

assign mosi         = shift_register[7];
assign read_rq      = fifo_read_requst;
assign write_rq     = fifo_write_request;
assign cs_          = chip_select;

assign data_rx[7:0] = data_buffer[7:0];

//==================================
//          LOGIC SECTION
//==================================
// Latch logic instantiation
always @ (posedge clk or negedge resetn)
begin
    if (!resetn)
        miso_reg    <= 0;
    else if (sample_clk)
        miso_reg    <= miso;
end

//=========================================
// Shift register logic
always @ (posedge clk or negedge resetn)
begin
    if (!resetn)
        shift_register <= 0;
	else if (load_to_shifter)
        shift_register[7:0] <= data_tx[7:0];
	else if (enable)
	begin
		if (shift_clk)
        	shift_register[7:0] <= {shift_register[6:0], miso_reg};
	end
end

// Counter logic for shift register
always @ (posedge clk or negedge resetn)
begin
	if (!resetn)
		shifter_counter <= 0;
	else if (load_to_shifter)
		shifter_counter <= 0;
	else if (enable)
	begin
		if (shift_clk)
			shifter_counter <= shifter_counter + 1;
	end
end

// Hold counter logic for prehold and posthold states of FSM
always @ (posedge clk or negedge resetn)
begin
	if (!resetn)
		hold_counter <= 0;
	else if (load_to_holder)
		hold_counter <= 0;
	else if (hold_enable)
	begin
		if (hold_counter != 2'b10)
			hold_counter <= hold_counter + 1; 
	end
end

//========================================
// Control state machine
always @ (posedge clk or negedge resetn)
begin
	if (!resetn)
	begin
		fsm_resetn            <= 1;
		load_to_holder        <= 0;
		enable                <= 0;
		baud_clock_enable     <= 0;
		hold_enable           <= 0;
		fifo_read_requst      <= 0;
		fifo_write_request    <= 0;
		chip_select           <= 1;
		load_to_shifter       <= 0;
		tx_data_ready_to_load <= 0;
		data_buffer           <= 0;
		state                 <= IDLE;
	end
	else
		case (state)
			IDLE:
			begin
				fsm_resetn            <= 1;
				load_to_holder        <= 0;
				enable                <= 0;
				baud_clock_enable     <= 0;
				hold_enable           <= 0;
				
				fifo_read_requst      <= 0;
				fifo_write_request    <= 0;
				chip_select           <= 1;
				
				load_to_shifter       <= 0;
				
				tx_data_ready_to_load <= 0;
				
				data_buffer           <= 0;
				
				if (!empty_tx)
				begin
					load_to_holder   <= 1;
					fifo_read_requst <= 1;
					state            <= PREHOLD;
				end
				else
					state <= IDLE;
			end
			PREHOLD: // State for launch "holder"
			begin
				load_to_holder    <= 0;
				hold_enable       <= 1;
				baud_clock_enable <= 1;
				
				fifo_read_requst  <= 0;
				chip_select       <= 0;
				
				if (hold_counter == 2'b10)
					state <= WR_TO_SHIFTER;
				else
					state <= PREHOLD;
			end
			WR_TO_SHIFTER: // State for load data to shifter
			begin
				fsm_resetn         <= 0;
				hold_enable        <= 0;
				enable             <= 0;
				load_to_shifter    <= 1;
				
				fifo_write_request <= 0;
				
				state <= FIFO_TX_CHKR;
			end
			FIFO_TX_CHKR: // FIFO TX check state
			begin
				fsm_resetn      <= 1;
				enable          <= 1;
				load_to_holder  <= 0;
				load_to_shifter <= 0;
				if (!empty_tx)
				begin
					fifo_read_requst      <= 1;
					tx_data_ready_to_load <= 1;
					state <= SHIFTER_BUSY;
				end
				else
				begin
					fifo_read_requst      <= 0;
					tx_data_ready_to_load <= 0;
					state <= SHIFTER_BUSY;
				end
			end
			SHIFTER_BUSY: // Shifter busy state
			begin
				fifo_read_requst <= 0;
				
				if (shifter_counter == 8)
				begin
					data_buffer[7:0] <= shift_register[7:0];
					enable           <= 0;
					state            <= WR_FIFO_RX;
				end
				else
				begin
					state <= SHIFTER_BUSY;
				end
			end
			WR_FIFO_RX: // Write data byte from slave state
			begin
				fifo_write_request <= 1;
				
				if (tx_data_ready_to_load)
					state <= WR_TO_SHIFTER;
				else
				begin
					load_to_holder <= 1;
					hold_enable    <= 1;
					state          <= POSTHOLD;
				end
			end
			POSTHOLD: // State for launch posthold
			begin
				enable             <= 0;
				fifo_write_request <= 0;
				load_to_holder     <= 0;
				
				if (hold_counter == 2'b10)
				begin
					chip_select <= 1;
					fsm_resetn  <= 0;
					state       <= IDLE;
				end
				else
				begin
					chip_select <= 0;
					state       <= POSTHOLD;
				end
			end
		endcase
end
endmodule 