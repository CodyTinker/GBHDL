//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : n_bit_adder.v                                                  //
//  Create Date  : September, 2016                                                //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   n-bit ripple carry adder module                                //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module n_bit_adder #(
  parameter                       DATA_WIDTH = 8
)(
  input [DATA_WIDTH-1:0]          i_data_A,
  input [DATA_WIDTH-1:0]          i_data_B,
  input                           i_carry,
  output [DATA_WIDTH-1:0]         o_sum,
  output                          o_half_carry,
  output                          o_carry
);
  
  wire [DATA_WIDTH-1:0] sum;
  wire [DATA_WIDTH:0] carry;
  
  assign carry[0] = i_carry;
  
  genvar i;
  generate
		for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      full_adder full_adder_inst (
        .i_data_A (i_data_A[i]),
        .i_data_B (i_data_B[i]),
        .i_carry  (carry[i]),
        .o_sum    (sum[i]),
        .o_carry  (carry[i+1])
      );
		end
  endgenerate
  
  assign o_sum = sum;
  assign o_half_carry = carry[DATA_WIDTH/2];
  assign o_carry = carry[DATA_WIDTH];

endmodule