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
// It utilizes a priority encoder to detect a 1 on the MSB for switches 17 downto 0
// It then displays the switch number onto the 7-segment display
module exercise1 (
		/////// switches                          ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs
		output logic[17:0] LED_RED_O              // 18 red LEDs
);

logic [3:0] value;
logic [3:0] value1;
logic [6:0] value_7_segment;
logic [6:0] value1_7_segment;
logic turnoff;

logic [3:0] value2;
logic [3:0] value3;
logic [6:0] value2_7_segment;
logic [6:0] value3_7_segment;
logic turnon;

// Instantiate a module for converting hex number to 7-bit value for the 7-segment display
convert_hex_to_seven_segment unit0 (
	.hex_value(value),
	.converted_value(value_7_segment)
);

convert_hex_to_seven_segment unit1 (
	.hex_value(value1),
	.converted_value(value1_7_segment)
);

convert_hex_to_seven_segment unit2 (
	.hex_value(value2),
	.converted_value(value2_7_segment)
);

convert_hex_to_seven_segment unit3 (
	.hex_value(value3),
	.converted_value(value3_7_segment)
);


// A priority encoder using if-else statement
always_comb begin
	if (SWITCH_I[17] == 1'b1) begin
		value = 4'd7;
		value1 = 8'd1;
		end else begin
		if (SWITCH_I[16] == 1'b1) begin
			value = 4'd6;
			value1 = 8'd1;
			end else begin
			if (SWITCH_I[15] == 1'b1) begin
				value = 4'd5;
				value1 = 8'd1;
				end else begin
				if (SWITCH_I[14] == 1'b1) begin
					value = 4'd4;
					value1 = 8'd1;
					end else begin
					if (SWITCH_I[13] == 1'b1) begin
						value = 4'd3;
						value1 = 8'd1;
						end else begin
						if (SWITCH_I[12] == 1'b1) begin
							value = 4'd2;
							value1 = 8'd1;
							end else begin
							if (SWITCH_I[11] == 1'b1) begin
								value = 4'd1;
								value1 = 8'd1;
								end else begin
								if (SWITCH_I[10] == 1'b1) begin
									value = 4'd0;
									value1 = 8'd1;
									end else begin
									if (SWITCH_I[9] == 1'b1) begin
										value = 4'd9;
										value1 = 8'd0;
									end else begin
										if (SWITCH_I[8] == 1'b1) begin
											value = 4'd8;
											value1 = 8'd0;
										end else begin
											if (SWITCH_I[7] == 1'b1) begin
												value = 4'd7;
												value1 = 8'd0;
											end else begin
												if (SWITCH_I[6] == 1'b1) begin
													value = 4'd6;
													value1 = 8'd0;
												end else begin
													if (SWITCH_I[5] == 1'b1) begin
														value = 4'd5;
														value1 = 8'd0;
													end else begin
														if (SWITCH_I[4] == 1'b1) begin
															value = 4'd4;
															value1 = 8'd0;
														end else begin
															if (SWITCH_I[3] == 1'b1) begin
																value = 4'd3;
																value1 = 8'd0;
															end else begin
																if (SWITCH_I[2] == 1'b1) begin
																	value = 4'd2;
																	value1 = 8'd0;
																end else begin
																	if (SWITCH_I[1] == 1'b1) begin
																		value = 4'd1;
																		value1 = 8'd0;
																	end else begin
																		if (SWITCH_I[0] == 1'b1) begin
																			value = 4'd0;
																			value1 = 8'd0;
																		end else begin
																			value = 4'hF;
																			value1 = 8'hF;
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

always_comb begin
	if (SWITCH_I[0] == 1'b0) begin
		value2 = 4'd0;
		value3 = 8'd0;
		end else begin
		if (SWITCH_I[1] == 1'b0) begin
			value2 = 4'd1;
			value3 = 8'd0;
			end else begin
			if (SWITCH_I[2] == 1'b0) begin
				value2 = 4'd2;
				value3 = 8'd0;
				end else begin
				if (SWITCH_I[3] == 1'b0) begin
					value2 = 4'd3;
					value3 = 8'd0;
					end else begin
					if (SWITCH_I[4] == 1'b0) begin
						value2 = 4'd4;
						value3 = 8'd0;
						end else begin
						if (SWITCH_I[5] == 1'b0) begin
							value2 = 4'd5;
							value3 = 8'd0;
							end else begin
							if (SWITCH_I[6] == 1'b0) begin
								value2 = 4'd6;
								value3 = 8'd0;
								end else begin
								if (SWITCH_I[7] == 1'b0) begin
									value2 = 4'd7;
									value3 = 8'd0;
									end else begin
									if (SWITCH_I[8] == 1'b0) begin
										value2 = 4'd8;
										value3 = 8'd0;
									end else begin
										if (SWITCH_I[9] == 1'b0) begin
											value2 = 4'd9;
											value3 = 8'd0;
										end else begin
											if (SWITCH_I[10] == 1'b0) begin
												value2 = 4'd0;
												value3 = 8'd1;
											end else begin
												if (SWITCH_I[11] == 1'b0) begin
													value2 = 4'd1;
													value3 = 8'd1;
												end else begin
													if (SWITCH_I[12] == 1'b0) begin
														value2 = 4'd2;
														value3 = 8'd1;
													end else begin
														if (SWITCH_I[13] == 1'b0) begin
															value2 = 4'd3;
															value3 = 8'd1;
														end else begin
															if (SWITCH_I[14] == 1'b0) begin
																value2 = 4'd4;
																value3 = 8'd1;
															end else begin
																if (SWITCH_I[15] == 1'b0) begin
																	value2 = 4'd5;
																	value3 = 8'd1;
																end else begin
																	if (SWITCH_I[16] == 1'b0) begin
																		value2 = 4'd6;
																		value3 = 8'd1;
																	end else begin
																		if (SWITCH_I[17] == 1'b0) begin
																			value2 = 4'd7;
																			value3 = 8'd1;
																		end else begin
																			value2 = 4'hF;
																			value3 = 8'hF;
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


assign turnoff = ~|SWITCH_I[17:0]; //If all the switches are off, turnoff will be 1
assign turnon = &SWITCH_I[17:0]; //If all the switches are on, turnon will be 1

assign  SEVEN_SEGMENT_N_O[0] = turnoff ? 7'h7f : value_7_segment,
        SEVEN_SEGMENT_N_O[1] = turnoff ? 7'h7f : value1_7_segment,
        SEVEN_SEGMENT_N_O[2] = 7'h7f,
        SEVEN_SEGMENT_N_O[3] = 7'h7f,
        SEVEN_SEGMENT_N_O[4] = 7'h7f,
        SEVEN_SEGMENT_N_O[5] = 7'h7f,
        SEVEN_SEGMENT_N_O[6] = turnon ? 7'h7f : value2_7_segment,
        SEVEN_SEGMENT_N_O[7] = turnon ? 7'h7f : value3_7_segment;
		  

assign LED_RED_O = SWITCH_I;
assign LED_GREEN_O[7] = {5'h00, {SWITCH_I[17] == 1'b1}&&{SWITCH_I[16] == 1'b1}&&{SWITCH_I[15] == 1'b1}};
assign LED_GREEN_O[6] = {5'h00, {SWITCH_I[17] == 1'b1}||{SWITCH_I[16] == 1'b1}||{SWITCH_I[15] == 1'b1}};
assign LED_GREEN_O[5] = {5'h00, {SWITCH_I[14] == 1'b0}&&{SWITCH_I[13] == 1'b0}&&{SWITCH_I[12] == 1'b0}};
assign LED_GREEN_O[4] = {5'h00, {SWITCH_I[14] == 1'b0}||{SWITCH_I[13] == 1'b0}||{SWITCH_I[12] == 1'b0}};
assign LED_GREEN_O[3] = {5'h00, {{{SWITCH_I[11] == 1'b1}||{SWITCH_I[10] == 1'b1}}&&{{SWITCH_I[10] == 1'b1}||{SWITCH_I[9] == 1'b1}}}&&{{SWITCH_I[11] == 1'b1}||{SWITCH_I[9] == 1'b1}}};
assign LED_GREEN_O[2] = {5'h00, ~{{{{SWITCH_I[8] == 1'b1}||{SWITCH_I[7] == 1'b1}}&&{{SWITCH_I[7] == 1'b1}||{SWITCH_I[6] == 1'b1}}}&&{{SWITCH_I[8] == 1'b1}||{SWITCH_I[6] == 1'b1}}}};
assign LED_GREEN_O[1] = {5'h00, {SWITCH_I[5] == 1'b1}~^{SWITCH_I[4] == 1'b1}^{SWITCH_I[3] == 1'b1}};
assign LED_GREEN_O[0] = {5'h00, ~{{SWITCH_I[2] == 1'b1}~^{SWITCH_I[1] == 1'b1}^{SWITCH_I[0] == 1'b1}}};
	
endmodule
