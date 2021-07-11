`include "cs_constants.v"

module cs_SAD55
(
	input								  		rst,
	input								  		clk,
	input  [`PACKET_LEN-1:0] 	  		y_in,
	input  [`DATA_WIDTH-1:0]     		y_p_left_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_up_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_dc_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_left_cand,
	input  [`DATA_WIDTH-1:0] 	  		y_p_up_cand,
	input  [`DATA_WIDTH-1:0] 	  		y_p_dc_cand,
	
	output reg 						 	  	SAD_busy_flag,
	output reg [`PACKET_LEN-1:0] 	  	y_residual,
//	output reg [`DATA_WIDTH-1:0] 	   y_predicted_0,
//	output reg [`DATA_WIDTH-1:0]     y_predicted,
	output reg [`PREDICTED_MODE-1:0] predicted_mode
);

reg [`DATA_WIDTH-1:0] 	  y_predicted_0;
reg [`DATA_WIDTH-1:0]     y_predicted;

reg [(`DATA_WIDTH*2)-1:0] sum_y_p_left_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_up_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_dc_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_cp_cand;

reg [`DATA_WIDTH-1:0] tmp_y_p_left_cand [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_up_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_dc_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_cp_cand 	 [0:`ARRAY_ROLLING-1];

reg [`DATA_WIDTH-1:0] abs_y_p_left_cand [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] abs_y_p_up_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] abs_y_p_dc_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] abs_y_p_cp_cand 	 [0:`ARRAY_ROLLING-1];

reg [`DATA_WIDTH-1:0] INDEX;
reg [`DATA_WIDTH-1:0] INDEX_I;
reg [`DATA_WIDTH-1:0] INDEX_II;
reg [`DATA_WIDTH-1:0] INDEX_III;
							
always@(posedge clk or negedge rst) begin
	if(~rst) begin
		y_predicted_0 		<= 0;
		y_predicted			<= 0;
		
		sum_y_p_left_cand <= 0;
		sum_y_p_up_cand   <= 0;
		sum_y_p_dc_cand   <= 0;
		sum_y_p_cp_cand   <= 0;
		for(INDEX_I=0;INDEX_I<=`ARRAY_ROLLING-1;INDEX_I=INDEX_I+1) begin
			tmp_y_p_left_cand[INDEX_I] <= 0;
			tmp_y_p_up_cand  [INDEX_I] <= 0;
			tmp_y_p_dc_cand  [INDEX_I] <= 0;
			tmp_y_p_cp_cand  [INDEX_I] <= 0;
			abs_y_p_left_cand[INDEX_I] <= 0;
			abs_y_p_up_cand  [INDEX_I] <= 0;
			abs_y_p_dc_cand  [INDEX_I] <= 0;
			abs_y_p_cp_cand  [INDEX_I] <= 0;
		end
		INDEX_I				<= 0;
		SAD_busy_flag 		<= 0; //Busy
		y_residual 			<= 0;
		y_predicted_0 		<= 0;
		y_predicted   		<= 0;
		predicted_mode		<= 0;
	end
	else begin
		if(INDEX_I <= `CLOCK_CYCLE-1) begin // Clock cycle
			SAD_busy_flag 	  <= 1; //busy
			if(INDEX_I == 0) begin
				for(INDEX_II=0;INDEX_II<=`ARRAY_ROLLING-1;INDEX_II=INDEX_II+1) begin // paprallel
					if(INDEX_II==0)begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand_0);
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand_0);
						tmp_y_p_dc_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand_0);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 16'b0111111110000000);
					end
					else begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand);									
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand);
						tmp_y_p_dc_cand[INDEX_II]   <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 16'b0011111111000000);
					end
				end
			end
			else begin
				for(INDEX_II=0;INDEX_II<=`ARRAY_ROLLING-1;INDEX_II=INDEX_II+1) begin // paprallel
					tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand);									
					tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand);
					tmp_y_p_dc_cand[INDEX_II]   <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand);
					tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 16'b0011111111000000);
				end
			end
			
			for(INDEX_III=0;INDEX_III<=`ARRAY_ROLLING-1;INDEX_III=INDEX_III+1) begin
				abs_y_p_left_cand[INDEX_III] <= (tmp_y_p_left_cand[INDEX_III][`DATA_WIDTH-1] ? -tmp_y_p_left_cand[INDEX_III] : tmp_y_p_left_cand[INDEX_III]);
				abs_y_p_up_cand[INDEX_III]   <= (tmp_y_p_up_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_up_cand[INDEX_III] : tmp_y_p_up_cand[INDEX_III]);
				abs_y_p_dc_cand[INDEX_III]   <= (tmp_y_p_dc_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_dc_cand[INDEX_III] : tmp_y_p_dc_cand[INDEX_III]);
				abs_y_p_cp_cand[INDEX_III]   <= (tmp_y_p_cp_cand[INDEX_III][`DATA_WIDTH-1]	  ? -tmp_y_p_cp_cand[INDEX_III] : tmp_y_p_cp_cand[INDEX_III]);
			end
			INDEX_I 				<= INDEX_I + 1;
		end
		else begin
			if((sum_y_p_left_cand < sum_y_p_up_cand) && (sum_y_p_left_cand < sum_y_p_dc_cand) && (sum_y_p_left_cand < sum_y_p_cp_cand)) begin
				y_predicted_0  <= y_p_left_cand_0;
				y_predicted 	<= y_p_left_cand;
				predicted_mode <= 2'b00;
			end
			else if((sum_y_p_up_cand  < sum_y_p_left_cand) && (sum_y_p_up_cand   < sum_y_p_dc_cand) && (sum_y_p_up_cand   < sum_y_p_cp_cand)) begin
				y_predicted_0  <= y_p_up_cand_0;
				y_predicted 	<= y_p_up_cand;
				predicted_mode <= 2'b01;
			end
			else if((sum_y_p_dc_cand  < sum_y_p_left_cand) && (sum_y_p_dc_cand 	< sum_y_p_up_cand) && (sum_y_p_dc_cand   < sum_y_p_cp_cand)) begin
				y_predicted_0  <= y_p_dc_cand_0;
				y_predicted 	<= y_p_dc_cand;
				predicted_mode <= 2'b10;
			end
			else if((sum_y_p_cp_cand  < sum_y_p_left_cand) && (sum_y_p_cp_cand 	< sum_y_p_up_cand) && (sum_y_p_cp_cand   < sum_y_p_dc_cand)) begin
				y_predicted_0  <= 16'b0111111110000000;
				y_predicted 	<= 16'b0011111111000000;
				predicted_mode <= 2'b11;
			end
			else begin
				y_predicted_0  <= 16'b0111111110000000;
				y_predicted 	<= 16'b0011111111000000;
				predicted_mode <= 2'b11;
			end
			
			for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1) begin
				if(INDEX==0) begin
					y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted_0;
				end
				else begin
					y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted;
				end
			end
			
			//RESET
			sum_y_p_left_cand <= 0;
			sum_y_p_up_cand   <= 0;
			sum_y_p_dc_cand   <= 0;
			sum_y_p_cp_cand   <= 0;
			INDEX_I				<= 0;
			SAD_busy_flag 		<= 0; //idle
		end
	end
end
endmodule
