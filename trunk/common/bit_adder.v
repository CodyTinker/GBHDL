//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : bit_adder.v                                                   //
//  Create Date  : September, 2016                                                //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Full adder module                                              //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module bit_adder #(
  parameter                       DATA_WIDTH = 8
)(
  input [DATA_WIDTH-1:0]          i_data_A,
  input [DATA_WIDTH-1:0]          i_data_B,
  input                           i_carry_in,
  output [DATA_WIDTH-1:0]         o_sum,
  output                          o_carry_out
)

  assign  {o_carry_out, o_sum} = i_data_A + i_data_B + i_carry_in;

endmodule