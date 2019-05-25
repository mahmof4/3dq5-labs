/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

// This is the top module
// It uses a PS2_Controller to assemble the PS2 codes (both make code and break code)
// And stores them into a 24-bit shift register, which is displayed on 7-segment display
module exercise1 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs
		output logic[17:0] LED_RED_O,             // 18 red LEDs
		
		/////// PS2                               ////////////
		input logic PS2_DATA_I,                   // PS2 data
		input logic PS2_CLOCK_I                   // PS2 clock
);

logic resetn;

logic [7:0] PS2_code;
logic PS2_code_ready;

logic [31:0] seven_segment_shift_reg;
logic PS2_code_ready_buf;
logic PS2_make_code;

logic [6:0] value_7_segment [7:0];

logic key_f, key_p, key_g, key_a;
logic light_flag;

enum logic [2:0] {
	S_IDLE,
	S_STATE_F,
	S_STATE_P,
	S_STATE_G,
	S_STATE_A
} state;

assign resetn = ~SWITCH_I[17];

assign key_f = (PS2_code == 8'h2B);
assign key_p = (PS2_code == 8'h4D);
assign key_g = (PS2_code == 8'h34);
assign key_a = (PS2_code == 8'h1C);

// PS/2 controller
PS2_controller ps2_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PS2_clock(PS2_CLOCK_I),
	.PS2_data(PS2_DATA_I),
	.PS2_code(PS2_code),
	.PS2_code_ready(PS2_code_ready),
	.PS2_make_code(PS2_make_code)
);

// Putting the PS2 code into the shift register
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		seven_segment_shift_reg <= 32'h000000;
		PS2_code_ready_buf <= 1'b0;
		light_flag <= 1'b0;
		//state <= S_IDLE;
	end else begin
		PS2_code_ready_buf <= PS2_code_ready;
		
		if ((PS2_code_ready == 1'b1) && (PS2_code_ready_buf == 1'b0) && (PS2_make_code == 1'b0) && (PS2_code != 8'hF0)) begin
			// scan code detected
			state <= S_IDLE;
			case(state)
				S_IDLE: begin
					if(key_f) state <= S_STATE_F;
				end
				
				S_STATE_F: begin
					if(key_p) state <= S_STATE_P;
				end
				
				S_STATE_P: begin
					if(key_g) state <= S_STATE_G;
				end
				
				S_STATE_G: begin
					if(key_a) 
						light_flag <= ~light_flag;
						state <= S_STATE_A;
				end
				
				S_STATE_A: begin
					if(key_f)
						state <= S_STATE_F;
				end
			endcase
			
			seven_segment_shift_reg <= {seven_segment_shift_reg[31:0], PS2_code};
			
		end

	end
end

assign LED_RED_O = {resetn, 16'd0, PS2_make_code};
assign LED_GREEN_O = {PS2_code_ready, PS2_code};


convert_hex_to_seven_segment unit7 (
	.hex_value(seven_segment_shift_reg[31:28]), 
	.converted_value(value_7_segment[7])
);

convert_hex_to_seven_segment unit6 (
	.hex_value(seven_segment_shift_reg[27:24]), 
	.converted_value(value_7_segment[6])
);

convert_hex_to_seven_segment unit5 (
	.hex_value(seven_segment_shift_reg[23:20]), 
	.converted_value(value_7_segment[5])
);

convert_hex_to_seven_segment unit4 (
	.hex_value(seven_segment_shift_reg[19:16]), 
	.converted_value(value_7_segment[4])
);

convert_hex_to_seven_segment unit3 (
	.hex_value(seven_segment_shift_reg[15:12]), 
	.converted_value(value_7_segment[3])
);

convert_hex_to_seven_segment unit2 (
	.hex_value(seven_segment_shift_reg[11:8]), 
	.converted_value(value_7_segment[2])
);

convert_hex_to_seven_segment unit1 (
	.hex_value(seven_segment_shift_reg[7:4]), 
	.converted_value(value_7_segment[1])
);

convert_hex_to_seven_segment unit0 (
	.hex_value(seven_segment_shift_reg[3:0]), 
	.converted_value(value_7_segment[0])
);

assign	SEVEN_SEGMENT_N_O[0] = (light_flag) ? 7'h7f : value_7_segment[0],
		SEVEN_SEGMENT_N_O[1] = (light_flag) ? 7'h7f : value_7_segment[1],
		SEVEN_SEGMENT_N_O[2] = (light_flag) ? 7'h7f : value_7_segment[2],
		SEVEN_SEGMENT_N_O[3] = (light_flag) ? 7'h7f : value_7_segment[3],
		SEVEN_SEGMENT_N_O[4] = (light_flag) ? 7'h7f : value_7_segment[4],
		SEVEN_SEGMENT_N_O[5] = (light_flag) ? 7'h7f : value_7_segment[5],
		SEVEN_SEGMENT_N_O[6] = (light_flag) ? 7'h7f : value_7_segment[6],
		SEVEN_SEGMENT_N_O[7] = (light_flag) ? 7'h7f : value_7_segment[7];

endmodule
