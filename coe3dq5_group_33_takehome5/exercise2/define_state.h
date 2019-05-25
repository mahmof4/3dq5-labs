`ifndef DEFINE_STATE

// This defines the states

typedef enum logic [3:0] {
	
	//S_IDLE,
	S_FILL_SRAM,
	//S_FINISH_FILL_SRAM,
   //S_WAIT_NEW_PIXEL_ROW
    /* add your states */
	
	S_WAIT_NEW_PIXEL_ROW,
	S_NEW_PIXEL_ROW_DELAY_1,
	S_NEW_PIXEL_ROW_DELAY_2,
	S_NEW_PIXEL_ROW_DELAY_3,
	S_NEW_PIXEL_ROW_DELAY_4,
	S_NEW_PIXEL_ROW_DELAY_5,
	S_FETCH_PIXEL_DATA_0,
	S_FETCH_PIXEL_DATA_1,
	S_FETCH_PIXEL_DATA_2,
	S_FETCH_PIXEL_DATA_3,
	S_IDLE,
	S_FILL_SRAM_0,
	S_FILL_SRAM_1,
	S_FILL_SRAM_2,
	S_FINISH_FILL_SRAM
	
} state_type;

`define DEFINE_STATE 1
`endif
