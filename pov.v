`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:42:39 04/15/2019 
// Design Name: 
// Module Name:    pov 
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
module pov
	(MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS, // Disable the three memory chips
	ClkPort,                           // the 100 MHz incoming clock signal
	BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
	BtnC,                              // the center button (this is our reset in most of our designs)
	Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0, // 8 switches
	/*Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
	An3, An2, An1, An0,			       // 4 anodes
	Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
	Dp,       */                          // Dot Point Cathode on SSDs
	JA1, // SPI MOSI
	JA2, // SPI SCLK
	JA3, // Encoder index input
	JA4  // Motor PWM output
	);

	/*  INPUTS */
	// Clock & Reset I/O
	input		ClkPort;	
	// Project Specific Inputs
	input		BtnL, BtnU, BtnD, BtnR, BtnC;	
	input		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;
	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS;
	// Project Specific Outputs
	// LEDs
	/*output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	*/
	
	// SPI
	output wire JA1, JA2, JA3, JA4;

	
	/*  LOCAL SIGNALS */
	
	reg write_data;
	
	reg [7:0] led_r[7:0];
	reg [7:0] led_g[7:0];
	reg [7:0] led_b[7:0];
	
	//------------	
	// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS} = 5'b11111;
	
	//------------	
	// Use BtnC as reset button
	wire		Reset;
	assign Reset = BtnC;

	
	//------------
	// Set up board clock
	wire		board_clk;
	BUFGP BUFGP1 (board_clk, ClkPort); 	
	
	//------------
	// generate vectors to be passed as parameters
	
	reg [63:0] led_r_vector;
	reg [63:0] led_g_vector;
	reg [63:0] led_b_vector;

	integer index;
	always @* begin 
	  for(index=0; index <= 7; index = index + 1)
			begin
				led_r_vector[index*8 +: 8] <= led_r[index];
				led_g_vector[index*8 +: 8] <= led_g[index];
				led_b_vector[index*8 +: 8] <= led_b[index];
			end
	end
	
	//------------
	// declare LED driver
		
	led_driver led_driver (
		.rst(Reset), 
		.led_r_vector(led_r_vector),
		.led_g_vector(led_g_vector),
		.led_b_vector(led_b_vector),
		.sys_clk(board_clk),
		.mosi(JA3),
		.sclk(JA2),
		.write_data(write_data)
	);
	
	//------------
	// clock divider
	reg [25:0] divclk;
	
	always @(posedge board_clk, posedge Reset) 	
		begin							
			if (Reset)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end
		
	//------------
	// Generate PWM for motor controller
	assign JA1 = ~(divclk[16] && divclk[17]);
		
	//------------
	// Triggering logic
	// FOR NOW: just trigger at 100Hz
	//assign write_data = divclk[10]; // clock divide by 2^10 = 1024
	
	assign JA4 = 1'b1;
	
	initial
	begin
		led_r[0] = 8'h00;
		led_g[0] = 8'h00;
		led_b[0] = 8'h40;
    
		led_r[1] = 8'h20;
		led_g[1] = 8'h00;
		led_b[1] = 8'h40;
    	
		led_r[2] = 8'h40;
		led_g[2] = 8'h00;
		led_b[2] = 8'h20;
    
		led_r[3] = 8'h40;
		led_g[3] = 8'h00;
		led_b[3] = 8'h00;
    
		led_r[4] = 8'h40;
		led_g[4] = 8'h20;
		led_b[4] = 8'h00;
    
		led_r[5] = 8'h20;
		led_g[5] = 8'h40;
		led_b[5] = 8'h00;
    
		led_r[6] = 8'h00;
		led_g[6] = 8'h40;
		led_b[6] = 8'h00;
    
		led_r[7] = 8'h00;
		led_g[7] = 8'h20;
		led_b[7] = 8'h40;
        
		write_data = 1'b1;
			

		
	end

	always @(posedge divclk[21])
		begin: RAINBOW
			reg [7:0] temp_r;
			reg [7:0] temp_g;
			reg [7:0] temp_b;

			temp_r = led_r[7];
			temp_g = led_g[7];
			temp_b = led_b[7];

			for(index=0; index < 7; index = index + 1)
			begin
				led_r[index + 1] <= led_r[index];
				led_g[index + 1] <= led_g[index];
				led_b[index + 1] <= led_b[index];
			end
			
			led_r[0] <= temp_r;
			led_g[0] <= temp_g;
			led_b[0] <= temp_b;
		end
endmodule
