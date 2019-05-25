onbreak {resume}

transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

# load designs
vlog -sv -svinputport=var -work rtl_work dual_port_RAM0.v
vlog -sv -svinputport=var -work rtl_work dual_port_RAM1.v
vlog -sv -svinputport=var -work rtl_work exercise1.v
vlog -sv -svinputport=var -work rtl_work tb_exercise1.v

# specify library for simulation
vsim -t 1ps -L altera_mf_ver -lib rtl_work tb_exercise1

# Clear previous simulation
restart -f

# activate waveform simulation
view wave

# add waves to waveform
add wave Clock_50
add wave Resetn
add wave -unsigned Read_address_a
add wave -unsigned Read_address_b
add wave -decimal Read_data_A
add wave -decimal Write_data_A
add wave -decimal Read_data_B
add wave -decimal Write_data_B
add wave Write_enable_A
add wave Write_enable_B

# format signal names in waveform
configure wave -signalnamewidth 1

# run complete simulation
run -all

mem save -o simulation_RAM0.mem -f mti -data decimal -addr hex -wordsperline 8 /tb_exercise1/uut/dual_port_RAM_inst0/altsyncram_component/mem_data
mem save -o simulation_RAM1.mem -f mti -data decimal -addr hex -wordsperline 8 /tb_exercise1/uut/dual_port_RAM_inst1/altsyncram_component/mem_data

simstats
