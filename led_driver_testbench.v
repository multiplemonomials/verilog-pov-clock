`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:04:39 04/12/2019
// Design Name:   led_driver
// Module Name:   /mnt/hgfs/ee354/pov_project/led_driver_testbench.v
// Project Name:  pov_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: led_driver
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module led_driver_testbench;

	// Inputs
	reg rst;
	reg [7:0] led_r[7:0];
	reg [7:0] led_g[7:0];
	reg [7:0] led_b[7:0];
	
	reg write_data;
	
	wire mosi;
	wire sclk;
	
	// clock generator
	reg Clk;
	
  initial 
		begin
			Clk = 0; // Initialize clock
    end
      
	always  
		begin 
			#10; 
			Clk = ~ Clk; 
		end

	// Instantiate the Unit Under Test (UUT)
	led_driver uut (
		.rst(rst), 
		.led_r(led_r),
		.led_g(led_g),
		.led_b(led_b),
		.sys_clk(Clk),
		.mosi(mosi),
		.sclk(sclk),
		.write_data(write_data)
	);

	initial begin
		// Initialize Inputs
		rst = 1;
		write_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 0;
		
		led_r[0] = 8'h80;
		led_g[0] = 8'h00;
		led_b[0] = 8'hFF;
    
    led_r[1] = 8'h80;
		led_g[1] = 8'h00;
		led_b[1] = 8'hFF;
    	
    led_r[2] = 8'h80;
		led_g[2] = 8'h00;
		led_b[2] = 8'hFF;
    
    led_r[3] = 8'h80;
		led_g[3] = 8'h00;
		led_b[3] = 8'hFF;
    
    led_r[4] = 8'h80;
		led_g[4] = 8'h00;
		led_b[4] = 8'hFF;
    
    led_r[5] = 8'h80;
		led_g[5] = 8'h00;
		led_b[5] = 8'hFF;
    
    led_r[6] = 8'h80;
		led_g[6] = 8'h00;
		led_b[6] = 8'hFF;
    
    led_r[7] = 8'h80;
		led_g[7] = 8'h00;
		led_b[7] = 8'hFF;
    
    #20
    
		write_data = 1'b1;
		
		#20
		write_data = 1'b0;
		
	end
      
endmodule

