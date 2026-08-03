
module PS2_Demo (
	// Inputs
	CLOCK_50,
	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	//outputs 
	game_arrows, 
	KEY
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input	CLOCK_50;
input[3:0] KEY; //reset

// Bidirectionals
inout	PS2_CLK;
inout	PS2_DAT;

//output 
output [3:0] game_arrows; 


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire[7:0] ps2_key_data;
wire ps2_key_pressed;

// Internal Registers
reg[7:0] last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

//update the logic 
always @(posedge CLOCK_50)
begin
	if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50 (CLOCK_50),
	.reset (~KEY[0]),

	// Bidirectionals
	.PS2_CLK (PS2_CLK),
 	.PS2_DAT (PS2_DAT),

	// Outputs
	.received_data (ps2_key_data),
	.received_data_en (ps2_key_pressed),
	.arrow_direction(game_arrows)  );




endmodule
