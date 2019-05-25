/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

// This is the top module
// It connects the SRAM and VGA together
// It will first write RGB data of an image with 8x8 rectangles of size 40x30 pixels into the SRAM
// The VGA will then read the SRAM and display the image
module exercise2 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_I,           // pushbuttons
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
		
		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[17:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O                  // SRAM output logic enable
);

parameter NUM_ROW_RECTANGLE = 8,
		  NUM_COL_RECTANGLE = 8,
		  RECT_WIDTH = 40,
		  RECT_HEIGHT = 30,
		  VIEW_AREA_LEFT = 160,
		  VIEW_AREA_RIGHT = 480,
		  VIEW_AREA_TOP = 120,
		  VIEW_AREA_BOTTOM = 360;
		  
parameter R_segment = 18'd0, 
			even_G_segment = 18'd38400,
			odd_G_segment = 18'd57600,
			B_segment = 18'd76800;

state_type state;

// For Push button
logic [3:0] PB_pushed;

// For VGA
logic [9:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

// Counter
//logic SRAM_counter;

logic resetn;

// For SRAM
logic [17:0] SRAM_address;
logic [17:0] SRAM_address_o;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

logic [2:0] rect_row_count;		// Number of rectangles in a row
logic [2:0] rect_col_count;		// Number of rectangles in a column
logic [5:0] rect_width_count;	// Width of each rectangle
logic [4:0] rect_height_count;	// Height of each rectangle
logic [2:0] color;
logic [1:0] current_write_color;

logic [15:0] VGA_sram_data [3:0]; // we have to buffer 2 red values, a green and a blue

assign resetn = ~SWITCH_I[17] && SRAM_ready;

// Push Button unit
PB_Controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_I),	
	.PB_pushed(PB_pushed)
);

// SRAM unit
SRAM_Controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address_o),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);

// VGA unit
VGA_Controller VGA_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn),

	.iRed(VGA_red),
	.iGreen(VGA_green),
	.iBlue(VGA_blue),
	.oCoord_X(pixel_X_pos),
	.oCoord_Y(pixel_Y_pos),
	
	//	VGA Side
	.oVGA_R(VGA_RED_O),
	.oVGA_G(VGA_GREEN_O),
	.oVGA_B(VGA_BLUE_O),
	.oVGA_H_SYNC(VGA_HSYNC_O),
	.oVGA_V_SYNC(VGA_VSYNC_O),
	.oVGA_SYNC(VGA_SYNC_O),
	.oVGA_BLANK(VGA_BLANK_O),
	.oVGA_CLOCK(VGA_CLOCK_O)
);

// Each rectangle will have different color
assign color = rect_col_count + rect_row_count;
assign SRAM_write_data = {16{color[current_write_color]}};

// map the SRAM_address to the correct region of the memory depending on colour
always_comb begin
	case (state)
		// icrementing memory addresses according to the specifications
		//S_NEW_PIXEL_ROW_DELAY_1: SRAM_address_o = SRAM_address + R_segment;
		S_NEW_PIXEL_ROW_DELAY_2: SRAM_address_o = SRAM_address[17:1] + even_G_segment;
		S_NEW_PIXEL_ROW_DELAY_3: SRAM_address_o = SRAM_address + B_segment;
		S_NEW_PIXEL_ROW_DELAY_4: SRAM_address_o = SRAM_address[17:1] + odd_G_segment;
		//S_FETCH_PIXEL_DATA_0: SRAM_address_o = SRAM_address + R_segment;
		S_FETCH_PIXEL_DATA_1: SRAM_address_o = SRAM_address[17:1] + even_G_segment;
		S_FETCH_PIXEL_DATA_2: SRAM_address_o = SRAM_address + B_segment;
		S_FETCH_PIXEL_DATA_3: SRAM_address_o = SRAM_address[17:1] + odd_G_segment;
		default: SRAM_address_o = SRAM_address;
	endcase
end

