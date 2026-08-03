module totalProject(
    CLOCK_50,
    LEDR,
    KEY,
    PS2_CLK,
    PS2_DAT,
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,

    // VGA outputs added here
    VGA_R,
    VGA_G,
    VGA_B,
    VGA_HS,
    VGA_VS,
    VGA_BLANK_N,
    VGA_SYNC_N,
    VGA_CLK
);


/*****************************************************************************
 *                             inputs/outputs/wires                          *
 *****************************************************************************/

//input
input CLOCK_50; 
input [3:0] KEY; 

//bidirectionals 
inout PS2_CLK;
inout PS2_DAT;

//output 
output [9:0] LEDR; 
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

// VGA outputs
output [7:0] VGA_R;
output [7:0] VGA_G;
output [7:0] VGA_B;
output VGA_HS;
output VGA_VS;
output VGA_BLANK_N;
output VGA_SYNC_N;
output VGA_CLK;


//wires/reg
wire [3:0] game_arrows;  
wire [2:0] VGA_screen_num; 
wire [3:0] score;
wire [5:0] timer; 

/*****************************************************************************
 *        Connections to other modules and Outputs/Assignments               *
 *****************************************************************************/

PS2_Demo U1(.CLOCK_50(CLOCK_50), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .game_arrows(game_arrows), .KEY(KEY));  
fsm U2(.CLOCK_50(CLOCK_50), .key_signal(game_arrows), .VGA_output(VGA_screen_num), .LEDR(LEDR), .scoreDisplay(score), .gameTimer(timer)); 

// score split into tens / ones
reg[3:0] scoreOnes, scoreTens; 

// timer split into tens / ones
reg [3:0] timeOnes, timeTens;

always @(*) begin
    // Score: 0?10 (you only ever reach 10)
    if (score >= 4'd10) begin
        scoreOnes = 4'd0;   // show "10"
        scoreTens = 4'd1;
    end else begin
        scoreOnes = score;
        scoreTens = 4'd0;
    end

    // Timer: 0?60
    // Simple BCD split: tens = timer / 10, ones = timer % 10
    timeTens = timer / 6'd10;
    timeOnes = timer % 6'd10;
end

// HEX2: turned off (blank)
assign HEX2[6:0] = 7'b1111111;

//display vga screen 
Hexadecimal_To_Seven_Segment vgaScreenNum(.hex_number({1'b0, VGA_screen_num}), .seven_seg_display(HEX3)); //will only ever be 0, 1, 2

//display score
Hexadecimal_To_Seven_Segment scoreH1 (.hex_number(scoreOnes), .seven_seg_display(HEX0));
Hexadecimal_To_Seven_Segment scoreH2 (.hex_number(scoreTens), .seven_seg_display(HEX1));


//display counter
Hexadecimal_To_Seven_Segment timeH4 (.hex_number(timeOnes), .seven_seg_display(HEX4));
Hexadecimal_To_Seven_Segment timeH5 (.hex_number(timeTens), .seven_seg_display(HEX5));

/*****************************************************************************
 *                             VGA MODULE HERE                               *
 *****************************************************************************/

vga_top VGA(
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .mole_active(LEDR[3:0]),   // <-- FSM mole outputs become VGA moles

    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK)
);

endmodule
