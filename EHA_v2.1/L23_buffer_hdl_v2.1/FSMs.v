`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 11/24/2016 12:53:27 PM
// Design Name: 
// Module Name: FSMs
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

module writebuf_fsm(
input clk,				/*Clock*/
input rst,				/*Reset*/
input greenflag,		/*From CountersBlock*/
input tvalid,			/*AXI-in*/   
input tlast,			/*AXI-in*/
input tuser,			/*AXI-in*/
output tready,			/*AXI-out*/
output wren,			/*To BRAM*/
output wr_newline,		/*To CountersBlock*/	
output wr_char_incr,	/*To CountersBlock*/
output wr_restart_line	/*To CountersBlock*/
);

//IDLE (WAIT FOR GREENFLAG) STATE
parameter IDLE = 1'b0;
//WRITE TO BUFFER STATE
parameter WRITE = 1'b1;

reg state;

// Control state machine implementation 
always@(posedge clk)
  begin
    if(rst)
      begin
        state <= IDLE;	/*Initial state is IDLE, wait for GREENFLAG*/
	  end
  else
    begin
     case(state)
       IDLE: if(greenflag) 
            begin 
              state <= WRITE; 
            end
           else
            begin
              state <= IDLE;
            end
       WRITE: if(tvalid && tlast) 
            begin 
              state <= IDLE; 
            end
		   else
            begin
              state <= WRITE;
            end
     endcase
    end
 end

 //"tready" generation
 assign tready = ((state == WRITE));
 //"wren" generation
 assign wren = ((state == WRITE) && (tvalid) && (!tuser));
 //"wr_char_incr" generation
 assign wr_char_incr = ((state == WRITE) && (tvalid) && (!tlast));
 //"wr_newline" generation
 assign wr_newline = ((state == WRITE) && (tvalid) && (tlast) && (!tuser));
 //"wr_restart_line" generation
 assign wr_restart_line = ((state == WRITE) && (tvalid) && (tlast) && (tuser));
 
endmodule



module readbuf_fsm(
input clk,				/*Clock*/
input rst,				/*Reset*/
input greenflag_input,	/*From CountersBlock*/
input hdr_lastflag,		/*From Hdr-counter*/
input lastflag,			/*From CountersBlock*/
input tready,			/*AXI-in*/
input run_mgmt,         /*External mgmt signal - RUN*/   
output reg tvalid,		/*AXI-out - delayed*/
output reg tlast,		/*AXI-out - delayed*/
output rd_newline,		/*To CountersBlock*/
output hdr_char_incr,	/*To Hdr-counter*/	
output rd_char_incr,	/*To CountersBlock*/
output reg mux_sel,		/*To Mux - delayed*/
output idle_mgmt        /*External mgmt signal - IDLE*/
);

//IDLE (WAIT FOR GREENFLAG) STATE
parameter IDLE = 2'b00;
//READ FROM HEADER MEMORY STATE
parameter READ_HDR = 2'b01;
//READ BODY FROM BUFFER STATE
parameter READ_BODY = 2'b10;


wire tvalid_nodelay;
wire tlast_nodelay;
wire mux_sel_nodelay;
wire greenflag;

reg [1:0] state;

//assign greenflag if green flag comes via greenflag_input and  active RUN management input 
assign greenflag = greenflag_input & run_mgmt;

// Control state machine implementation 
always@(posedge clk)
  begin
    if(rst)
      begin
        state <= IDLE;	/*Initial state is IDLE, wait for GREENFLAG*/
	  end
  else
    begin
     case(state)
       IDLE: if(greenflag) 
            begin 
              state <= READ_HDR; 
            end
           else
            begin
              state <= IDLE;
            end
       READ_HDR: if(tready && hdr_lastflag) 
            begin 
              state <= READ_BODY; 
            end
           else
            begin
              state <= READ_HDR;
            end
	   READ_BODY: if(tready && lastflag) 
            begin 
              state <= IDLE; 
            end
           else
            begin
              state <= READ_BODY;
            end
     endcase
    end
 end

 //"tvalid" generation
 assign tvalid_nodelay = ((state == READ_HDR) || (state == READ_BODY));
 //"tlast" generation
 assign tlast_nodelay = ((state == READ_BODY) && (tready) && (lastflag));
 //"mux_sel" generation
 assign mux_sel_nodelay = ((state == READ_BODY));
 //"hdr_char_incr" generation
 assign hdr_char_incr = ((state == READ_HDR) && (tready) && (!hdr_lastflag));
 //"rd_char_incr" generation
 assign rd_char_incr = ((state == READ_BODY) && (tready) && (!lastflag));
 //"rd_newline" generation
 assign rd_newline = ((state == READ_BODY) && (tready) && (lastflag));    
 //"idle_mgmt" generation
 assign idle_mgmt = ((state == IDLE));
          
    // Delay the tvalid, tlast and mux_sel signals by one clock cycle                              
	// to match the latency of TDATA from BRAMs                                                        
	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (rst)                                                                         
	    begin                                                                                      
	      tvalid <= 1'b0;                                                               
	      tlast <= 1'b0;                                                                
		  mux_sel <= 1'b0;
	    end                                                                                        
	  else if (tready)                                                                                         
	    begin                                                                                      
	      tvalid <= tvalid_nodelay;               
	      tlast <= tlast_nodelay;
		  mux_sel <= mux_sel_nodelay; 
	    end
//NOTE: If (~tready & ~rst) then (tvalid), (tlast) and (mux_sel) remain unchanged.
	end         
 
endmodule