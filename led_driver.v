`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:16:15 04/12/2019 
// Design Name: 
// Module Name:    led_driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
// This class drives Adafruit DotStar LEDs.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define NUM_LEDS 8

module led_driver(

		input wire rst,
		input wire [7:0] led_r [`NUM_LEDS-1:0],
		input wire [7:0] led_g [`NUM_LEDS-1:0],
		input wire [7:0] led_b [`NUM_LEDS-1:0],
		input wire sys_clk,
		input wire write_data,

		// SPI pins
		output wire mosi,
		output wire sclk
    );

	// instantiate SPI module
	wire spi_done;
	reg spi_trigger;
	reg [31:0] spi_data_word;
	
	simple_spi_m_bit_rw
	#(
		.reg_width(32)
	) spi
	(
  	.module_clk(sys_clk),
		.t_start(spi_trigger),
		.d_in(spi_data_word),
		.d_out(),
		.t_size(6'd32),
		.cs(),
		.rst(rst),
		.spi_clk(sclk),
		.miso(1'b0),
		.mosi(mosi),
		.transmit_done(spi_done)
	);

	
	// state machine
	
	localparam 	RESET = 3'd0, START_FRAME = 3'd1, LED_FRAME = 3'd3, END_FRAME = 3'd4, DONE = 3'd5;
	
	reg [2:0] state;
	integer next_led;
	
	always @(posedge rst, posedge sys_clk)
		begin
			if(rst)
				begin
					spi_trigger <= 1'b0;
					state <= RESET;
				end
			else
				begin
					case(state)
					RESET:
						begin
							if(write_data)
								begin	
									state <= START_FRAME;
								end
						end
					START_FRAME:
						begin	
							state <= LED_FRAME;
							spi_data_word <= 32'h00000000;
							spi_trigger <= 1'b1;
							next_led <= 0;
						end
					LED_FRAME:
						begin
							spi_trigger <= 1'b0;
							
							if(spi_done)
								begin
									if(next_led == `NUM_LEDS)
										begin
											state <= END_FRAME;
											spi_data_word <= 32'hFFFFFFFF;
											spi_trigger <= 1'b1;
										end
									else
										begin
											
											// compose next data word
											spi_data_word <= {8'b11111111, led_b[next_led][7:0], led_g[next_led][7:0], led_r[next_led][7:0]};
											
											spi_trigger <= 1'b1;
											next_led <= next_led + 1;

										end


								end
						end
					END_FRAME:
						begin
							spi_trigger <= 1'b0;
							
							if(spi_done)
								state <= DONE;
						end
					DONE:
						if(write_data)
								state <= START_FRAME;
					endcase
				end
		end
endmodule
