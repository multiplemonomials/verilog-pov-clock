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
	Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
	An3, An2, An1, An0,			       // 4 anodes
	Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
	Dp,                                 // Dot Point Cathode on SSDs
	JA0, // SPI MOSI
	JA1, // SPI SCLK
	JA2, // Encoder index input
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
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	
	
	// SPI
	output wire JA0, JA1;

	
	/*  LOCAL SIGNALS */
	
	reg write_data;
	
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
	// declare LED driver
	led_driver led_driver (
		.rst(Reset), 
		.led_r(led_r),
		.led_g(led_g),
		.led_b(led_b),
		.sys_clk(board_clk),
		.mosi(JA0),
		.sclk(JA1),
		.write_data(write_data)
	);
	
	//------------
	// clock divider
	reg [25:0] divclk;
	
	always @(posedge sys_clk, posedge Reset) 	
		begin							
			if (Reset)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end
		
	//------------
	// Triggering logic
	// FOR NOW: just trigger at 100Hz
	assign write_data = divclk[10]; // clock divide by 2^10 = 1024

endmodule
