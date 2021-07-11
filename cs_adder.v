`include "cs_constants.v"

module cs_adder
(
	input  	  [`PACKET_LEN-1:0] a,
	input  	  [`DATA_WIDTH-1:0] b_0,
	input  	  [`DATA_WIDTH-1:0] b,
	output reg [`PACKET_LEN-1:0] c
);

integer INDEX;

always@(a or b or b_0)
begin
	for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1) begin
		if(INDEX==0) begin
			c[`DATA_WIDTH*INDEX +: `DATA_WIDTH] = a[`DATA_WIDTH*INDEX +: `DATA_WIDTH] + b_0;
		end
		else begin
			c[`DATA_WIDTH*INDEX +: `DATA_WIDTH] = a[`DATA_WIDTH*INDEX +: `DATA_WIDTH] + b;
		end
	end	
end
endmodule
