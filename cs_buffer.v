`include "cs_constants.v"

module cs_buffer
(
	input							 	  reset,
	input							 	  clk,
	input  	  [`PACKET_LEN-1:0] in,
	output reg [`PACKET_LEN-1:0] out
);

always @(posedge clk or negedge reset) 
begin
	if(~reset)
	begin
		out <= 0;
	end
	
	else
	begin
		out <= in;
	end
end
endmodule
