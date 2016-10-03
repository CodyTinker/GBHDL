//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : decoder.v                                                      //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Decoder module.                                      //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module decoder #(
  parameter                 DATA_WIDTH = 8,
  parameter                 ADDR_WIDTH = 3,
  parameter                 OPCODE_TYPE_LENGTH=4
)(
  input                     i_clk,
  input                     i_reset,
  //Bus pins
  input [DATA_WIDTH-1:0]    i_data_in,
  
  //Sequencer pins
  output [OPCODE_TYPE_LENGTH-1:0]  o_opcode_type,
  output [DATA_WIDTH-1:0]   o_literal_value,
  output [ADDR_WIDTH-1:0]   o_addr_A,
  output [ADDR_WIDTH-1:0]   o_addr_B
);

endmodule