`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:52:08 04/23/2019 
// Design Name: 
// Module Name:    time_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// when clk counts up to here, 1 second has passed
`define 1_SEC_CLK_COUNT 27'd100000000 -1

module time_counter(
	output reg [4:0] hours_tens,
	output reg [4:0] hours_ones,
	output reg [4:0] minutes_tens,
	output reg [4:0] minutes_ones,
	output reg [4:0] seconds_tens,
	output reg [4:0] seconds_ones,
	input wire rst,
   input wire sys_clk
   );

	// clock divider
	reg [27:0] divclk;
	
	always @(posedge sys_clk, posedge rst) 	
		begin							
			if (rst || divclk == `1_SEC_CLK_COUNT)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end		
	// time counter
	
	reg [5:0] curr_hours;
   reg [6:0] curr_minutes;
   reg [6:0] curr_seconds;
			
	always @(posedge rst, posedge sys_clk)
		begin
			
			if(rst)
				begin
					curr_hours <= 6'd4;
					curr_minutes <= 7'd34;
					curr_seconds <= 7'd40;
				end
			else if(divclk == `1_SEC_CLK_COUNT)
				begin
					if(curr_seconds < 6'd59)
						begin
							curr_seconds <= curr_seconds + 1;
						end
					else if(curr_minutes < 6'd59)
						begin
							// roll over seconds
							curr_seconds <= 0;
							curr_minutes <= curr_minutes + 1;
						end
					else if(curr_hours < 24)
						begin
							// roll over minutes
							curr_seconds <= 0;
							curr_minutes <= 0;
							curr_hours <= curr_hours + 1;
						end
					else
						begin
							curr_seconds <= 0;
							curr_minutes <= 0;
							curr_hours <= 0;
						end
				end
		end
		
	// divider
	
	// modules
	
	reg hours_divider_start;
	reg hours_divider_ack;
	wire hours_divider_done;
	wire [4:0] hours_divider_quotient;
	wire [4:0] hours_divider_remainder;
	
	divider hours_divider(
		.Xin({1'b0, curr_hours}),
		.Yin(7'd10),
		.Start(hours_divider_start),
		.Ack(hours_divider_ack),
		.Clk(sys_clk),
		.Reset(rst),
		.Done(hours_divider_done),
		.Quotient(hours_divider_quotient),
		.Remainder(hours_divider_remainder)
	);
	
	reg minutes_divider_start;
	reg minutes_divider_ack;
	wire minutes_divider_done;
	wire [4:0] minutes_divider_quotient;
	wire [4:0] minutes_divider_remainder;
	
	divider minutes_divider(
		.Xin(curr_minutes),
		.Yin(7'd10),
		.Start(minutes_divider_start),
		.Ack(minutes_divider_ack),
		.Clk(sys_clk),
		.Reset(rst),
		.Done(minutes_divider_done),
		.Quotient(minutes_divider_quotient),
		.Remainder(minutes_divider_remainder)
	);
	
	
	reg seconds_divider_start;
	reg seconds_divider_ack;
	wire seconds_divider_done;
	wire [4:0] seconds_divider_quotient;
	wire [4:0] seconds_divider_remainder;
	
	divider seconds_divider(
		.Xin(curr_seconds),
		.Yin(7'd10),
		.Start(seconds_divider_start),
		.Ack(seconds_divider_ack),
		.Clk(sys_clk),
		.Reset(rst),
		.Done(seconds_divider_done),
		.Quotient(seconds_divider_quotient),
		.Remainder(seconds_divider_remainder)
	);
	
	
	// states
	localparam WAIT=2'd0, LOAD=2'd1, DIVIDE=2'd2;
	
	reg[2:0] state;
	
	always @(posedge sys_clk, posedge rst)
		begin
			if(rst)
				begin
					state <= WAIT;
					
					// initialize divider params
					hours_divider_start <= 1'b0;
					hours_divider_ack <= 1'b0;
					minutes_divider_start <= 1'b0;
					minutes_divider_ack <= 1'b0;
					seconds_divider_start <= 1'b0;
					seconds_divider_ack <= 1'b0;
					
					// initialize output registers
					hours_tens <= 5'd0;
					hours_ones <= 5'd0;
					minutes_tens <= 5'd0;
					minutes_ones <= 5'd0;
					seconds_tens <= 5'd0;
					seconds_ones <= 5'd0;
				end
			else
				begin
					case(state)
						WAIT:
							begin
							
								// reset acknowledges from last DIVIDE state
								hours_divider_ack <= 1'b0;
								minutes_divider_ack <= 1'b0;
								seconds_divider_ack <= 1'b0;

							
								// wait for the next second tick
								if(divclk == `1_SEC_CLK_COUNT)
								begin
									state <= LOAD;
								end
							end
						LOAD:
							begin
								// start all dividers
								hours_divider_start <= 1'b1;
								minutes_divider_start <= 1'b1;
								seconds_divider_start <= 1'b1;
								
								state <= DIVIDE;

							end
						DIVIDE:
							begin
							
								// remove the start signals
								hours_divider_start <= 1'b0;
								minutes_divider_start <= 1'b0;
								seconds_divider_start <= 1'b0;

							
								// wait for all dividers to be done
								if(hours_divider_done && minutes_divider_done && seconds_divider_done)
									begin
									
										// acknowledge
										hours_divider_ack <= 1'b1;
										minutes_divider_ack <= 1'b1;
										seconds_divider_ack <= 1'b1;
										
										// save results
										hours_tens <= hours_divider_quotient;
										hours_ones <= hours_divider_remainder;
										
										minutes_tens <= minutes_divider_quotient;
										minutes_ones <= minutes_divider_remainder;
										
										seconds_tens <= seconds_divider_quotient;
										seconds_ones <= seconds_divider_remainder;
										
										// wait for next second
										state <= WAIT;
										
									end
							end
							
								
					endcase
				end
		end
	
endmodule
