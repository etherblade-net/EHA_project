`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: char_line_counters_wrapper
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

module char_line_counters_wrapper (
  input clk,
  input rst,
  input rd_char_incr, 
  input wr_char_incr,
  input rd_newline,
  input wr_newline,
//If "rd_restart_line" is required, uncomment this line  
//input rd_restart_line,
  input wr_restart_line,
  output rd_greenflag,
  output wr_greenflag,
  output tlast_flag,
  output [12:0] rd_ptr,
  output [12:0] wr_ptr
);

wire rd_char_setzero;
wire wr_char_setzero;

//If "rd_restart_line" is required, use this line
//assign rd_char_setzero = rd_newline || rd_restart_line;
assign rd_char_setzero = rd_newline;
assign wr_char_setzero = wr_newline || wr_restart_line;

//The purpose of this wrapper module is to make:
//signal "rd_newline" drive two signals "rd_char_setzero", "rd_line_incr" signals;
//signal "wr_newline" drive three signals "wr_char_setzero", "wr_line_incr", "tlast_we";
//signal "rd_restart_line" drive "rd_char_setzero" signal;
//signal "wr_restart_line" drive "wr_char_setzero" signal;

//Instantiation of "char_line_counters" module
char_line_counters char_line_counters1 (.clk(clk), .rst(rst), .rd_char_incr(rd_char_incr), .wr_char_incr(wr_char_incr), .rd_char_setzero(rd_char_setzero), .wr_char_setzero(wr_char_setzero),
.rd_line_incr(rd_newline), .wr_line_incr(wr_newline), .tlast_we(wr_newline), .rd_greenflag(rd_greenflag), .wr_greenflag(wr_greenflag), .tlast_flag(tlast_flag), .rd_ptr(rd_ptr), .wr_ptr(wr_ptr));

endmodule