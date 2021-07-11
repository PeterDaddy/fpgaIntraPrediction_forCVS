// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Fri Feb 19 05:01:43 2021"

module compressed_sensing_walsh_ifwht_intra_prediction(
	CLK,
	RST,
	BIT_SHIFT,
	COLUMNS,
	PACKAGE_IN,
	ROWS,
	SAMPLING_RATE,
	IDLE_FLAG,
	DATA_AVAILABLE_FLAG,
	PACKAGE_OUT,
	PREDICTION_MODE
);


input wire	CLK;
input wire	RST;
input wire	[2:0] BIT_SHIFT;
input wire	[7:0] COLUMNS;
input wire	[2047:0] PACKAGE_IN;
input wire	[7:0] ROWS;
input wire	[1:0] SAMPLING_RATE;
output wire	IDLE_FLAG;
output wire	DATA_AVAILABLE_FLAG;
output wire	[2047:0] PACKAGE_OUT;
output wire	[2:0] PREDICTION_MODE;

wire	[2047:0] SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	[15:0] SYNTHESIZED_WIRE_3;
wire	[15:0] SYNTHESIZED_WIRE_4;
wire	[15:0] SYNTHESIZED_WIRE_5;
wire	[15:0] SYNTHESIZED_WIRE_6;
wire	[15:0] SYNTHESIZED_WIRE_7;
wire	[15:0] SYNTHESIZED_WIRE_8;
wire	[15:0] SYNTHESIZED_WIRE_9;
wire	[15:0] SYNTHESIZED_WIRE_10;
wire	[15:0] SYNTHESIZED_WIRE_11;
wire	[2047:0] SYNTHESIZED_WIRE_12;
wire	[2047:0] SYNTHESIZED_WIRE_13;
wire	[2047:0] SYNTHESIZED_WIRE_14;
wire	[15:0] SYNTHESIZED_WIRE_15;
wire	[15:0] SYNTHESIZED_WIRE_16;

assign	IDLE_FLAG = SYNTHESIZED_WIRE_1;
assign	DATA_AVAILABLE_FLAG = SYNTHESIZED_WIRE_2;
assign	PACKAGE_OUT = SYNTHESIZED_WIRE_13;




cs_y_buffer	b2v_inst(
	.y_packed_in(SYNTHESIZED_WIRE_0),
	.y_0_out(SYNTHESIZED_WIRE_3),
	.y_1_out(SYNTHESIZED_WIRE_4),
	.y_31_out(SYNTHESIZED_WIRE_5));


cs_average	b2v_inst11(
	.rst(RST),
	.clk(CLK),
	.sad_busy_flag(SYNTHESIZED_WIRE_1),
	.data_available_flag(SYNTHESIZED_WIRE_2),
	.columns(COLUMNS),
	.rows(ROWS),
	.y_0(SYNTHESIZED_WIRE_3),
	.y_1(SYNTHESIZED_WIRE_4),
	.y_31(SYNTHESIZED_WIRE_5),
	.y_p_dc_out(SYNTHESIZED_WIRE_6),
	.y_p_dc_out_0(SYNTHESIZED_WIRE_7),
	.y_p_left_out(SYNTHESIZED_WIRE_8),
	.y_p_left_out_0(SYNTHESIZED_WIRE_9),
	.y_p_up_out(SYNTHESIZED_WIRE_10),
	.y_p_up_out_0(SYNTHESIZED_WIRE_11));


cs_SAD	b2v_inst14(
	.rst(RST),
	.clk(CLK),
	.sampling_mode(SAMPLING_RATE),
	.y_in(PACKAGE_IN),
	.y_p_dc_cand(SYNTHESIZED_WIRE_6),
	.y_p_dc_cand_0(SYNTHESIZED_WIRE_7),
	.y_p_left_cand(SYNTHESIZED_WIRE_8),
	.y_p_left_cand_0(SYNTHESIZED_WIRE_9),
	.y_p_up_cand(SYNTHESIZED_WIRE_10),
	.y_p_up_cand_0(SYNTHESIZED_WIRE_11),
	.sad_busy_flag(SYNTHESIZED_WIRE_1),
	.data_available_flag(SYNTHESIZED_WIRE_2),
	.predicted_mode(PREDICTION_MODE),
	.y_predicted(SYNTHESIZED_WIRE_15),
	.y_predicted_0(SYNTHESIZED_WIRE_16),
	.y_residual(SYNTHESIZED_WIRE_12));


cs_quantization	b2v_inst16(
	.bit_shift(BIT_SHIFT),
	.y_p(SYNTHESIZED_WIRE_12),
	.bit_stream(SYNTHESIZED_WIRE_13));


cs_dequantization	b2v_inst6(
	.bit_shift(BIT_SHIFT),
	.y_p(SYNTHESIZED_WIRE_13),
	.bit_stream(SYNTHESIZED_WIRE_14));


cs_adder	b2v_inst7(
	.a(SYNTHESIZED_WIRE_14),
	.b(SYNTHESIZED_WIRE_15),
	.b_0(SYNTHESIZED_WIRE_16),
	.c(SYNTHESIZED_WIRE_0));


endmodule
