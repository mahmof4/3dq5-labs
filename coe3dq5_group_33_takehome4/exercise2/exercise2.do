onbreak {resume}

transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

# load designs
vlog -sv -svinputport=var -work rtl_work SRAM_BIST.v
vlog -sv -svinputport=var -work rtl_work +define+SIMULATION SRAM_Controller.v
vlog -sv -svinputport=var -work rtl_work tb_SRAM_Emulator.v
vlog -sv -svinputport=var -work rtl_work exercise2.v
vlog -sv -svinputport=var -work rtl_work tb_exercise2.v

# specify library for simulation
vsim -t 100ps -L altera_mf_ver -lib rtl_work tb_exercise2

# Clear previous simulation
restart -f

# activate waveform simulation
view wave

# add signals to waveform
add wave Clock_50
# add wave Switches
# add wave LED_Green

add wave uut/BIST_unit/BIST_state
add wave -unsigned uut/BIST_unit/BIST_address
add wave -hex uut/BIST_unit/BIST_write_data
add wave -hex uut/BIST_unit/BIST_we_n
add wave -hex uut/BIST_unit/BIST_read_data
add wave uut/BIST_unit/BIST_finish
add wave uut/BIST_unit/BIST_mismatch

# add wave -unsigned uut/SRAM_unit/SRAM_ADDRESS_O
# add wave -hex uut/SRAM_unit/SRAM_write_data_buf
# add wave -hex uut/SRAM_unit/SRAM_read_data
# add wave -hex uut/SRAM_unit/SRAM_DATA_IO
# add wave uut/SRAM_unit/SRAM_WE_N_O

# format signal names in waveform
configure wave -signalnamewidth 1

# run complete simulation
run -all

# save the SRAM content for inspection
mem save -o SRAM.mem -f mti -data hex -addr hex -startaddress 0 -endaddress 262143 -wordsperline 8 /tb_exercise2/SRAM_component/SRAM_data

simstats
