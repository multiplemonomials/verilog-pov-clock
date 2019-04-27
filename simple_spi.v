
// Simple Verilog SPI communication module
// Library taken as public domain from here: https://hackaday.io/project/119133-rops/log/144622-starting-with-verilog-and-spi

`timescale 1ms/1ms

/// SPI
module simple_spi_m_bit_rw
#(
	parameter reg_width = 8,
  parameter clock_divider = 32
)
(
	// System side
	input rst,
  input module_clk,
	input t_start,
	input [reg_width-1:0] d_in,
	input [$clog2(reg_width):0] t_size,
	output reg [reg_width-1:0] d_out,
	output reg transmit_done,

	// SPI side
	input miso,
	output wire mosi,
	output wire spi_clk,
	output reg cs
);
	parameter counter_width = $clog2(reg_width);
	parameter idle = 1, load = 2, transact = 3, unload = 4;

	reg [reg_width-1:0] mosi_d;
	reg [reg_width-1:0] miso_d;
	reg [counter_width:0] count;
	reg [2:0] state;
  reg bus_clk;
  
  // clock divider
	reg [25:0] divclk;
	
	always @(posedge module_clk, posedge rst) 	
		begin : clock_divider_block							
			if (rst)
				divclk <= 0;
			else if(divclk == clock_divider)
				divclk <= 0;
			else
				divclk <= divclk + 1'b1;
		end

  // state machine
	always @(posedge module_clk, posedge rst)
	begin
		if (rst)
      begin
        state <= idle;
        cs <= 1;
        d_out <= 0;
        transmit_done <= 0;
        bus_clk <= 0;
        mosi_d <= 0;
        count <= 0;
      end
		else
			case (state)
				idle:
				begin
          bus_clk <= 0;
          count <= reg_width;
          cs <= 0;
          transmit_done <= 0;

					if (t_start)
          begin
						state <= load;
          end
				end
				load:
        begin
					state <= transact;
          mosi_d <= d_in;
        end
        
				transact:
        begin
          if(divclk == clock_divider)
          begin
            bus_clk <= !bus_clk;
            
            if(bus_clk == 1'b1)
            begin
            
              // shift in next bit on falling edge
              count <= count - 2'd1;
              mosi_d <= {mosi_d[reg_width-2:0], 1'b0};

            end
          end
          
          if (count != 0)
            state <= transact;
          else
            state <= unload;
        end
				unload:
        begin
					if (t_start)
						state <= load;
					else
						begin
							state <= idle;
							transmit_done <= 1;
						end
        end
			endcase
	end
	// end state machine

	// begin SPI logic

	assign mosi = ( ~cs ) ? mosi_d[reg_width-1] : 1'bz;
	assign spi_clk = bus_clk;//( state == transact ) ? bus_clk : 1'b0;

	// end SPI logic

endmodule
