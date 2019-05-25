/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

module exercise1 (
		input logic CLOCK_I,
		input logic RESETN_I,
		output logic [8:0] READ_ADDRESS_O,
		output logic [8:0] WRITE_ADDRESS_O,		
		output logic [7:0] READ_DATA_A_O [1:0],
		output logic [7:0] READ_DATA_B_O [1:0],
		output logic [7:0] WRITE_DATA_A_O [1:0],
		output logic WRITE_ENABLE_A_O [1:0],
		output logic [7:0] WRITE_DATA_B_O [1:0],
		output logic WRITE_ENABLE_B_O [1:0]	
);

enum logic [1:0] {
	S_READ,
	S_WRITE,
	S_IDLE
} state;

//logic [8:0] read_address, write_address;
logic [8:0] address_a;
logic [8:0] address_b;
logic [7:0] write_data_a [1:0];
logic write_enable_a [1:0];
logic [7:0] write_data_b [1:0];
logic write_enable_b [1:0];
logic [7:0] read_data_a [1:0];
logic [7:0] read_data_b [1:0];
logic counter;

// Instantiate RAM1
dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_a ),
	.address_b ( address_b ),
	.clock ( CLOCK_I ),
	.data_a ( write_data_a[1] ), // Y[i] when i >= 256
	.data_b ( write_data_b[1] ), // Z[i] when i >= 256
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ), // W[i+256]
	.q_b ( read_data_b[1] ) // X[i+256]
	);

// Instantiate RAM0
dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( address_a ),
	.address_b ( address_b ),
	.clock ( CLOCK_I ),
	.data_a ( write_data_a[0] ), // Y[i] when i < 256
	.data_b ( write_data_b[0] ), // Z[i] when i < 256
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ), // W[i]
	.q_b ( read_data_b[0] ) // X[i]
	);

// User defined

assign address_b = address_a + 9'd256;

// Y[i]
assign write_data_a[0] = read_data_a[0] + read_data_b[1]; // Y[i] when i < 256
assign write_data_a[1] = read_data_a[1] + read_data_b[0]; // Y[i] when i >= 256

// Z[i]
assign write_data_b[0] = read_data_a[1] - read_data_b[0]; // Z[i] when i < 256
assign write_data_b[1] = read_data_a[0] - read_data_b[1]; // Z[i] when i >= 256

// FSM to control the read and write sequence
always_ff @ (posedge CLOCK_I or negedge RESETN_I) begin
	if (RESETN_I == 1'b0) begin
		address_a <= 9'h000;
		//address_b <= 9'h000;
		write_enable_a[0] <= 1'b0;
		write_enable_a[1] <= 1'b0;
		write_enable_b[0] <= 1'b0;
		write_enable_b[1] <= 1'b0;
		state <= S_READ;
	end else begin
		case (state)
			S_WRITE: begin	
				// One clock cycle for reading and writing data	
				
				address_a <= address_a + 9'd1;
				//address_b <= address_a;
				
				write_enable_a[0] <= 1'b0;
				write_enable_a[1] <= 1'b0;
				write_enable_b[0] <= 1'b0;
				write_enable_b[1] <= 1'b0;
									
				state <= S_READ;
				
			end
			S_READ: begin
				if (address_a < 9'd256) begin		
					
					write_enable_a[0] <= 1'b1;
					write_enable_a[1] <= 1'b1;
					write_enable_b[0] <= 1'b1;
					write_enable_b[1] <= 1'b1;
					
					state <= S_WRITE;
					
				end else begin
					
					write_enable_a[0] <= 1'b0;
					write_enable_a[1] <= 1'b0;
					write_enable_b[0] <= 1'b0;
					write_enable_b[1] <= 1'b0;
					
					state <= S_IDLE;
	
				end	
			end
		endcase
	end
end

assign READ_ADDRESS_O = address_a;
assign WRITE_ADDRESS_O = address_b;

assign READ_DATA_A_O = read_data_a;
assign READ_DATA_B_O = read_data_b;

assign WRITE_ENABLE_A_O = write_enable_a;
assign WRITE_ENABLE_B_O = write_enable_b;

assign WRITE_DATA_A_O = write_data_a;
assign WRITE_DATA_B_O = write_data_b;

endmodule
