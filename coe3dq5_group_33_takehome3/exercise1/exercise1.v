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
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock
		
		/////// switches                          ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[9:0] VGA_RED_O,              // VGA red
		output logic[9:0] VGA_GREEN_O,            // VGA green
		output logic[9:0] VGA_BLUE_O,             // VGA blue
		
		/////// PS2                               ////////////
		input logic PS2_DATA_I,                   // PS2 data
		input logic PS2_CLOCK_I                   // PS2 clock
);

logic system_resetn;
logic Clock_50, Clock_25, Clock_25_locked;

// For PS/2 Controller
logic [7:0] PS2_code;
logic PS2_code_ready;
logic PS2_code_ready_buf;
logic PS2_make_code;

// For VGA
logic [9:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

// User defined
logic VGA_vsync_buf;
logic [6:0] frame_counter = 1'd0;
logic[2:0] counter_tl;
logic[2:0] counter_tr;
logic[2:0] counter_bl;
logic[2:0] counter_br;

logic key_L, key_L_pressed;
logic key_Q, key_Q_pressed;
logic key_W, key_W_pressed;
logic key_A, key_A_pressed;
logic key_S, key_S_pressed;

assign key_L = (PS2_code == 8'h4B);
assign key_Q = (PS2_code == 8'h15);
assign key_W = (PS2_code == 8'h1D);
assign key_A = (PS2_code == 8'h1C);
assign key_S = (PS2_code == 8'h1B);

assign system_resetn = ~(SWITCH_I[17] || ~Clock_25_locked);


// PS/2 controller
PS2_controller ps2_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(system_resetn),
	.PS2_clock(PS2_CLOCK_I),
	.PS2_data(PS2_DATA_I),
	.PS2_code(PS2_code),
	.PS2_code_ready(PS2_code_ready),
	.PS2_make_code(PS2_make_code)
);

// PLL for clock generation
CLOCK_25_PLL CLOCK_25_PLL_inst (
	.areset(SWITCH_I[17]),
	.inclk0(CLOCK_50_I),
	.c0(Clock_50),
	.c1(Clock_25),
	.locked(Clock_25_locked)
);

// VGA unit
VGA_Controller VGA_unit(
	.Clock(Clock_25),
	.Resetn(system_resetn),

	.iRed(VGA_red),
	.iGreen(VGA_green),
	.iBlue(VGA_blue),
	.oCoord_X(pixel_X_pos),
	.oCoord_Y(pixel_Y_pos),
	
	//	VGA Sidcountere
	.oVGA_R(VGA_RED_O),
	.oVGA_G(VGA_GREEN_O),
	.oVGA_B(VGA_BLUE_O),
	.oVGA_H_SYNC(VGA_HSYNC_O),
	.oVGA_V_SYNC(VGA_VSYNC_O),
	.oVGA_SYNC(VGA_SYNC_O),
	.oVGA_BLANK(VGA_BLANK_O),
	.oVGA_CLOCK()
);

assign VGA_CLOCK_O = CLOCK_50_I;

always_ff @ (posedge Clock_25 or negedge system_resetn) begin
	if (system_resetn == 1'b0) begin
		VGA_vsync_buf <= 1'b0;
	end else begin
		VGA_vsync_buf <= VGA_VSYNC_O;
	end
end

always_ff @ (posedge Clock_25 or negedge system_resetn) begin
	if (system_resetn == 1'b0) begin
		PS2_code_ready_buf <= 1'b0; 
		key_L_pressed <= 1'b0;
		key_Q_pressed <= 1'b0;
		key_W_pressed <= 1'b0;
		key_A_pressed <= 1'b0;
		key_S_pressed <= 1'b0;
 	end else begin
		if((PS2_code_ready == 1'b1) && (PS2_code_ready_buf == 1'b0) && (PS2_make_code == 1'b0) && (PS2_code != 8'hF0)) begin
			
			if(key_L) begin
				key_L_pressed <= 1'b1;
				key_Q_pressed <= 1'b0;
				key_W_pressed <= 1'b0;
				key_A_pressed <= 1'b0;
				key_S_pressed <= 1'b0;
			end
			//else key_L_pressed <= 1'b0;
			
			if(key_Q) key_Q_pressed <= 1'b1;
			//else key_Q_pressed <= 1'b0;
			
			if(key_W) key_W_pressed <= 1'b1;
			//else key_W_pressed <= 1'b0;
			
			if(key_A) key_A_pressed <= 1'b1;
			//else key_A_pressed <= 1'b0;
			
			if(key_S) key_S_pressed <= 1'b1;
			//else key_S_pressed <= 1'b0;
			
		end
	end
end


always_ff @ (posedge Clock_25 or negedge system_resetn) begin
	if (system_resetn == 1'b0) begin
		counter_tl <= 3'b0;
		counter_tr <= 3'b0;
		counter_bl <= 3'b0;
		counter_br <= 3'b0;
		frame_counter <= 1'd0;
 	end else begin
	
		if(key_L_pressed) begin
			
			if(VGA_vsync_buf && ~VGA_VSYNC_O) begin
			
				frame_counter <= frame_counter + 1'd1;
				if(frame_counter == 10'd49) begin
					
					frame_counter <= 1'd0;
					
					if(key_Q_pressed == 1'b0) begin
						if(SWITCH_I[3] == 1'b1) counter_tl <= counter_tl + 3'b1;
						else counter_tl <= counter_tl - 3'b1;
					end else begin 
						counter_tl <= counter_tl;
					end
					
					if(key_W_pressed == 1'b0) begin
						if(SWITCH_I[7] == 1'b1) counter_tr <= counter_tr + 3'b1;
						else  counter_tr <= counter_tr - 3'b1;
					end else begin
						counter_tr <= counter_tr;
					end
					
					if(key_A_pressed == 1'b0) begin
						if(SWITCH_I[11] == 1'b1) counter_bl <= counter_bl + 3'b1;
						else counter_bl <= counter_bl - 3'b1;
					end else begin
						counter_bl <= counter_bl;
					end
					
					if(key_S_pressed == 1'b0) begin
						if(SWITCH_I[15] == 1'b1) counter_br <= counter_br + 3'b1;
						else counter_br <= counter_br - 3'b1;
					end else begin
						counter_br <= counter_br;
					end
					
				end
		
			end
		end
	end
end


always_comb begin

	if (pixel_X_pos >= 10'd0 && pixel_X_pos < 10'd320
	 && pixel_Y_pos >= 10'd0 && pixel_Y_pos < 10'd240) begin
	 
		VGA_red = SWITCH_I[2] ? {10{counter_tl[2]}} : 10'h000;
		VGA_green = SWITCH_I[1] ? {10{counter_tl[1]}} : 10'h000;
		VGA_blue = SWITCH_I[0] ? {10{counter_tl[0]}} : 10'h000;
		
	end else if (pixel_X_pos >= 10'd320 && pixel_X_pos < 10'd640
	 && pixel_Y_pos >= 10'd0 && pixel_Y_pos < 10'd240) begin
	 
		VGA_red = SWITCH_I[6] ? {10{counter_tr[2]}} : 10'h000;
		VGA_green = SWITCH_I[5] ? {10{counter_tr[1]}} : 10'h000;
		VGA_blue = SWITCH_I[4] ? {10{counter_tr[0]}} : 10'h000;
		
	end else if (pixel_X_pos >= 10'd0 && pixel_X_pos < 10'd320
	 && pixel_Y_pos >= 10'd240 && pixel_Y_pos < 10'd480) begin
	 
		VGA_red = SWITCH_I[10] ? {10{counter_bl[2]}} : 10'h000;
		VGA_green = SWITCH_I[9] ? {10{counter_bl[1]}} : 10'h000;
		VGA_blue = SWITCH_I[8] ? {10{counter_bl[0]}} : 10'h000;
	
	end else if (pixel_X_pos >= 10'd320 && pixel_X_pos < 10'd640
	 && pixel_Y_pos >= 10'd240 && pixel_Y_pos < 10'd480) begin
		
		VGA_red = SWITCH_I[14] ? {10{counter_br[2]}} : 10'h000;
		VGA_green = SWITCH_I[13] ? {10{counter_br[1]}} : 10'h000;
		VGA_blue = SWITCH_I[12] ? {10{counter_br[0]}} : 10'h000;
	
	end else begin
		
		VGA_red = 10'h000;
		VGA_green = 10'h000;
		VGA_blue = 10'h000;
	
	end
	
end


endmodule
