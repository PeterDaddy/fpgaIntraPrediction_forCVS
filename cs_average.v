`include "cs_constants.v"

module cs_average
(
	input							 rst,
	input							 clk,
	input	 						 sad_busy_flag,
	input	 						 data_available_flag,
	input	 [`ADDR_WIDTH-1:0] rows,
	input	 [`ADDR_WIDTH-1:0] columns,
	input  [`DATA_WIDTH-1:0] y_0,
	input  [`DATA_WIDTH-1:0] y_1,
	input  [`DATA_WIDTH-1:0] y_31,
	
	output reg [`DATA_WIDTH-1:0] y_p_left_out_0,
	output reg [`DATA_WIDTH-1:0] y_p_up_out_0,
	output reg [`DATA_WIDTH-1:0] y_p_dc_out_0,
	output reg [`DATA_WIDTH-1:0] y_p_left_out,
	output reg [`DATA_WIDTH-1:0] y_p_up_out,
	output reg [`DATA_WIDTH-1:0] y_p_dc_out
);

integer 					 INDEX;
reg [`DATA_WIDTH-1:0] memory [0:80-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_left_out_0;
reg [`DATA_WIDTH-1:0] tmp_y_p_left_out;
reg [`DATA_WIDTH-1:0] tmp_y_p_dc_out_0;
reg [`DATA_WIDTH-1:0] tmp_y_p_dc_out;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		for(INDEX=0;INDEX<=80-1;INDEX=INDEX+1) begin
			memory[INDEX] <= 0;
		end
		y_p_up_out_0	 	 <= 0;
		y_p_up_out      	 <= 0;
		tmp_y_p_left_out_0 <= 0;
		tmp_y_p_left_out	 <= 0;
		tmp_y_p_dc_out_0 	 <= 0;
		tmp_y_p_dc_out 	 <= 0;
	end
	else begin
		if (~sad_busy_flag) begin
			y_p_up_out_0	 <= memory[columns]/128*256;
			y_p_up_out      <= memory[columns]/128*128;
		end
		if (data_available_flag) begin
			memory[columns] <= y_0-y_1;
		end
		tmp_y_p_left_out_0 <= y_p_left_out_0;
		tmp_y_p_left_out	 <= y_p_left_out;
		tmp_y_p_dc_out_0 	 <= y_p_dc_out_0;
		tmp_y_p_dc_out 	 <= y_p_dc_out;
	end
end

always@(*) begin
	if(~sad_busy_flag) begin
		if(columns == 0) begin
			y_p_left_out_0  = 0;
			y_p_left_out	 = 0;
		end
		else begin
			y_p_left_out_0  = (y_0 - y_31)/128*256;
			y_p_left_out	 = (y_0 - y_31)/128*128;
		end
		y_p_dc_out_0		 = (y_p_up_out_0 + y_p_left_out_0)/2;
		y_p_dc_out			 = (y_p_up_out + y_p_left_out)/2;
	end
	else begin
		y_p_left_out_0  	 = tmp_y_p_left_out_0;
		y_p_left_out	 	 = tmp_y_p_left_out;
		y_p_dc_out_0		 = tmp_y_p_dc_out_0;
		y_p_dc_out			 = tmp_y_p_dc_out;
	end
end
endmodule



