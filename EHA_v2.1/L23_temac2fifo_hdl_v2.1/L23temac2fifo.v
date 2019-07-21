`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: L23temac2fifo_v2
// Project Name: L23buffer_v2 
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

module L23temac2fifo (
input L23_clk,	//shared wire
input L23_rst,	//shared wire

//AXI-stream input ports
input [7:0] L23i_tdata,
input L23i_tlast,
input L23i_tuser,
output L23i_tready,
input L23i_tvalid,

//AXI-stream output ports
output [7:0] L23o_tdata,
output L23o_tlast,
output L23o_tuser,
input L23o_tready,
output L23o_tvalid
);

//IDLE STATE (DO NOTHING)
parameter IDLE = 1'b0;
//TUSER STATE (GENERATION OF TUSER SIGNAL IS PENDING)
parameter TUSER = 1'b1;

reg state;

// Control state machine implementation 
always@(posedge L23_clk)
  begin
    if(L23_rst)
      begin
        state <= IDLE;	/*Initial state is IDLE*/
	  end
  else
    begin
     case(state)
       IDLE: if(L23i_tvalid && !L23o_tready) 
            begin 
              state <= TUSER; 
            end
           else
            begin
              state <= IDLE;
            end
	   TUSER: if(L23i_tvalid && L23o_tready && L23i_tlast)
			begin
			  state <= IDLE;
			end
		   else
			begin
			  state <= TUSER;
			end
     endcase
    end
 end

 assign L23o_tuser = (((state == TUSER) && (L23i_tvalid) && (L23o_tready) && (L23i_tlast)) || (L23i_tuser)); 
 assign L23o_tvalid = L23i_tvalid;
 assign L23o_tlast = L23i_tlast;
 assign L23o_tdata = L23i_tdata;
 assign L23i_tready = L23o_tready;
  
endmodule

