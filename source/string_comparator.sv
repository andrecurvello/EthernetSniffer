// File name:   string_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Comparator designed for string matching based on predefined corrupt 
//              strings programmed from the Atom.

module string_comparator
(
  input wire clk,
  input wire n_rst,
  input wire clear,
  input wire [0:16][7:0] flagged_string,
  input wire [4:0] strlen,
  input wire [31:0] data_in,
  output reg match,
  output reg [31:0] data_out
);

reg [7:0] comp_buff [0:19];
int unsigned i, j;
reg next_match;
reg [16:0] char_matches_0;
reg [16:0] char_matches_1;
reg [16:0] char_matches_2;
reg [16:0] char_matches_3;

always_comb begin
  next_match = match;
  char_matches_0 = '0; char_matches_1 = '0; char_matches_2 = '0; char_matches_3 = '0; //Reset char_matches buffers

// A buffer of all 1s will signify a match. Therefore, any character beyond the length of the target string
// should automatically be a 1. The others are dependent on whether they match the flagged_string or not.
  for(j = 0; j < 17; j = j + 1) begin
    char_matches_0[j] = ((strlen != 17 && j < 17 - strlen) || (comp_buff[19 - j] == flagged_string[j]))?1'b1:1'b0;
    char_matches_1[j] = ((strlen != 17 && j < 17 - strlen) || (comp_buff[18 - j] == flagged_string[j]))?1'b1:1'b0;
    char_matches_2[j] = ((strlen != 17 && j < 17 - strlen) || (comp_buff[17 - j] == flagged_string[j]))?1'b1:1'b0;
    char_matches_3[j] = ((strlen != 17 && j < 17 - strlen) || (comp_buff[16 - j] == flagged_string[j]))?1'b1:1'b0;
  end

// Next_match is set to 1 when a char_matches is found that is filled with 1s. Each char_matches handles a different byte offset.
  if (char_matches_0 == '1 || char_matches_1 == '1 || char_matches_2 == '1 || char_matches_3 == '1) begin
    next_match = 1'b1;
  end
end

always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    for(i = 0; i < 20; i = i + 1) begin
      comp_buff[i] <= '0;
    end 
    data_out <= '0;
    match <= '0;
  end else if (clear == 1'b1) begin
    for(i = 0; i < 20; i = i + 1) begin
      comp_buff[i] <= '0;
    end 
    data_out <= '0;
    match <= '0;
  end else begin
    comp_buff[0] <= data_in[7:0];
    comp_buff[1] <= data_in[15:8];
    comp_buff[2] <= data_in[23:16];
    comp_buff[3] <= data_in[31:24];
    for(i = 4; i < 19; i = i + 4) begin
      comp_buff[i] <= comp_buff[i - 4];
      comp_buff[i+1] <= comp_buff[i - 3];
      comp_buff[i+2] <= comp_buff[i - 2];
      comp_buff[i+3] <= comp_buff[i - 1];
    end
    data_out <= {comp_buff[19], comp_buff[18], comp_buff[17], comp_buff[16]};
    match <= next_match;
  end
end

endmodule
