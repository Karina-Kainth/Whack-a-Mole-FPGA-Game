// TA Alex's Code from youtube tutorial 
module randomNumGen #(parameter INITIAL_SEED=16'hBEEF) (
    input wire reset,
    input wire clk,
    output reg [15:0] seed
);

    wire next_bit;

    // Define next_bit using XOR for a Fibonacci LFSR
    assign next_bit = (seed[15] ^ seed[13] ^ seed[12] ^ seed[10]);

    always @(posedge clk) begin
        if (reset) begin
            seed <= INITIAL_SEED; // Reset to initial seed value
        end else begin
            seed <= {seed[14:0], next_bit}; // Shift left and insert next_bit
        end
    end

endmodule
