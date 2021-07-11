`include "cs_constants.v"

module uart_interface_package_arrangement
(
	input 							   	 clk,
	input 							   	 rst,
	input							 	   	 SAD_busy_flag,
	
	input 							   	 tx_uart_ready,
	input	 [`UART_DATA_WIDTH-1:0] 	 tx_uart_data,
	input								   	 tx_uart_error,
	input								   	 tx_uart_valid,
	
	output reg [`UART_DATA_WIDTH-1:0] rx_uart_data,
	output reg 								 rx_uart_error,
	output reg								 rx_uart_valid,
	output reg							    rx_uart_ready,
	
	output reg [`BIT_SHIFT_WIDTH-1:0] bit_shift_parameter,
	output reg [`PACKET_LEN-1:0]  	 measurement_package,
	output reg [`ROWS_WIDTH-1:0]	    rows,
	output reg [`COLUMNS_WIDTH-1:0]   columns
);

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		rx_uart_ready 		  <= 0;
		rx_uart_data 		  <= 0;
		rx_uart_error 		  <= 0;
		rx_uart_valid 		  <= 0;
		bit_shift_parameter <= 0;
		measurement_package <= 0;
		rows 					  <= 0;
		columns 				  <= 0;
	end
	else begin
//		if() begin
//		end
//		else begin
//			rx_uart_ready 		  <= 0;
//			rx_uart_data 		  <= 0;
//			rx_uart_error 		  <= 0;
//			rx_uart_valid 		  <= 0;
//			bit_shift_parameter <= 0;
//			measurement_package <= 0;
//			rows 					  <= 0;
//			columns 				  <= 0;
//		end
	end
end
endmodule
