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
    output reg [5:0] curr_hours,
    output reg [6:0] curr_minutes,
    output reg [6:0] curr_seconds,
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
		end;		
	// time counter
	
	reg [5:0] curr_hours;
   reg [6:0] curr_minutes;
   reg [6:0] curr_seconds;
		
	always @(posedge rst, posedge sys_clk)
		begin
			
			if(rst)
				begin
					curr_hours <= 0;
					curr_minutes <= 0;
					curr_seconds <= 0;
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
	
endmodule
