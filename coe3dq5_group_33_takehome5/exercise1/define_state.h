`ifndef DEFINE_STATE

// This defines the states for BIST

typedef enum logic [3:0] {
	S_IDLE,
	S_START,
	S_WRITE_CYCLE,
	S_DELAY_1,
	S_DELAY_2,
	S_READ_CYCLE,
	S_DELAY_3,
	S_DELAY_4,
	S_WRITE_CYCLE_2,
	S_DELAY_5,
	S_DELAY_6,
	S_READ_CYCLE_2,
	S_DELAY_7,
	S_DELAY_8
} BIST_state_type;

parameter PAT0 = 16'h3333;
parameter PAT1 = 16'hCCCC;
parameter PAT2 = 16'h0F0F;
parameter PAT3 = 16'hF0F0;

`define DEFINE_STATE 1
`endif
