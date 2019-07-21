`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: FSMs
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
input greenflag,		/*From CountersBlock*/
input lastflag,			/*From CountersBlock*/
input tready,			/*AXI-in*/   
output tvalid,			/*AXI-out - delayed*/
output tlast,			/*AXI-out - delayed*/
output rd_newline,		/*To CountersBlock*/	
output rd_char_incr		/*To CountersBlock*/
);

//IDLE (WAIT FOR GREENFLAG) STATE
parameter IDLE = 2'b00;
//READ FROM BUFFER STATE
parameter READ = 2'b01;

wire tvalid_nodelay;
wire tlast_nodelay;
reg tvalid;
reg tlast;

reg [1:0] state;

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
              state <= READ; 
            end
           else
            begin
              state <= IDLE;
            end
       READ: if(tready && lastflag) 
            begin 
              state <= IDLE; 
            end
           else
            begin
              state <= READ;
            end
     endcase
    end
 end

 //"tvalid" generation
 assign tvalid_nodelay = ((state == READ));
 //"tlast" generation
 assign tlast_nodelay = ((state == READ) && (tready) && (lastflag));
 //"rd_char_incr" generation
 assign rd_char_incr = ((state == READ) && (tready) && (!lastflag));
 //"rd_newline" generation
 assign rd_newline = ((state == READ) && (tready) && (lastflag));    
        
    // Delay the tvalid and tlast signal by one clock cycle                              
	// to match the latency of TDATA from BRAM                                                        
	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (rst)                                                                         
	    begin                                                                                      
	      tvalid <= 1'b0;                                                               
	      tlast <= 1'b0;                                                                
	    end                                                                                        
	  else if (tready)                                                                                         
	    begin                                                                                      
	      tvalid <= tvalid_nodelay;               
	      tlast <= tlast_nodelay;                                                          
	    end
//NOTE: If (~tready & ~rst) then (tvalid) and (tlast) remain unchanged.
	end         

 
endmodule