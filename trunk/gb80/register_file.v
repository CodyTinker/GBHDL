//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : register_file.v                                                //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Register File Module.                                          //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module register_file #(
  parameter                          DATA_WIDTH = 8,
  parameter                          ADDRESS_WIDTH = 3
)(
  input                              i_clk,
  input                              i_reset,
  input                              i_wr_en,
  input                              i_rd_en,
  input  [ADDRESS_WIDTH-1:0]         i_addr,
  input  [DATA_WIDTH-1:0]            i_data,
  output [DATA_WIDTH-1:0]            o_data
);

  always@ posedge(i_clk) begin : clkProcess
    