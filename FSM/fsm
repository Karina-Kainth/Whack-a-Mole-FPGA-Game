/*General Notes: 
	- no asyncronys resets anywhere in circuit 
	- all resets are active high (whatever tf the resets are gonna be) 
	- currently implemented such that the game will run forever until the user reaches 10 points 

*/ 


module fsm(CLOCK_50, key_signal, VGA_output, LEDR, scoreDisplay, gameTimer); 
/*****************************************************************************
 *                                inputs/outputs                             *
 *****************************************************************************/
input CLOCK_50; 
input [3:0] key_signal;

output[2:0] VGA_output; 
output [9:0] LEDR; //this will be driven to the LEDs on the board and the VGA board to show the moles and the LED
output[3:0] scoreDisplay; //score counter to be shown 

output[5:0] gameTimer; 
/*****************************************************************************
 *                            Parameters and Wires                           *
 *****************************************************************************/
/*Notes: 
	- for the sake of readabilty, implement wires and parameters where they are needed, and not at the top?
	- there is a mix of both styles in this code right now 
*/ 

localparam 	OTHER_KEY  	= 4'd0,    //any other key pressed or no key pressed 
	   	MOVE_ONE    	= 4'd1,  
           	MOVE_TWO  	= 4'd2,  
           	MOVE_THREE  	= 4'd3,  
           	MOVE_FOUR	= 4'd4,  
	   	RESET      	= 4'd5,  //restart the game
	   	START      	= 4'd6,  //start the game 
		key1 		= 4'd7,
		key2 		= 4'd8, 
		key3 		= 4'd9;  


wire reset = (key_signal == RESET); //reset signal wire gets driven HIGH if key pressed is R. 
wire startKey = (key_signal == START);


reg[3:0] score;  //4 max bits, to hold a counter that goes up to 10
reg[3:0] mole_position; //shows the positions of the moles 

// Random number generator for mole timings
wire [15:0] random;

//reg for LEDs lighting up 
reg[3:0] mole_LED; 

//reg for the game counter 
reg [5:0] countDownGameTime; 
/*****************************************************************************
 *                            Half-second tick generator                     *              -> done?
 *****************************************************************************/
/*Notes: 	
	- has a syncornys reset, maybe let's not?
	- reset is active high 
*/

reg[24:0] half_sec_count; //wire creation
reg half_sec_pulse; //1 bit pulse for half second 

always @(posedge CLOCK_50) begin
	if(reset) begin //active high reset
		half_sec_count <= 0;
		half_sec_pulse <= 0;	
	end
	else if (half_sec_count == 25_000_000 - 1) begin  //tick if half second has passed 
		half_sec_count <= 0; //reset the counter 
		half_sec_pulse <= 1;
	end
	else begin
		half_sec_count <= half_sec_count +1;
		half_sec_pulse <= 0;  //reset the tick until the next half second
	end
end


/*****************************************************************************
 *                          FSM for main game logic                          *
 *****************************************************************************/
/*Notes: 
	- no fucking idea what is implemented in this section 
	- reset is active high 
*/

//FSM states for main game logic 
localparam  	START_DISPLAY	= 4'd0,
		IDLE       	= 4'd1, 
		DELAY 		= 4'd2, 
		SPAWN 		= 4'd3, 
		CHECK 		= 4'd4, 
		TIME_UP 	= 4'd5, 
		INCREMENT_SCORE = 4'd6, 
		GAME_OVER 	= 4'd7, 
		LEVEL_CHOICE	= 4'd8; 

//signals to be sent to the VGA for which screen to display 
localparam 	START_SCREEN 	= 3'd0, //displays options for levels 
		GAME_SCREEN 	= 3'd1,  
		END_SCREEN 	= 3'd2, 
		LEVEL_1_START 	= 3'd3, //all these screens prompt a start 
		LEVEL_2_START 	= 3'd4, 
		LEVEL_3_START 	= 3'd5;  

//signals that determine which level is chosen 
localparam 	LEVEL_ONE 	= 2'd0, 
		LEVEL_TWO	= 2'd1,
		LEVEL_THREE 	= 2'd2;  
		

		 
reg[3:0] current_state; //will take the value of one of the 4 bit states of the FSM 
reg[3:0] next_state; //will take the value of one of the 4 bit states of the FSM 
reg[2:0] vga_display_screen_signal; //this 3 bit signal will tell the VGA which screen to display 

//signals used to help transitions to next states
reg correct_hit, start_delay, start_timer, score_ten, start_game; 
wire time_up_mole_display, time_up_mole_delay, count_down; 

