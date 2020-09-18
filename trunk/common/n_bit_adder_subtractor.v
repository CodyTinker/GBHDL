//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : n_bit_adder_subtractor.v                                       //
//  Create Date  : September, 2016                                                //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   n-bit ripple carry adder/subtractor module                     //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module n_bit_adder_subtractor #(
  parameter                       DATA_WIDTH = 8
)(
  input [DATA_WIDTH-1:0]          i_data_A,
  input [DATA_WIDTH-1:0]          i_data_B,
  input                           i_carry,
  input [1:0]                     i_control,
  output [DATA_WIDTH-1:0]         o_result,
  output                          o_half_carry,
  output                          o_carry
);

  reg [DATA_WIDTH-1:0] data_B;
  reg                  carry;
  reg                  carry_in;
  wire                 pre_half_carry;
  wire                 pre_carry;
  reg                  half_carry;
  
  n_bit_adder n_bit_adder_inst (
    .i_data_A     (i_data_A),
    .i_data_B     (data_B),
    .i_carry      (carry_in),
    .o_sum        (o_result),
    .o_half_carry (pre_half_carry),
    .o_carry      (pre_carry)
  );
  
  always @(*) begin : combProcess
    //CONTROL	COMMAND
    //  0 0     ADD	  
    //  0 1     ADC	  
    //  1 0     SUB	  
    //  1 1     SBC	 
    case(i_control)
      2'b00 : begin
        data_B = i_data_B;
        carry_in = 1'b0;
        half_carry = pre_half_carry;
        carry = pre_carry;
      end
      2'b01 : begin
        data_B = i_data_B;
        carry_in = i_carry;
        half_carry = pre_half_carry;
        carry = pre_carry;
      end
      2'b10 : begin
        data_B = ~i_data_B;
        carry_in = 1'b1;
        half_carry = !pre_half_carry;
        carry = !pre_carry;
      end
      2'b11 : begin
        data_B = ~i_data_B;
        carry_in = !i_carry;
        half_carry = !pre_half_carry;
        carry = !pre_carry;
      end
    endcase
  end
  
  assign o_half_carry = half_carry;
  assign o_carry = carry;
  
endmodule