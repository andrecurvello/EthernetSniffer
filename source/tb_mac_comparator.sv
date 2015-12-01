// File name:   tb_mac_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the IP comparator.

`timescale 1ns/10ps

module tb_mac_comparator();

reg clk;
reg n_rst;
reg [31:0] ip_in;
reg [31:0] data_in;
reg [31:0] data_out;
reg match;
reg clear;

reg [31:0] expected_data_out;
reg expected_match;

reg [31:0] sample_data;
reg [31:0] sample_data_2;
reg [31:0] sample_data_shift1;
reg [31:0] sample_data_shift1_2;
reg [31:0] sample_data_shift2;
reg [31:0] sample_data_shift2_2;
reg [31:0] sample_data_shift3;
reg [31:0] sample_data_shift3_2;
reg [31:0] sample_data_shift3_3;

mac_comparator COMP(.clk, .n_rst, .clear, .ip_in, .data_in, .match, .data_out);

localparam CLK_PERIOD = 10;

//Clock generation block
always
begin
	clk = 1'b0;
	#(CLK_PERIOD/2.0);
	clk = 1'b1;
	#(CLK_PERIOD/2.0);
end

clocking cb @(posedge clk);
	default input #1step output #100ps;
	output #800ps n_rst = n_rst;
	output datai = data_in;
	output ipin = ip_in;
	output c = clear;
	input datao = data_out;
	input m = match;
endclocking

initial
begin
	n_rst = 1'b1;
	sample_data = 32'hE5F60000; //E5:F6:00:00
        sample_data_2 = 32'hA1B2C3D4; //A1:B2:C3:D4
	sample_data_shift1 = 32'hD4E5F600;
	sample_data_shift1_2 = 32'h00A1B2C3;
	sample_data_shift2 = 32'hC3D4E5F6;
	sample_data_shift2_2 = 32'h0000A1B2;
	sample_data_shift3 = 32'hF6000000;
	sample_data_shift3_2 = 32'hB2C3D4E5;
	sample_data_shift3_3 = 32'h000000A1;
	data_in = 32'h0000;
	ip_in = 32'h0000;
	clear = '0;

	//Reset Test Case
	cb.n_rst <= 1'b1;
	@cb; n_rst = 1'b0; @cb;
	expected_data_out = '0;
	expected_match = '0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("1: Reset Test Case: Incorrect Match Flag");
	cb.n_rst <= 1'b1;
	@cb; @cb;
	
	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 2.1 No Shift*********************//
	ip_in = sample_data; 	
	data_in = sample_data; 
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("2.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 2.2
	data_in = sample_data_2; 
	expected_data_out = sample_data;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.2: Successful Match: Incorrect Match Flag");

	//Test Case 2.3
	data_in = 32'h0000; 
	expected_data_out = sample_data_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.2: Successful Match: Incorrect Match Flag");

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 3.1: One Shift*********************//
	data_in = sample_data_shift1;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 3.2
	data_in = sample_data_shift1_2;
	expected_data_out = sample_data_shift1;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 3.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift1_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.3: Successful Match: Incorrect Match Flag");
	

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 4.1: Two Shift*********************//
	data_in = sample_data_shift2;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 4.2
	data_in = sample_data_shift2_2;
	expected_data_out = sample_data_shift2;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 4.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift2_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.3: Successful Match: Incorrect Match Flag");

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 5.1: Two Shift*********************//
	data_in = sample_data_shift3;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 5.2
	data_in = sample_data_shift3_2;
	expected_data_out = sample_data_shift3;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 5.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift3_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.3: Successful Match: Incorrect Match Flag");
	
	@cb; clear = 1'b1; @cb;

	$stop;

end
endmodule
