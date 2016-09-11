//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : controller_sequencer.v                                          //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Controller Sequencer.                                //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module controller_sequencer #(
  parameter                             OPCODE_TYPE_LENGTH = 4,
  parameter                             ALU_OPCODE_WIDTH = 3,
  parameter                             ADDR_LENGTH = 3,
  parameter                             DATA_WIDTH = 8
)(
  input                                 i_clk,
  input                                 i_reset,
  
  //decoder pins
  input [OPCODE_TYPE_LENGTH-1:0]        i_opcode_type,
  input [DATA_WIDTH-1:0]                i_literal_value_in,
  input [ADDR_LENGTH-1:0]               i_addr_A,
  input [ADDR_LENGTH-1:0]               i_addr_B,
  
  //control pins
  //register interface:
  output [ADDR_LENGTH-1:0]              o_register_file_addr,
  output                                o_register_file_wr,
  output                                o_register_file_rd,
  
  
  //alu:
  output                                o_accumulator_reg_wr,
  output                                o_tmp_reg_wr,
  output                                o_tmp_reg_rd,
  output [ALU_OPCODE_WIDTH-1:0]         o_alu_control,
  output                                o_alu_rd,
  output                                o_flags_reg_rd,
  //output maybe flags_reg_wr
  
  //memory:
  output                                o_wr_mem,
  output                                o_rd_mem
  
)

endmodule