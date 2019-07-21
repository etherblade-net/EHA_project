`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: line_counters
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

module line_counters (
  input clk,
  input rst,
  input rd_line_incr, 
  input wr_line_incr,
  output rd_greenflag,
  output wr_greenflag,
  output [1:0] rd_line_ptr,
  output [1:0] wr_line_ptr
);

reg [2:0] tribit_rd_line_ptr;
reg [2:0] tribit_wr_line_ptr;

//RD_LINE_COUNTER
always @(posedge clk)
if (rst) begin
 tribit_rd_line_ptr <= 3'b0;
 end else if (rd_line_incr) begin
 tribit_rd_line_ptr <= tribit_rd_line_ptr + 1;
 end
 
//WR_LINE_COUNTER
always @(posedge clk)
if (rst) begin
 tribit_wr_line_ptr <= 3'b0;
 end else if (wr_line_incr) begin
 tribit_wr_line_ptr <= tribit_wr_line_ptr + 1;
 end

//output two LSBits out of tribit_rd_line_ptr 
 assign rd_line_ptr = tribit_rd_line_ptr[1:0];
//output two LSBits out of tribit_wr_line_ptr 
 assign wr_line_ptr = tribit_wr_line_ptr[1:0];

//"rd_greenflag" aka "not_empty"
//It is "0" when MSBits and other bits of "tribit_rd_line_ptr" and "tribit_wr_line_ptr" are equal
  assign rd_greenflag = ((tribit_wr_line_ptr[2] == tribit_rd_line_ptr[2]) &&                        
                         (tribit_wr_line_ptr[1:0] == tribit_rd_line_ptr[1:0])) ? 0 : 1;

//"wr_greenflag" aka "not_full"
//It is "0" when MSBits of "tribit_rd_line_ptr" and "tribit_wr_line_ptr" are not equal but other bits equal
  assign wr_greenflag = ((tribit_wr_line_ptr[2] != tribit_rd_line_ptr[2]) &&                        
                         (tribit_wr_line_ptr[1:0] == tribit_rd_line_ptr[1:0])) ? 0 : 1;
  
endmodule
