`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:15:08 04/23/2019 
// Design Name: 
// Module Name:    digit_display 
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

// spacing in pixels
`define FRONT_PADDING 10
`define DIGIT_PADDING 2

// pixel timing
`define CLOCKS_PER_PIXEL 27'd20000000 - 1


module digit_display(
    input wire [4:0] hours_tens,
    input wire [4:0] hours_ones,
    input wire [4:0] minutes_tens,
    input wire [4:0] minutes_ones,
    input wire [4:0] seconds_tens,
    input wire [4:0] seconds_ones,
	 
	 input wire sys_clk,
	 input wire trigger,
	 input wire rst
    );
	 
	 wire [4:0] digits [6:0];
	
	assign digits[0] = seconds_ones;
	assign digits[1] = seconds_tens;
	assign digits[2] = minutes_ones;
	assign digits[3] = minutes_tens;	
	assign digits[4] = hours_ones;
	assign digits[5] = hours_tens;
	
	// clock divider
	reg [27:0] divclk;
	
	always @(posedge board_clk, posedge Reset) 	
		begin							
			if (Reset || divclk == CLOCKS_PER_PIXEL)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end
	
	// state machine for displaying numbers
	integer digit_counter;
	integer pad_counter;
	reg [3:0] state;
	
	localparam 	WAIT = 3'd0, RIGHT_PAD = 3'd1, DIGIT = 3'd2, DIGIT_PAD = 3'd3;

	always @(posedge rst, posedge sys_clk)
	begin
		if(rst)
			begin
				digit_counter <= 0;
				pad_counter <= 0;
				state <= 0;
			end
		
		case(state)
			WAIT:
				begin
					if(trigger)
						begin
							pad_counter <= 0;
							digit_counter <= 0;
							state <= RIGHT_PAD;
						end
				end
			RIGHT_PAD:
				begin
					
		endcase
		
		else if(divclk == CLOCKS_PER_PIXEL)
			begin
				
	end
	

endmodule
