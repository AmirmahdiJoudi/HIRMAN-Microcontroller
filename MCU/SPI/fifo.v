`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/11/2023 10:04:41 AM
// Design Name:
// Module Name: fifo
// Project Name:
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




module fifo#
(
    parameter BUF_SIZE = 4
)
(
	input clk,
	input rst,
	input [7:0] buf_in,
	output reg [7:0] buf_out,
	input wr_en,
	input rd_en,
	output buf_empty,
	output buf_full
);






reg[4 :0]    fifo_counter;
reg[4 -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses
reg[7:0]              buf_mem[BUF_SIZE -1 : 0]; //

assign buf_empty = (fifo_counter==0) ? 1'b1 : 1'b0;   // Checking for whether buffer is empty or not
assign buf_full = (fifo_counter== BUF_SIZE) ? 1'b1 : 1'b0;  //Checking for whether buffer is full or not

//Setting FIFO counter value for different situations of read and write operations.
always @(posedge clk or posedge rst)
begin
   if( rst )
       fifo_counter <= 0;		// Reset the counter of FIFO

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )  //When doing read and write operation simultaneously
       fifo_counter <= fifo_counter;			// At this state, counter value will remain same.

   else if( !buf_full && wr_en )			// When doing only write operation
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )		//When doing only read operation
       fifo_counter <= fifo_counter - 1;

   else
      fifo_counter <= fifo_counter;			// When doing nothing.
end

always @( posedge clk or posedge rst)
begin
   if( rst )
      buf_out <= 0;		//On reset output of buffer is all 0.
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];	//Reading the 8 bit data from buffer location indicated by read pointer

      else
         buf_out <= buf_out;

   end
end

always @(posedge clk)
begin
   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;		//Writing 8 bit data input to buffer location indicated by write pointer

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge clk or posedge rst)
begin
   if( rst )
   begin
      wr_ptr <= 0;		// Initializing write pointer
      rd_ptr <= 0;		//Initializing read pointer
   end
   else
   begin
      if( !buf_full && wr_en )
			wr_ptr <= wr_ptr + 1;		// On write operation, Write pointer points to next location
      else
			wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )
			rd_ptr <= rd_ptr + 1;		// On read operation, read pointer points to next location to be read
      else
			rd_ptr <= rd_ptr;
   end

end
endmodule
