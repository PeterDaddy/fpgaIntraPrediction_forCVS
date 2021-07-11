`include "cs_constants.v"

module cs_y_buffer
(
	input  [`PACKET_LEN-1:0]  	y_packed_in, //steam per block
	
	output [`DATA_WIDTH-1:0]  	y_0_out,
	output [`DATA_WIDTH-1:0]  	y_1_out,
	output [`DATA_WIDTH-1:0]  	y_31_out
);

assign y_0_out  = y_packed_in[`DATA_WIDTH*0  +: `DATA_WIDTH];//1
assign y_1_out  = y_packed_in[`DATA_WIDTH*1  +: `DATA_WIDTH];//2
assign y_31_out = y_packed_in[`DATA_WIDTH*2 +: `DATA_WIDTH];//32
endmodule
