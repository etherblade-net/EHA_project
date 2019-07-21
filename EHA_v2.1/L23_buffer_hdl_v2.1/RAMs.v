`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: RAMs
// Project Name: L23buffer_v1 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Distributed Simple Dual port RAM, async read
module dual_port_asyncout_ram #(parameter D_WIDTH = 11, parameter A_WIDTH = 2)
(
    input clk,
    input we,
    input [(D_WIDTH-1):0] data,
    input [(A_WIDTH-1):0] read_addr, write_addr,
    output [(D_WIDTH-1):0] q
);

 reg [D_WIDTH-1:0] ram[2**A_WIDTH-1:0];

 always @ (posedge clk)
    begin
       if (we)
        ram[write_addr] <= data;
    end
assign q = ram[read_addr];
endmodule



//Block Simple Dual port RAM, syncronous read with output port enable signal.
module dual_port_syncout_enabled_ram #(parameter D_WIDTH=8, parameter A_WIDTH=13)
(
	input clk,
	input rst,
	input enableout,
	input we,
	input [(D_WIDTH-1):0] data,
	input [(A_WIDTH-1):0] read_addr,
	input [(A_WIDTH-1):0] write_addr,
	output reg [(D_WIDTH-1):0] q
);

(*ramstyle = "block"*)reg [D_WIDTH-1:0] ram[2**A_WIDTH-1:0];


always @(posedge clk) begin 
	if (we)
		ram[write_addr] <= data;
end

always @(posedge clk) begin                                                                                          
	  if (rst)                                                                         
	    begin                                                                                      
	      q <= {D_WIDTH{1'b0}};                                                                                                                         
	    end                                                                                    
	  else if (enableout)                                                                                         
	    begin
	    q <= ram[read_addr];                                                                                                                                     
	    end
//NOTE: If (~enableout & ~rst) then (q) remains unchanged.
            end  

endmodule

