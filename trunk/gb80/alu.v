//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : alu.v                                                          //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Arithmatic-Logic Unit.                               //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module alu #(
 parameter                        OPCODE_WIDTH = 3,
 parameter                        DATA_WIDTH = 8
)(
 input [DATA_WIDTH-1:0]           i_data_A,
 input [DATA_WIDTH-1:0]           i_data_B,
 input [OPCODE_WIDTH-1:0]         i_control,
 input [DATA_WIDTH-1:0]           o_data 
)
