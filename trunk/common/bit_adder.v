//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : bit_adder.v                                                    //
//  Create Date  : September, 2016                                                //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Full adder module                                              //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.02 - Updated with standard full adder module                       //
//--------------------------------------------------------------------------------//
module bit_adder (
  input                           i_data_A,
  input                           i_data_B,
  input                           i_carry,
  output                          o_sum,
  output                          o_carry
);
  
  wire prtl_sum;

  assign prtl_sum = i_data_A ^ i_data_B;
  
  assign o_sum = prtl_sum ^ i_carry;
  assign o_carry = (prtl_sum && i_carry) || (i_data_A && i_data_B);

endmodule