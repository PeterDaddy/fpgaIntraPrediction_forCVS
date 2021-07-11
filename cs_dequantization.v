`include "cs_constants.v"

module cs_dequantization
(
	input  [`BIT_SHIFT_WIDTH-1:0] bit_shift,
	input  [`PACKET_LEN-1:0] 		y_p,
	output reg [`PACKET_LEN-1:0] 	bit_stream
);

integer INDEX         = 0;

always@(y_p or bit_shift)
begin
	for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1)
	begin
		bit_stream[`DATA_WIDTH*INDEX +: `DATA_WIDTH] = y_p[`DATA_WIDTH*INDEX +: `DATA_WIDTH] << bit_shift;
	end
end

endmodule
