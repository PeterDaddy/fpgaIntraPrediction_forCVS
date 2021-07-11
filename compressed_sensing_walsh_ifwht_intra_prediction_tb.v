`timescale 1ns/1ps
`include "cs_constants.v"

module compressed_sensing_walsh_ifwht_intra_prediction_tb;
reg				RST;
reg				CLK;
reg	[2:0]    BIT_SHIFT;
reg	[1:0]    SAMPLING_RATE;
reg	[7:0]    COLUMNS;
reg	[7:0]    ROWS;
reg	[2047:0] PACKAGE_IN;
wire				IDLE_FLAG;
wire				DATA_AVAILABLE_FLAG;
wire	[2047:0] PACKAGE_OUT;
reg	[2:0]    PREDICTED_MODE;

reg				state;
reg   [15:0] 	buffer [0:3600-1];
reg   [15:0] 	memory [0:128-1][0:3600-1]; 
reg   [15:0] 	output_memory [0:128-1][0:1200-1]; 

compressed_sensing_walsh_ifwht_intra_prediction DUT(
	.CLK(CLK),
	.RST(RST),
	.BIT_SHIFT(BIT_SHIFT),
	.COLUMNS(COLUMNS),
	.PACKAGE_IN(PACKAGE_IN),
	.ROWS(ROWS),
	.SAMPLING_RATE(SAMPLING_RATE),
	.IDLE_FLAG(IDLE_FLAG),
	.DATA_AVAILABLE_FLAG(DATA_AVAILABLE_FLAG),
	.PACKAGE_OUT(PACKAGE_OUT),
	.PREDICTION_MODE(PREDICTION_MODE)
	);

integer i, j, SLOT, MODES, fd_mode;
integer INDEX   = 0;
integer INDEX_I = 0;
integer INDEX_J = 0;
integer INDEX_K = 0;
integer INDEX_LIMITED = 0;

reg [31:0] fd 		 [0:128-1];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

initial begin 
  MODES   	  	 = 2'b01;
  SAMPLING_RATE = 2'b10;
  BIT_SHIFT     = 3'b100;
  SLOT 		    = 0;
  
  //___READMEMH INITIALIZED___
  if(MODES == 2'b00) begin
	  INDEX_LIMITED = 64;
  end
  else if(MODES == 2'b01) begin
	  INDEX_LIMITED = 128;  
  end
  else if(MODES == 2'b10) begin
	  INDEX_LIMITED = 192;
  end
  else begin
	  INDEX_LIMITED = 0;
  end
  
  fd_mode = $fopen("C:/Users/Jay/Desktop/Research/FPGA_ASIC/DCC2019_FPGA_4_modes_intra_prediction/y_reconstruct/modes.dat", "w");
  
  for(i=0; i<=INDEX_LIMITED-1; i=i+1) begin
		$readmemb($sformatf("C:/Users/Jay/Desktop/Research/FPGA_ASIC/DCC2019_FPGA_4_modes_intra_prediction/y_source/TouchDown_y%0d.dat",i), buffer);
		fd[i]   = $fopen($sformatf("C:/Users/Jay/Desktop/Research/FPGA_ASIC/DCC2019_FPGA_4_modes_intra_prediction/y_reconstruct/TouchDown_y%0d.dat",i), "w");
		for (j=0; j<=3600-1; j=j+1) begin
			memory[i][j] = buffer[j];
		end
  end
end 
    
initial begin
  CLK = 1'b0;
  RST = 1'b0;
  repeat(4) #10 CLK = ~CLK;
  RST = 1'b1;
  forever #10 CLK = ~CLK; // generate a clock
  PREDICTED_MODE=0; 
end

initial begin
	@(negedge IDLE_FLAG)
	for(ROWS=0; ROWS<=45-1; ROWS=ROWS+1) begin
		for(COLUMNS=0; COLUMNS<=80-1; COLUMNS=COLUMNS+1) begin
			if(SLOT <= 3600-1) begin
				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin //LMB first
					PACKAGE_IN[`DATA_WIDTH*INDEX +: `DATA_WIDTH] = memory[INDEX][SLOT];
				end
				@(posedge DATA_AVAILABLE_FLAG)
				@(negedge IDLE_FLAG)
				PREDICTED_MODE=$urandom%3; 
//				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin
//					$display(`DATA_WIDTH*INDEX);
//					$fwrite(fd[INDEX],"%d\n", $signed(PACKAGE_OUT[`DATA_WIDTH*INDEX +: `DATA_WIDTH]));
//				end
//				$fwrite(fd_mode,"%d\n", PREDICTION_MODE);
				SLOT = SLOT+1;
			end
		end
	end
end
endmodule
