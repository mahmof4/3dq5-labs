/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ5)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

// This module contains the BIST engine for the SRAM
module SRAM_BIST (
	input logic Clock,
	input logic Resetn,
	input logic BIST_start,
	
	output logic [17:0] BIST_address,
	output logic [15:0] BIST_write_data,
	output logic BIST_we_n,
	input logic [15:0] BIST_read_data,
	
	output logic BIST_finish,
	output logic BIST_mismatch
);

BIST_state_type BIST_state;

// The BIST engine
always_ff @ (posedge Clock or negedge Resetn) begin
	if (Resetn == 1'b0) begin
		BIST_state <= S_IDLE;
		BIST_mismatch <= 1'b0;
		BIST_finish <= 1'b0;
		BIST_address <= 18'd0;
		BIST_write_data <= 16'd0;
		BIST_we_n <= 1'b1;
	end else begin		
		case (BIST_state)
		S_IDLE: begin
			if (BIST_start) begin
				// Start the BIST engine
				BIST_address <= 18'd0;
				BIST_write_data <= 16'd0;
				BIST_we_n <= 1'b0;
				BIST_mismatch <= 1'b0;
				
				BIST_finish <= 1'b0;
				
				BIST_state <= S_START;
			end else begin
				BIST_address <= 18'd0;
				BIST_write_data <= 16'd0;
				BIST_we_n <= 1'b1;
				BIST_finish <= 1'b1;				
			end
		end
		
		S_START: begin
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT0;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT1;
			
			BIST_state <= S_WRITE_CYCLE;
			
		end
		
		S_WRITE_CYCLE: begin
			// SRAM is writing in this clock cycle
			
			if (BIST_address == 18'h3FFFF) begin
			
				BIST_we_n <= 1'b1;
				
				BIST_state <= S_DELAY_1;
				
			end else begin
			
				BIST_address <= BIST_address + 18'd1;
				
				if (BIST_address[0] == 0) 
					BIST_write_data <= PAT1;
				else if (BIST_address[0] == 1) BIST_write_data <= PAT0;
			
			end
		end
		
		S_DELAY_1: begin
			BIST_address <= BIST_address - 18'd1;
			
			BIST_state <= S_DELAY_2;
		end
		
		S_DELAY_2: begin
			BIST_address <= BIST_address - 18'd1;
			
			BIST_state <= S_READ_CYCLE;		
		end
		
		S_READ_CYCLE: begin
			// SRAM is reading in this clock cycle
			
			// Check for data mismatch
			if (BIST_write_data != BIST_read_data) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT1;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT0;
			
			if (BIST_address > 18'd0) begin
			
				BIST_address <= BIST_address - 18'd1;					
			
			end else begin
				// Go to delay state to check the last two data
				BIST_state <= S_DELAY_3;
				
			end								
		end
		
		S_DELAY_3: begin
			// Check for data mismatch
			if (BIST_write_data != BIST_read_data) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT1;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT0;
			
			BIST_state <= S_DELAY_4;
		end
		
		S_DELAY_4: begin
			// Check for data mismatch
			if (BIST_read_data != PAT0) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT1;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT0;
			
			if (BIST_address == 1'b0) begin
				// Finish the whole SRAM
				
				if (BIST_address[0] == 0) 
					BIST_write_data <= PAT2;
				else if (BIST_address[0] == 1) BIST_write_data <= PAT3;
				
				BIST_state <= S_WRITE_CYCLE_2;
				BIST_address <= 18'h3FFFF;
				BIST_we_n <= 1'b0;

			end
			
		end
		
		S_WRITE_CYCLE_2: begin
			// SRAM is writing in this clock cycle
			
			if (BIST_address == 18'd0) begin
			
				BIST_we_n <= 1'b1;
				
				BIST_state <= S_DELAY_5;
				
			end else begin
			
				BIST_address <= BIST_address - 18'd1;
			
				if (BIST_address[0] == 0) 
					BIST_write_data <= PAT3;
				else if (BIST_address[0] == 1) BIST_write_data <= PAT2;
			
			end
		end
		
		S_DELAY_5: begin
			BIST_address <= BIST_address + 18'd1;
			
			BIST_state <= S_DELAY_6;
		end
		
		S_DELAY_6: begin
			BIST_address <= BIST_address + 18'd1;
			
			BIST_state <= S_READ_CYCLE_2;		
		end
		
		S_READ_CYCLE_2: begin
			// SRAM is reading in this clock cycle
			
			// Check for data mismatch
			if (BIST_write_data != BIST_read_data) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT3;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT2;
			
			if (BIST_address == 18'h3FFFF) begin
				
				BIST_state <= S_DELAY_7;			
			
			end else begin
				// Go to delay state to check the last two data
				
				BIST_address <= BIST_address + 18'd1;		
				
			end								
		end
		
		S_DELAY_7: begin
			// Check for data mismatch
			if (BIST_write_data != BIST_read_data) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT3;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT2;
			
			BIST_state <= S_DELAY_8;
		end
		
		S_DELAY_8: begin
			// Check for data mismatch
			if (BIST_write_data != PAT2) BIST_mismatch <= 1'b1;
			
			if (BIST_address[0] == 0) 
				BIST_write_data <= PAT3;
			else if (BIST_address[0] == 1) BIST_write_data <= PAT2;
			
			if (BIST_address == 18'h3FFFF) begin
				// Finish the whole SRAM
				BIST_state <= S_IDLE;
				BIST_finish <= 1'b1;
			end
			
		end
		
		default: BIST_state <= S_IDLE;
		endcase
	end
end

endmodule
