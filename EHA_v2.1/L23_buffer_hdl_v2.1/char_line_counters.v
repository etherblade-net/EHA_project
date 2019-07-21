`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: char_line_counters
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

module char_line_counters (
  input clk,
  input rst,
  input rd_char_incr, 
  input wr_char_incr,
  input rd_char_setzero,
  input wr_char_setzero,
  input rd_line_incr,
  input wr_line_incr,
  input tlast_we,
  output rd_greenflag,
  output wr_greenflag,
  output tlast_flag,
  output [12:0] rd_ptr,
  output [12:0] wr_ptr
);

  reg [10:0] rd_char_ptr;
  reg [10:0] wr_char_ptr;

  wire [1:0] rd_line_ptr;
  wire [1:0] wr_line_ptr;
  wire [10:0] rd_tlast_ptr;
  wire rd_setzero_or_rst;
  wire wr_setzero_or_rst; 

//assign rd_setzero_or_rst for sync reset 
 assign rd_setzero_or_rst = rd_char_setzero || rst;
  
 //assign wr_setzero_or_rst for sync reset 
 assign wr_setzero_or_rst = wr_char_setzero || rst;

//RD_CHAR_COUNTER
always @(posedge clk)
if (rd_setzero_or_rst) begin
 rd_char_ptr <= 11'b0;
 end else if (rd_char_incr) begin
 rd_char_ptr <= rd_char_ptr + 1;
 end

//WR_CHAR_COUNTER
always @(posedge clk)
if (wr_setzero_or_rst) begin
 wr_char_ptr <= 11'b0;
 end else if (wr_char_incr) begin
 wr_char_ptr <= wr_char_ptr + 1;
 end

//Instantiate tlast_pointers_array
dual_port_asyncout_ram #(11,2) tlast_pointers_array1 (.clk(clk), .we(tlast_we), .data(wr_char_ptr), .read_addr(rd_line_ptr), .write_addr(wr_line_ptr), .q(rd_tlast_ptr));

//Instantiate line_counters
line_counters line_counters1 (.clk(clk), .rst(rst), .rd_line_incr(rd_line_incr), .wr_line_incr(wr_line_incr), .rd_greenflag(rd_greenflag), .wr_greenflag(wr_greenflag),
.rd_line_ptr(rd_line_ptr), .wr_line_ptr(wr_line_ptr));

//Generate tlast_flag
  assign tlast_flag = (rd_tlast_ptr == rd_char_ptr)? 1 : 0;
                       
//output rd_ptr[12:0] as concatenation of rd_line_ptr[1:0] and rd_char_ptr[10:0]                       
  assign rd_ptr = {rd_line_ptr, rd_char_ptr};
//output wr_ptr[12:0] as concatenation of wr_line_ptr[1:0] and wr_char_ptr[10:0]
  assign wr_ptr = {wr_line_ptr, wr_char_ptr};

endmodule
