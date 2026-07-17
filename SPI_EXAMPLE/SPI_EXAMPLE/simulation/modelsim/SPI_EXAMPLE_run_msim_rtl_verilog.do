transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/top_files {D:/Primitive_SPI/SPI_EXAMPLE/source_files/top_files/DUT.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/top_files {D:/Primitive_SPI/SPI_EXAMPLE/source_files/top_files/SPI.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules {D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules/PPC.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules {D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules/Control_and_shifter.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules {D:/Primitive_SPI/SPI_EXAMPLE/source_files/modules/BAUD_RATE_GENERATOR.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/ip/FIFO/TX {D:/Primitive_SPI/SPI_EXAMPLE/source_files/ip/FIFO/TX/FIFO_TX.v}
vlog -vlog01compat -work work +incdir+D:/Primitive_SPI/SPI_EXAMPLE/source_files/ip/FIFO/RX {D:/Primitive_SPI/SPI_EXAMPLE/source_files/ip/FIFO/RX/FIFO_RX.v}