always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		state <= S_IDLE;
		rect_row_count <= 3'd0;
		rect_col_count <= 3'd0;
		rect_width_count <= 6'd0;
		rect_height_count <= 5'd0;
		current_write_color <= 2'd2;
		
		VGA_red <= 10'd0;
		VGA_green <= 10'd0;
		VGA_blue <= 10'd0;				
		
		SRAM_we_n <= 1'b1;
		SRAM_address <= 18'd0;
		//SRAM_counter <= 1'b0;
	end else begin
		case (state)
		S_IDLE: begin
			rect_row_count <= 3'd0;
			rect_col_count <= 3'd0;
			rect_width_count <= 6'd0;
			rect_height_count <= 5'd0;
			current_write_color <= 2'd2;

			if (PB_pushed[0] == 1'b1) begin
				// Start filling the SRAM
				state <= S_FILL_SRAM;
				SRAM_address <= 18'd0;				
				SRAM_we_n <= 1'b0;
			end
		end
		S_FILL_SRAM: begin
			SRAM_address <= SRAM_address + 18'd1;

			// Segment control
			if (SRAM_address == 18'd38399) begin
				// last red address
				rect_row_count <= 3'd0;
				rect_col_count <= 3'd0;
				rect_width_count <= 6'd10; // write half as many pix values for even G segment
				rect_height_count <= 5'd0;
				current_write_color <= 2'd1;
			end else if (SRAM_address == 18'd57599) begin
				// end of even G segment
				rect_row_count <= 3'd0;
				rect_col_count <= 3'd0;
				rect_width_count <= 6'd10; // write half as many pix values for odd G segment
				rect_height_count <= 5'd0;
			end else if (SRAM_address == 18'd76799) begin
				// end of odd G segment
				rect_row_count <= 3'd0;
				rect_col_count <= 3'd0;
				rect_width_count <= 6'd0;
				rect_height_count <= 5'd0;
				current_write_color <= 2'd0;
			end else if (SRAM_address == 18'd115199) begin
				SRAM_we_n <= 1'b1;
				state <= S_FINISH_FILL_SRAM;
			end else if (rect_width_count < 'd19) begin
				// Same horizontal line for a rectangle
				rect_width_count <= rect_width_count + 6'd1;
			end else begin
				// Move to the next rectangle
				if (current_write_color == 2'd1) rect_width_count <= 6'd10;
				else rect_width_count <= 6'd0;
				  
				if (rect_col_count < (NUM_COL_RECTANGLE - 1)) rect_col_count <= rect_col_count + 3'd1;
				else begin
					// One pixel row
					if (rect_height_count < (RECT_HEIGHT - 1)) begin
						rect_height_count <= rect_height_count + 5'd1;
					end else begin
						// New row of rectangle
						rect_row_count <= rect_row_count + 3'd1;
						rect_height_count <= 5'd0;
					end
					rect_col_count <= 3'd0;						
				end
			end
		end
		S_FINISH_FILL_SRAM: begin
			// Finish filling the SRAM
			// Now prepare for VGA to read the image
			VGA_sram_data[3] <= 16'd0;
			VGA_sram_data[2] <= 16'd0;
			VGA_sram_data[1] <= 16'd0;
			VGA_sram_data[0] <= 16'd0;

			SRAM_address <= 18'h00000;									
			
			state <= S_WAIT_NEW_PIXEL_ROW;			
		end
		S_WAIT_NEW_PIXEL_ROW: begin
			if (pixel_Y_pos >= VIEW_AREA_TOP && pixel_Y_pos < VIEW_AREA_BOTTOM) begin
				if (pixel_X_pos == (VIEW_AREA_LEFT - 3)) begin
					if (pixel_Y_pos == VIEW_AREA_TOP) begin
						// Start a new frame
                  // Provide address for Red component for first two pixels
						SRAM_address <= 18'd0;
						//SRAM_counter <= 18'd0;
					end else begin
						// Start a new row of pixels
						SRAM_address <= SRAM_address - 18'd1;
						//SRAM_address <= SRAM_address - 18'd4;
						//SRAM_address <= SRAM_counter - 18'd1;
					end
               // Jump to the first lead-in state
					state <= S_NEW_PIXEL_ROW_DELAY_1;
 				end
			end

			VGA_red <= 10'd0;
			VGA_green <= 10'd0;
			VGA_blue <= 10'd0;								
		end
		
		S_NEW_PIXEL_ROW_DELAY_1: begin
			state <= S_NEW_PIXEL_ROW_DELAY_2;
		end
		
		S_NEW_PIXEL_ROW_DELAY_2: begin
			//SRAM_address_o <= SRAM_address[17:1] + even_G_segment; // even G segment
			state <= S_NEW_PIXEL_ROW_DELAY_3;
		end
		
		S_NEW_PIXEL_ROW_DELAY_3: begin
			//SRAM_address_o <= SRAM_address + B_segment; // B segment
			
			VGA_sram_data[3] <= SRAM_read_data[15:8]; // R0 
			VGA_sram_data[2] <= SRAM_read_data[7:0]; // R1
			
			state <= S_NEW_PIXEL_ROW_DELAY_4;
		end
		
		S_NEW_PIXEL_ROW_DELAY_4: begin
			//SRAM_address_o <= SRAM_address[17:1] + odd_G_segment; // odd G segment
			SRAM_address <= SRAM_address + 18'h00001;
			
			VGA_sram_data[1] <= SRAM_read_data[15:8]; // G0
			//VGA_sram_data[1] <= SRAM_read_data[7:0]; // G1
			
			//state <= S_NEW_PIXEL_ROW_DELAY_5;
			state <= S_FETCH_PIXEL_DATA_0;
		end
		
		S_NEW_PIXEL_ROW_DELAY_5: begin
			SRAM_address <= SRAM_address + 18'h00001;
			
			//VGA_sram_data[1] <= SRAM_read_data[15:8]; // B0
			VGA_sram_data[0] <= SRAM_read_data[7:0]; // B1
		
			state <= S_FETCH_PIXEL_DATA_0;
		end
		
		S_FETCH_PIXEL_DATA_0: begin
			
			//VGA_sram_data[0] <= SRAM_read_data[15:8]; // B0
			VGA_sram_data[0] <= SRAM_read_data[7:0]; // B1
			      
			// Provide RGB data
			VGA_red <= {VGA_sram_data[3], 2'b00}; // R0
			VGA_green <= {VGA_sram_data[1], 2'b00}; // G0
			VGA_blue <= {SRAM_read_data[15:8], 2'b00}; // B0		 
			
			state <= S_FETCH_PIXEL_DATA_1;			
		end
		
		S_FETCH_PIXEL_DATA_1: begin
			//SRAM_address_o <= SRAM_address[17:1] + even_G_segment; // even G segment
			
			if (SRAM_address[0]) VGA_sram_data[1] <= SRAM_read_data[15:8]; // G0
			else VGA_sram_data[1] <= SRAM_read_data[7:0]; // G1
											
			state <= S_FETCH_PIXEL_DATA_2;
		end
		
		S_FETCH_PIXEL_DATA_2: begin
			//SRAM_address_o <= SRAM_address + B_segment; // B segment
			
			VGA_sram_data[3] <= SRAM_read_data[15:8]; // R0 
			VGA_sram_data[2] <= SRAM_read_data[7:0]; // R1
			
			// Provide RGB data
			VGA_red <= {VGA_sram_data[2], 2'b00}; // R
			VGA_green <= {VGA_sram_data[1], 2'b00}; // G
			VGA_blue <= {VGA_sram_data[0], 2'b00}; //B
			
			state <= S_FETCH_PIXEL_DATA_3;
		end
		
		S_FETCH_PIXEL_DATA_3: begin 
			//SRAM_address_o <= SRAM_address[17:1] + odd_G_segment; // odd G segment
			SRAM_address <= SRAM_address + 18'h00001;
			
			if (SRAM_address[0]) VGA_sram_data[1] <= SRAM_read_data[7:0]; // G1
			else VGA_sram_data[1] <= SRAM_read_data[15:8]; // G0
						
			if (pixel_X_pos < (VIEW_AREA_RIGHT - 2))
				// Still within one row
				state <= S_FETCH_PIXEL_DATA_0;
			else
				state <= S_WAIT_NEW_PIXEL_ROW;
		end		
		default: state <= S_IDLE;
		endcase
	end
end

endmodule
