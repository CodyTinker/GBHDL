//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : register.v                                                     //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description  : Generic register module                                        //
//                                                                                //
//  Dependencies : None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module register #(
  parameter                         DATA_WIDTH = 8
)(
  input                             i_clk,
  input                             i_reset,
  input                             i_we,
  input      [DATA_WIDTH-1:0]       i_data,
  output reg [DATA_WIDTH-1:0]       o_data
);
  always@(posedge i_clk) begin : clkProcess
    // Synchronous reset
    if (i_reset)
      o_data <= {DATA_WIDTH{1'b0}};
    // Synchronous write enable
    else if (i_we)
      o_data <= i_data;
  end
endmodule