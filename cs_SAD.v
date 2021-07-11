`timescale 1ns/1ps
`include "cs_constants.v"

module cs_SAD
(
	input								  		rst,
	input								  		clk,
	input	 [`SAMP_WIDTH-1:0] 			sampling_mode,
	input  [`PACKET_LEN-1:0] 	  		y_in,
	input  [`DATA_WIDTH-1:0]     		y_p_left_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_up_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_dc_cand_0,
	input  [`DATA_WIDTH-1:0] 	  		y_p_left_cand,
	input  [`DATA_WIDTH-1:0] 	  		y_p_up_cand,
	input  [`DATA_WIDTH-1:0] 	  		y_p_dc_cand,
	
	output reg 						 	  	sad_busy_flag,
	output reg 						 	  	data_available_flag,
	output reg [`PACKET_LEN-1:0] 	  	y_residual,
	output reg [`PREDICTED_MODE-1:0] predicted_mode,
	output reg [`DATA_WIDTH-1:0] 	  	y_predicted_0,
	output reg [`DATA_WIDTH-1:0] 	  	y_predicted
);

reg [(`DATA_WIDTH*2)-1:0] sum_y_p_left_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_up_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_dc_cand;
reg [(`DATA_WIDTH*2)-1:0] sum_y_p_cp_cand;

reg [`DATA_WIDTH-1:0] tmp_y_p_left_cand [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_up_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_dc_cand 	 [0:`ARRAY_ROLLING-1];
reg [`DATA_WIDTH-1:0] tmp_y_p_cp_cand 	 [0:`ARRAY_ROLLING-1];
	
