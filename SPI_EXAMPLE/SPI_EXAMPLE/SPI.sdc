## Generated SDC file "SPI.out.sdc"

## Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.0.0 Build 211 04/27/2016 SJ Standard Edition"

## DATE    "Tue Nov 16 01:22:27 2021"

##
## DEVICE  "EP4CE6E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk} -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -divide_by 2 	-source [get_ports {clk}] -name clkdivtwo [get_pins {SPI:spi_core_under_test|BAUD_RATE_GENERATOR:BAUD_RATE|counter[0]|q}]
#create_generated_clock -divide_by 4 	-source [get_ports {clk}] -name clkdivfour [get_pins {SPI:spi_core_under_test|BAUD_RATE_GENERATOR:BAUD_RATE|counter[1]|q}]
#create_generated_clock -divide_by 8 	-source [get_ports {clk}] -name clkdiveight [get_pins {SPI:spi_core_under_test|BAUD_RATE_GENERATOR:BAUD_RATE|counter[2]|q}]
#create_generated_clock -divide_by 16 	-source [get_ports {clk}] -name clkdivsixteen [get_pins {SPI:spi_core_under_test|BAUD_RATE_GENERATOR:BAUD_RATE|counter[3]|q}]

create_generated_clock -source [get_ports {clk}] -name load_shifter [get_pins {SPI:spi_core_under_test|Control_and_shifter:ctrl_shifter|load_to_shifter|q}]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

