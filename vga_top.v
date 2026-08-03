/*
 * Displays 4 moles at fixed positions over the background.
 * Each mole shows white when mole_active[i] = 1,
 * and leaves the background intact when mole_active[i] = 0.
 *
 * KEY[0] = reset (active-low)
 */

module vga_top(
    input CLOCK_50,
    input [3:0] KEY,
    input [3:0] mole_active,   // From your FSM
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);

    parameter MOLE_SIZE = 20;
    parameter NUM_MOLES = 4;

    // VGA draw signals
    reg [9:0] XC;
    reg [8:0] YC;
    reg [8:0] color;
    reg write;

    reg [5:0] x_count;
    reg [5:0] y_count;
    reg [1:0] mole_index;

    reg [8:0] mole_color;

    // -----------------------------------------
    // Custom mole coordinates
    // -----------------------------------------
    wire [9:0] Mole_X [0:NUM_MOLES-1];
    wire [8:0] Mole_Y [0:NUM_MOLES-1];

    assign Mole_X[0] = 93;
    assign Mole_X[1] = 228;
    assign Mole_X[2] = 387;
    assign Mole_X[3] = 531;

    assign Mole_Y[0] = 320;
    assign Mole_Y[1] = 320;
    assign Mole_Y[2] = 320;
    assign Mole_Y[3] = 320;

    // -----------------------------------------
    // Initial values
    // -----------------------------------------
    initial begin
        mole_color = 9'b111_111_111; // white
        x_count    = 0;
        y_count    = 0;
        mole_index = 0;
        write      = 0;
    end

    // -----------------------------------------
    // Draw moles over background
    // -----------------------------------------
    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            x_count    <= 0;
            y_count    <= 0;
            mole_index <= 0;
            write      <= 0;
        end else begin
            // current pixel
				XC <= Mole_X[mole_index] + x_count;
				YC <= Mole_Y[mole_index] + y_count;

				// overwrite pixel color depending on mole state
				if (mole_active[3 - mole_index])
					 color <= 9'b111_111_111;  // mole visible = white
				else
					 color <= 9'b000_000_000;  // mole hidden = black

				write <= 1'b1;  // always write to ensure mole disappears when needed

            // Pixel stepping
            if (x_count < MOLE_SIZE - 1) begin
                x_count <= x_count + 1;
            end else begin
                x_count <= 0;
                if (y_count < MOLE_SIZE - 1) begin
                    y_count <= y_count + 1;
                end else begin
                    y_count <= 0;
                    if (mole_index < NUM_MOLES - 1)
                        mole_index <= mole_index + 1;
                    else
                        mole_index <= 0;
                end
            end
        end
    end

    // -----------------------------------------
    // VGA Adapter instance
    // -----------------------------------------
    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(color),
        .x(XC),
        .y(YC),
        .write(write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    defparam VGA.RESOLUTION = "640x480";
    defparam VGA.COLOR_DEPTH = 9;
    defparam VGA.BACKGROUND_IMAGE = "./black.mif"; // your original background

endmodule