integer INDEX;
integer INDEX_I;
integer INDEX_II;
integer INDEX_III;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		for(INDEX_I=0;INDEX_I<=`ARRAY_ROLLING-1;INDEX_I=INDEX_I+1) begin
			tmp_y_p_left_cand[INDEX_I] <= 0;
			tmp_y_p_up_cand  [INDEX_I] <= 0;
			tmp_y_p_dc_cand  [INDEX_I] <= 0;
			tmp_y_p_cp_cand  [INDEX_I] <= 0;
		end
		INDEX_I					<= 0;
		sad_busy_flag 			<= 0; //Busy
	end
	else begin
		if(sampling_mode == 2'b00) begin
			if(INDEX_I <= 8-1) begin // Clock cycle
				sad_busy_flag 	  <= 1; //Busy
				for(INDEX_II=0;INDEX_II<=16-1;INDEX_II=INDEX_II+1) begin // paprallel
					if(INDEX_II==0)begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand_0);
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand_0);
						tmp_y_p_dc_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand_0);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
					else begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand);									
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand);
						tmp_y_p_dc_cand[INDEX_II]   <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
				end
				INDEX_I 				<= INDEX_I + 1;
			end
			else begin
				INDEX_I				<= 0;
				sad_busy_flag 	   <= 0; //IDLE
			end
		end
		
		else if(sampling_mode == 2'b01) begin
			if(INDEX_I <= 4-1) begin // Clock cycle
				sad_busy_flag 	  <= 1; //Busy
				for(INDEX_II=0;INDEX_II<=16-1;INDEX_II=INDEX_II+1) begin // paprallel
					if(INDEX_II==0)begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand_0);
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand_0);
						tmp_y_p_dc_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand_0);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
					else begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand);									
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand);
						tmp_y_p_dc_cand[INDEX_II]   <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
				end
				INDEX_I 				<= INDEX_I + 1;
			end
			else begin
				INDEX_I				<= 0;
				sad_busy_flag 	   <= 0; //IDLE
			end
		end
		
		else if(sampling_mode == 2'b10) begin
			if(INDEX_I <= 2-1) begin // Clock cycle
				sad_busy_flag 	  <= 1; //Busy
				for(INDEX_II=0;INDEX_II<=16-1;INDEX_II=INDEX_II+1) begin // paprallel
					if(INDEX_II==0)begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand_0);
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand_0);
						tmp_y_p_dc_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand_0);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
					else begin
						tmp_y_p_left_cand[INDEX_II] <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_left_cand);									
						tmp_y_p_up_cand[INDEX_II] 	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_up_cand);
						tmp_y_p_dc_cand[INDEX_II]   <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - y_p_dc_cand);
						tmp_y_p_cp_cand[INDEX_II]	 <= (y_in[(`DATA_WIDTH*(INDEX_I+(`CLOCK_CYCLE*INDEX_II))) +: `DATA_WIDTH] - 0);
					end
				end
				INDEX_I 				<= INDEX_I + 1;
			end
			else begin
				INDEX_I				<= 0;
				sad_busy_flag 	   <= 0; //IDLE
			end
		end
	end
end

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		sum_y_p_left_cand 	<= 0;
		sum_y_p_up_cand   	<= 0;
		sum_y_p_dc_cand 		<= 0;
		sum_y_p_cp_cand 		<= 0;
		data_available_flag  <= 0;
		y_residual <= 0;
		predicted_mode <= 0;
		y_predicted_0 <= 0;
		y_predicted  <= 0;
	end
	else begin
		if(sampling_mode == 2'b00) begin
			data_available_flag <= 0;
			if(sad_busy_flag == 1'b1 && data_available_flag == 1'b0) begin
				for(INDEX_III=0;INDEX_III<=16-1;INDEX_III=INDEX_III+1) begin
					sum_y_p_left_cand <= sum_y_p_left_cand + (tmp_y_p_left_cand[INDEX_III][`DATA_WIDTH-1] ? -tmp_y_p_left_cand[INDEX_III] : tmp_y_p_left_cand[INDEX_III]);
					sum_y_p_up_cand 	<= sum_y_p_up_cand   + (tmp_y_p_up_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_up_cand[INDEX_III] : tmp_y_p_up_cand[INDEX_III]);
					sum_y_p_dc_cand 	<= sum_y_p_dc_cand   + (tmp_y_p_dc_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_dc_cand[INDEX_III] : tmp_y_p_dc_cand[INDEX_III]);
					sum_y_p_cp_cand 	<= sum_y_p_cp_cand   + (tmp_y_p_cp_cand[INDEX_III][`DATA_WIDTH-1]	? -tmp_y_p_cp_cand[INDEX_III] : tmp_y_p_cp_cand[INDEX_III]);
				end
			end
			
			if (INDEX_I == 8) begin
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
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				else begin
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				
				for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1) begin
					if(INDEX == 0) begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted_0;
					end
					else begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted;
					end
				end
				data_available_flag <= 1;
			end
		end
		
		else if(sampling_mode == 2'b01) begin
			data_available_flag <= 0;
			if(sad_busy_flag == 1'b1 && data_available_flag == 1'b0) begin
				for(INDEX_III=0;INDEX_III<=8-1;INDEX_III=INDEX_III+1) begin
					sum_y_p_left_cand <= sum_y_p_left_cand + (tmp_y_p_left_cand[INDEX_III][`DATA_WIDTH-1] ? -tmp_y_p_left_cand[INDEX_III] : tmp_y_p_left_cand[INDEX_III]);
					sum_y_p_up_cand 	<= sum_y_p_up_cand   + (tmp_y_p_up_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_up_cand[INDEX_III] : tmp_y_p_up_cand[INDEX_III]);
					sum_y_p_dc_cand 	<= sum_y_p_dc_cand   + (tmp_y_p_dc_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_dc_cand[INDEX_III] : tmp_y_p_dc_cand[INDEX_III]);
					sum_y_p_cp_cand 	<= sum_y_p_cp_cand   + (tmp_y_p_cp_cand[INDEX_III][`DATA_WIDTH-1]	? -tmp_y_p_cp_cand[INDEX_III] : tmp_y_p_cp_cand[INDEX_III]);
				end
			end
			
			if (INDEX_I == 4) begin
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
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				else begin
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				
				for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1) begin
					if(INDEX == 0) begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted_0;
					end
					else begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted;
					end
				end
				data_available_flag <= 1;
			end
		end
		
		else if(sampling_mode == 2'b10) begin
			data_available_flag <= 0;
			if(sad_busy_flag == 1'b1 && data_available_flag == 1'b0) begin
				for(INDEX_III=0;INDEX_III<=4-1;INDEX_III=INDEX_III+1) begin
					sum_y_p_left_cand <= sum_y_p_left_cand + (tmp_y_p_left_cand[INDEX_III][`DATA_WIDTH-1] 	? -tmp_y_p_left_cand[INDEX_III] : tmp_y_p_left_cand[INDEX_III]);
					sum_y_p_up_cand 	<= sum_y_p_up_cand   + (tmp_y_p_up_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_up_cand[INDEX_III] : tmp_y_p_up_cand[INDEX_III]);
					sum_y_p_dc_cand 	<= sum_y_p_dc_cand   + (tmp_y_p_dc_cand[INDEX_III][`DATA_WIDTH-1]   ? -tmp_y_p_dc_cand[INDEX_III] : tmp_y_p_dc_cand[INDEX_III]);
					sum_y_p_cp_cand 	<= sum_y_p_cp_cand   + (tmp_y_p_cp_cand[INDEX_III][`DATA_WIDTH-1]	? -tmp_y_p_cp_cand[INDEX_III] : tmp_y_p_cp_cand[INDEX_III]);
				end
			end
			
			if (INDEX_I == 2) begin
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
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				else begin
					y_predicted_0  <= 16'b0000000000000000;
					y_predicted 	<= 16'b0000000000000000;
					predicted_mode <= 2'b11;
				end
				
				for(INDEX=0;INDEX<=`REG_BANK_DEPTH-1;INDEX=INDEX+1) begin
					if(INDEX == 0) begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted_0;
					end
					else begin
						y_residual[`DATA_WIDTH*INDEX +: `DATA_WIDTH] <= y_in[`DATA_WIDTH*INDEX +: `DATA_WIDTH] - y_predicted;
					end
				end
				data_available_flag <= 1;
			end
		end
	end
end
endmodule