//signal which select the level 
reg[1:0] level; //2 bits to hold up to a 4 numbers


always @(posedge CLOCK_50) begin 
	if(reset) begin 
		//drive all things to their base states	(does the same stuff as the START_DISPLAY state) 
		vga_display_screen_signal <= START_SCREEN; 
		score <= 4'd0; //reset the score
		mole_LED <= 4'd0; //display no moles 
		start_delay <= 1'd0; 
		start_timer <= 1'd0; 
		score_ten <= 1'd0; 
		start_game <= 1'b0; 
		correct_hit <= 1'd0; 
		level <= LEVEL_TWO; 
	end 
	else begin 
	case(current_state) ///////////start case
	LEVEL_CHOICE: begin 
		//reset everything (should already have happened the moment reset was triggered but do it again, why not)
		vga_display_screen_signal <= START_SCREEN; 
		score <= 4'd0; //reset the score
		mole_LED <= 4'd0; //display no moles 
		start_delay <= 1'd0; 
		start_timer <= 1'd0;
		start_game <= 1'b0;  
		score_ten <= 1'd0; 
		correct_hit <= 1'd0;
		if(key_signal == key1)  
			level <= LEVEL_ONE; 
		else if(key_signal == key2) 
			level <= LEVEL_TWO; 
		else if(key_signal == key3) 
			level <= LEVEL_THREE; 
		else //user hasn't picked a case yet 
			level <= LEVEL_TWO;
	end
	START_DISPLAY: begin 
		if(level == LEVEL_ONE) 	
			vga_display_screen_signal <= LEVEL_1_START;
		else if(level == LEVEL_TWO) 
			vga_display_screen_signal <= LEVEL_2_START;
		else if(level == LEVEL_THREE) 
			vga_display_screen_signal <= LEVEL_3_START;
		else 
			vga_display_screen_signal <= START_SCREEN; //should never be triggered, can't be in start_display state if level is default 
	end 
	IDLE: begin 
		start_game <= 1'b1; 
		vga_display_screen_signal <= GAME_SCREEN; 
		start_delay <= 1'b0; 
		start_timer <= 1'b0; 
		mole_LED <= 4'd0; //display no moles 
		 	
	end 
	DELAY: begin 
		//VGA screen signal doesn't change, will stay in game_screen 
		start_delay <= 1'b1; //triggers the timer module (begins a delay before the mole shows up) 
		start_timer <= 1'b0; //DONT turn the timer on 
		
	end 
	SPAWN: begin 
		start_delay <= 1'b0; //ends the timer module
		start_timer <= 1'b1; //triggers the timer module

		//cases to light up the LEDS once game starts
		if(mole_position == MOVE_ONE) 
			mole_LED <= 4'b1000;  //F1 (key on the far left) makes the LED on the far left light up 
		else if(mole_position == MOVE_TWO) 
			mole_LED <= 4'b0100; 
		else if(mole_position == MOVE_THREE) 
			mole_LED <= 4'b0010; 
		else if(mole_position == MOVE_FOUR) 
			mole_LED <= 4'b0001; 
		else                                 //Default case (never happens) 
			mole_LED <= 4'b0001; 
		//VGA screen signal doesn't change, will stay in game_screen 
	end 
	CHECK: begin 
		//VGA screen signal doesn't change, will stay in game_screen 
		// will automatically transitiion to the right state if time runs out
		if(key_signal == mole_position)  
			correct_hit <= 1'b1; 
		else
			correct_hit <= 1'b0; 
	end 
	TIME_UP: begin 
		//VGA screen signal doesn't change, will stay in game_screen 
		start_timer <= 1'b0; 
	end 
	INCREMENT_SCORE: begin 
		//VGA screen signal doesn't change, will stay in game_screen 
		mole_LED <= 4'd0; //display no moles 
		start_timer <= 1'b0; 
		 
		if(score == 4'd9) 
			score_ten <= 1'b1; //turn signal on to indicate 10 points reached --> will update state 
		else 
			score_ten <= 1'b0; //make sure signal is off
		score <= score + 1;
		correct_hit <= 1'b0; //ALWAYS turn off the correct_hit signal 
	end 
	GAME_OVER: begin 
		start_game <= 1'b0; 
		vga_display_screen_signal <= END_SCREEN; 
		//this doesn't turn score_ten signal off. No reason to do that. 
	end 
	default: vga_display_screen_signal <= START_SCREEN; //idek 
	endcase ///////////end case
	end //ends the else statement 
end //end the FSM always block 



/*****************************************************************************
 *                               Sequetial Logic                             *
 *****************************************************************************/
/*Notes: 
	- no fucking idea what is implemented in this section or if it's needed
*/

// latch choice of timing once per mole
reg [1:0] random_selector_latched;

always @(posedge CLOCK_50) begin
    if (reset) begin
        random_selector_latched <= 2'd0;
    end else if (current_state == IDLE && next_state == DELAY) begin
        // we are just now moving into DELAY ? pick a fresh random
        random_selector_latched <= random[1:0];
    end
end



//update states
always @(posedge CLOCK_50) begin
    if (reset)
        current_state <= LEVEL_CHOICE;
    else
        current_state <= next_state;
end


always @(posedge CLOCK_50) begin
    if (reset) begin
        countDownGameTime <= 6'd60;
    end 
    else if (start_game && count_down && countDownGameTime != 0) begin
        // timer says "one second passed" (or whatever duration), decrement
        countDownGameTime <= countDownGameTime - 6'd1;
    end
    // else: hold value
end
/*****************************************************************************
 *                              Combinational Logic                          *
 *****************************************************************************/
/*Notes: 
	- random selector logic 
	- next state logic for game FSM 
*/

/* Next state logic (FOR GAME FSM) implementation. Things to know: 
	- states (current_state, next_state, parameters) defined near FSM blcok 
	- time_up, correct_hit, score_ten = 1 bit reg wires each 
	- the time_up, correct_hit, score_ten are all driven in the FSM 

*/
always @(*) begin
	if(countDownGameTime == 6'b0 && start_game == 1'b1) begin 
		next_state = GAME_OVER;
	end 

	else begin
        case(current_state)  ///////////start case
	LEVEL_CHOICE: begin 
		if(key_signal != key1 && key_signal != key2 && key_signal != key3) //wrong key for levels picekd (stay in the same state) 
			next_state = current_state; 		
		else 
			next_state = START_DISPLAY; 
	end 
	START_DISPLAY: begin 
		if(startKey) 
		next_state = IDLE; 
		else 
		next_state = current_state; 
	end 
	IDLE: begin 
		next_state = DELAY; 
	end 
	DELAY: begin
		if(time_up_mole_delay)  //if enough time for the randomly generated delay has passed 
			next_state = SPAWN; 
		else 
			next_state = DELAY; 
	end 
	SPAWN: begin //instantly spawn the mole when at this stage 
		next_state = CHECK; 
	end 
	CHECK: begin 
		if(time_up_mole_display)
		next_state = TIME_UP; 
		else if(correct_hit) 
		next_state = INCREMENT_SCORE; 
		else //the time isn't up and the user hasn't hit the mole yet 
		next_state = CHECK; //remain in this state 
	end 
	TIME_UP: begin 
		next_state = IDLE; 
	end 
	INCREMENT_SCORE: begin 
		if(score_ten) 
		next_state = GAME_OVER; 
		else //there hasn't been 10 hits yet 
		next_state = IDLE; 
	end 
	GAME_OVER: begin 
		next_state = GAME_OVER; //remain in this state indefintely until the R key is hit 
	end 
	default: next_state = current_state; 
        endcase /////////////////end case 
	
	end //end the else statement
end //end the FSM combinational next state logic block 


/* Random selectors --> determines 2 time values, and the mole position 
	- mole_timer is the time that the mole will be on screen without registering the correct hit 
	- mole_delay is the time between the mole apperance and the next mole apperance
	- the random_selector is driven by an LSFR 
*/

reg [27:0] mole_timer, mole_delay; //28 bits, can store 150 mil, can store up to 3 seconds 

always @(*) begin
	/* Random time selection */
	if(level == LEVEL_ONE) begin
	case (random_selector_latched)
		//options from 0.15s, 0.33s, 0.5s (i.e. counter from 12.5 mil, 16.6mil, 25 mil)
		2'd1: begin mole_timer = 28'd12500000; mole_delay = 28'd16600000; 	end //Display: 0.15s  Delay: 0.33s  
		2'd2: begin mole_timer = 28'd16600000; mole_delay = 28'd25000000;  	end //Display: 0.33s  Delay: 0.5s 
		2'd3: begin mole_timer = 28'd25000000; mole_delay = 28'd12500000;  	end //Display: 0.5s  Delay: 0.33s 
		default: begin mole_timer = 28'd12500000; mole_delay = 28'd25000000; 	end //Display: 0.15s  Delay: 0.5s 
	endcase 
	end  
	else if(level == LEVEL_THREE) begin //options from 2.0s, 2.5s, 3.0s (i.e. counter from 100mil mil, 125mil,  150mil)
	case (random_selector_latched)
		2'd1: begin mole_timer = 28'd100_000_000; mole_delay = 28'd125_000_000; 	end //Display: 2.0s  Delay: 2.5s 
		2'd2: begin mole_timer = 28'd150_000_000; mole_delay = 28'd100_000_000;  	end //Display: 3.0s  Delay: 2.0s 
		2'd3: begin mole_timer = 28'd125_000_000; mole_delay = 28'd150_000_000;  	end //Display: 2.5s  Delay: 3.0s 
		default: begin mole_timer = 28'd125_000_000; mole_delay = 28'd100_000_000; 	end //Display: 2.5s  Delay: 2.0s 
	endcase 
	end
	else begin //covers cases level two and default. Both the smae
	case (random_selector_latched)
		2'd1: begin mole_timer = 28'd25000000; mole_delay = 28'd75000000; 	end //Display: 0.5s  Delay: 1.5s 
		2'd2: begin mole_timer = 28'd50000000; mole_delay = 28'd50000000;  	end //Display: 1.0s  Delay: 1.0s 
		2'd3: begin mole_timer = 28'd75000000; mole_delay = 28'd50000000;  	end //Display: 1.5s  Delay: 1.0s 
		default: begin mole_timer = 28'd25000000; mole_delay = 28'd25000000; 	end //Display: 0.5s  Delay: 0.5s 
	endcase
	end

	/* Random mole pop up */
	case(random_selector_latched)
		2'd0: begin mole_position = MOVE_ONE; 	end
		2'd1: begin mole_position = MOVE_TWO; 	end
		2'd2: begin mole_position = MOVE_THREE; end
		2'd3: begin mole_position = MOVE_FOUR; 	end
		default: mole_position = MOVE_ONE;	 //default case 
	endcase

end





/*****************************************************************************
 *        Connections to other moduels and Outputs/Assignments               *
 *****************************************************************************/
/*Notes: 
	- connections to modules like: random num gen, hex display, vga, keyboard
	- assign the outputs (right now, moles and vga output) 
		- later, this would be whatever is needed for VGA output, score display on hex, sounds, etc. 
*/


assign LEDR[9:4] = 6'b0;  //unused leds
assign LEDR[3:0] = mole_LED; //display the moles on the LEDs 
assign VGA_output = vga_display_screen_signal; //later put this score on HEX 5
assign scoreDisplay = score; //later put this score on HEX 1 and 0 
assign gameTimer = countDownGameTime; 

// Instantiate random number generator
randomNumGen #(16'hBEEF) rng (
       .reset(reset),
       .clk(CLOCK_50),
       .seed(random)
);

    // Instantiate Timer duration
