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
	/*Ld7, Ld6, Ld5, Ld4, Ld3, */Ld2, Ld1, Ld0,/* // 8 LEDs
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
	output 	Ld0, Ld1, Ld2; /*Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	*/
	
	// SPI
	output wire JA1, JA2, JA4;

	//motor encoder
	input wire JA3;
	
	/*  LOCAL SIGNALS */
	
	reg write_data;
	
	reg [7:0] led_r[7:0];
	reg [7:0] led_g[7:0];
	reg [7:0] led_b[7:0];
	
	// time
	wire [5:0] curr_hours;
   wire [6:0] curr_minutes;
   wire [6:0] curr_seconds;
	
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
		.mosi(JA1),
		.sclk(JA2),
		.write_data(write_data)
	);
	
	//------------
	// declare time counter
	
	wire [4:0] hours_tens;
	wire [4:0] hours_ones;
	wire [4:0] minutes_tens;
	wire [4:0] minutes_ones;
	wire [4:0] seconds_tens;
	wire [4:0] seconds_ones;	
	
	time_counter time_counter (
		.rst(Reset),
		.sys_clk(board_clk),
		.hours_tens(hours_tens),
		.hours_ones(hours_ones),
		.minutes_tens(minutes_tens),
		.minutes_ones(minutes_ones),
		.seconds_tens(seconds_tens),
		.seconds_ones(seconds_ones)
	);
	
	//------------
	// clock divider
	reg [27:0] divclk;
	
	
	// pixel timing
	`define CLOCKS_PER_PIXEL 27'd100000 - 1
	
	always @(posedge board_clk, posedge Reset) 	
		begin							
			if (Reset || divclk == `CLOCKS_PER_PIXEL)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end
		
	//------------
	// Generate PWM for motor controller
	assign JA4 = ~(divclk[16] && divclk[17]);
		
	//------------
	// Triggering logic
	// FOR NOW: just trigger at 100Hz
	//assign write_data = divclk[10]; // clock divide by 2^10 = 1024
	
	/*
	
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
		*/
		
	// spacing in pixels
	`define FRONT_PADDING 5'd31
	`define DIGIT_PADDING 4'd2
	
	// color of digits
	`define COL_R 8'h40;
	`define COL_G 8'h0;
	`define COL_B 8'h80;


	wire display_trigger;
	
	// TEMPORARY
	/*
	assign hours_tens = 4'd0;
	assign hours_ones = 4'd1;
	assign minutes_tens = 4'd2;
	assign minutes_ones = 4'd3;
	assign seconds_tens = 4'd4;
	assign seconds_ones = 4'd5;*/
	
	// trigger when the encoder reads the magnet
	assign display_trigger = ~JA3;

	
	// state machine for displaying numbers
	reg [3:0] digit_counter;
	reg [4:0] pixel_counter;
	reg [3:0] state;
	assign {Ld2, Ld1, Ld0} = state[3:0];
	
	localparam 	WAIT = 3'd0, RIGHT_PAD = 3'd1, DIGIT = 3'd2, DIGIT_PAD = 3'd3;

	always @(posedge Reset, posedge board_clk)
	begin
		if(Reset)
			begin
				digit_counter <= 3'b0;
				pixel_counter <= 4'b0;
				state <= 0;
				
				// blank lights
				for(index=0; index <= 7; index = index + 1)
					begin
						led_r[index] <= 8'b0;
						led_g[index] <= 8'b0;
						led_b[index] <= 8'b0;
					end
					
				write_data <= 1'b1;

			end
		else
			begin	
			case(state)
				WAIT:
					begin
						write_data <= 1'b0;
						if(display_trigger)
							begin
								pixel_counter <= 4'b0;
								digit_counter <= 3'b0;
								state <= RIGHT_PAD;
								write_data <= 1'b1;
							end
					end
				RIGHT_PAD:
					begin
						if(divclk == `CLOCKS_PER_PIXEL - 1)
							begin
								if(pixel_counter == `FRONT_PADDING)
									begin
										state <= DIGIT;
										pixel_counter <= 4'b0;
									end
								else
									begin
										pixel_counter <= pixel_counter + 4'b1;
									end
							end
					end
				DIGIT:
					begin : DISPLAY_DIGIT
					
						reg [4:0] digit;
						reg [7:0] vertical_pixels;


						if(divclk == `CLOCKS_PER_PIXEL - 1)
							begin
								if(pixel_counter == 4'd5)
									begin
										digit_counter <= digit_counter + 3'b1;
										
										if(digit_counter == 3'b1 || digit_counter == 3'd3)
											begin
												// add some padding
												state <= DIGIT_PAD;
											end
										else if(digit_counter == 3'd5)
											begin
												state <= WAIT;
											end
										else
											begin
												// move to next digit
												state <= DIGIT;
											end
										
										pixel_counter <= 4'b0;
									end
								else
									begin
										pixel_counter <= pixel_counter + 4'b1;
									end
							end
					
						
						case(digit_counter)
							3'd0:
								digit = seconds_ones;
							3'd1:
								digit = seconds_tens;
							3'd2:
								digit = minutes_ones;
							3'd3:
								digit = minutes_tens;
							3'd4:
								digit = hours_ones;
							default:
								digit = hours_tens;
						endcase
						
						vertical_pixels = 8'b0; // if we are past pixel 5, these will stay as zeros, which we want so we can add spacing
						
						case(digit)
							default:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00111110;
										4'd1:
											vertical_pixels = 7'b01000101;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01010001;
										4'd4:
											vertical_pixels = 7'b00111110;
									endcase
								end
								
							5'd1:
								case(pixel_counter)
									4'd0:
										vertical_pixels = 7'b01000000;
									4'd1:
										vertical_pixels = 7'b01111111;
									4'd2:
										vertical_pixels = 7'b01000010;
								endcase
							5'd2:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b01000110;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01010001;
										4'd3:
											vertical_pixels = 7'b01100001;
										4'd4:
											vertical_pixels = 7'b01000010;
									endcase
								end
							5'd3:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00110110;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01001001;
										4'd4:
											vertical_pixels = 7'b00100010;
									endcase
								end
							5'd4:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00010000;
										4'd1:
											vertical_pixels = 7'b01111111;
										4'd2:
											vertical_pixels = 7'b00010010;
										4'd3:
											vertical_pixels = 7'b00010100;
										4'd4:
											vertical_pixels = 7'b00011000;
									endcase
								end
							5'd5:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00110001;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01001001;
										4'd4:
											vertical_pixels = 7'b00101111;
									endcase
								end
							5'd6:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00110010;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01001001;
										4'd4:
											vertical_pixels = 7'b00111110;
									endcase
								end
							5'd7:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00000111;
										4'd1:
											vertical_pixels = 7'b00001001;
										4'd2:
											vertical_pixels = 7'b01110001;
										4'd3:
											vertical_pixels = 7'b00000001;
										4'd4:
											vertical_pixels = 7'b00111110;
									endcase
								end
							5'd8:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00110110;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01001001;
										4'd4:
											vertical_pixels = 7'b00110110;
									endcase
								end
							5'd9:
								begin
									case(pixel_counter)
										4'd0:
											vertical_pixels = 7'b00111110;
										4'd1:
											vertical_pixels = 7'b01001001;
										4'd2:
											vertical_pixels = 7'b01001001;
										4'd3:
											vertical_pixels = 7'b01001001;
										4'd4:
											vertical_pixels = 7'b00100110;
									endcase
								end
						endcase
						
						for(index=0; index <= 7; index = index + 1)
							begin
								if(vertical_pixels[7 - index])
									begin
										led_r[index] <= `COL_R;
										led_g[index] <= `COL_G;
										led_b[index] <= `COL_B;
									end
								else
									begin
										led_r[index] <= 8'b0;
										led_g[index] <= 8'b0;
										led_b[index] <= 8'b0;
									end
							end
						
						
					end
				DIGIT_PAD:
					begin
						if(divclk == `CLOCKS_PER_PIXEL - 1)
							begin
								if(pixel_counter == `DIGIT_PADDING - 1)
									begin
										state <= DIGIT;
										pixel_counter <= 4'd0;
									end
								else
									begin
										pixel_counter <= pixel_counter + 4'd1;
									end
							end
					end
			endcase
		end
				
	end
	

endmodule
