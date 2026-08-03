module timer(clk, start, reset, duration, time_up);
	input clk; // System clock
	input start;            //timer only starts if this is high 
	input reset;          // Active high reset
	input [27:0] duration; // Custom duration in clock cycles (this could be driven by your FSM or other logic)
	output reg time_up;     // Timeout signal

    reg [27:0] counter;  // Counter register

    // Timer logic
    always @(posedge clk) begin
        if (reset || !start) begin
            counter <= 1'b0;
            time_up <= 1'b0;
        end 
	else if(start) begin
		if (counter == duration - 1) begin
            		counter <= 1'b0;
            		time_up <= 1'b1;  // Timeout occurs when the counter reaches the set duration
        	end 
		else begin
            		counter <= counter + 1;  // Increment the counter on each clock cycle
            		time_up <= 1'b0;  // Reset timeout until duration is met
       	 	end
	end //end the start if statemment 
    end //end the always block 

endmodule