timer mole_display_timer (
        .clk(CLOCK_50),
	.start(start_timer),
        .reset(reset),
        .duration(mole_timer),  // Pass the current duration to the timer
        .time_up(time_up_mole_display)
);

timer mole_delay_timer  (
        .clk(CLOCK_50),
	.start(start_delay), 
        .reset(reset),
        .duration(mole_delay),  // Pass the current duration to the timer
        .time_up(time_up_mole_delay)
);

timer game_count_down  (
        .clk(CLOCK_50),
	.start(start_game), 
        .reset(reset),
        .duration(28'd50000000),  // Pass the current duration to the timer
        .time_up(count_down)
);


endmodule









/*Planning stuff 
states: 
IDLE, DELAY, SPAWN, CHECK, TIME_UP, INCREMENT_SCORE, GAME_OVER, START_DISPLAY  

START_DISPLAY --> the inital state, user presses S to start the game and transition into idle state
IDLE --> resets some logic, removes moles from the screen
DELAY --> generates a random hole, random delay for mole spawning, random time for how long the mole stays 
SPAWN --> spawns the mole in the chosen hole at the chosen time, begins a counter once mole is spawned 
CHECK --> waits for either the timer set in spawn state to go up, or for the user to register the correct hit (keyboard key) 
TIME_UP --> state triggered if timer set in spawn state goes up before the user can register a hit, goes to idle state
INCREMENT_SCORE --> increments the score counter by one if correct thing hit 
GAME_OVER --> if score == 10, ends the game and displays the right screen, transitions to start state if user hits R

Notes: 
	- must implement some sort of debounce logic for the keys 
	- signal for wrong hit --> lights up an LED (or later a sound)
	- display the score on a seven seg display 
Upgrades: 
	- 3 levels, with 3 different times 
	- keyboard inputs 1, 2, 3 will start different levels of the game 
	Level 1 
		- 0.15 -> 0.5 seconds 
	Level 2 
		- 0.5 -> 1.5 seconds 
	Level 3 
		- 1.5 -> 3 seconds 




*/
