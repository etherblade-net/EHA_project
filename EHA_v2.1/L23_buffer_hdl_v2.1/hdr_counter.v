`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vladimir Efimov
// 
// Create Date: 11/11/2016 04:28:30 PM
// Design Name: 
// Module Name: hdr_counter
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

module hdr_counter (
  input clk,
  input rst,
  input set_zero, 
  input incr,
  input [5:0] ref_value_mgmt,
  output last_flag,
  output reg [5:0] rd_ptr
);

  wire setzero_or_rst;
 
//assign setzero_or_rst for sync reset 
 assign setzero_or_rst = set_zero || rst;
    
//RD_COUNTER
always @(posedge clk)
if (setzero_or_rst) begin
 rd_ptr <= 6'b0;
 end else if (incr) begin
 rd_ptr <= rd_ptr + 1;
 end

//Generate last_flag
  assign last_flag = (rd_ptr == ref_value_mgmt)? 1 : 0;                   

endmodule

