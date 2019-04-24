`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:04:39 04/12/2019
// Design Name:   time_counter
// Module Name:   /mnt/hgfs/ee354/pov_project/time_counter_testbench.v
// Project Name:  pov_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: time_counter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module time_counter_testbench;
	
  reg rst;
  
	// clock generator
	reg Clk;
	
  initial 
		begin
			Clk = 0; // Initialize clock
    end
      
	always  
		begin 
      // 10 ns period = 100 MHz clock
			#5; 
			Clk = ~ Clk; 
		end

	//------------
	// declare time counter
	
	wire [4:0] hours_tens;
	wire [4:0] hours_ones;
	wire [4:0] minutes_tens;
	wire [4:0] minutes_ones;
	wire [4:0] seconds_tens;
	wire [4:0] seconds_ones;	
	
	time_counter time_counter (
		.rst(rst),
		.sys_clk(Clk),
		.hours_tens(hours_tens),
		.hours_ones(hours_ones),
		.minutes_tens(minutes_tens),
		.minutes_ones(minutes_ones),
		.seconds_tens(seconds_tens),
		.seconds_ones(seconds_ones)
	);
	
	initial begin
		// Initialize Inputs
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Start going
		rst = 0;

		
	end
      
endmodule

