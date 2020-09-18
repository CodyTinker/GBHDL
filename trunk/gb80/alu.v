//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : alu.v                                                          //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Arithmetic-Logic Unit.                               //
//                 Latency = 1 cycle                                              //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.03 - Added capability for 8-bit operations                         //
//--------------------------------------------------------------------------------//
module alu #(
 parameter                        OPCODE_WIDTH = 3,
 parameter                        DATA_WIDTH = 8
)(
 input                            i_clk,
 input [DATA_WIDTH-1:0]           i_data_A,
 input [DATA_WIDTH-1:0]           i_data_B,
 input [OPCODE_WIDTH-1:0]         i_control,
 output [DATA_WIDTH-1:0]          o_data,
 output [3:0]                     o_flags
);
  
  reg                       carry_in;
  reg [DATA_WIDTH-1:0]      operand;
  reg [DATA_WIDTH-1:0]      nxt_data;
  reg [DATA_WIDTH-1:0]      data;
  reg [3:0]                 nxt_flags;
  
  //   3   2   1   0
  // | Z | N | H | CY |
  reg [3:0]                 flags;
  wire [DATA_WIDTH-1:0]     sum;
  wire                      half_carry;
  wire                      carry_out;
  
  //FIXME: Latency may need to be changed, can be increased by changing to time
  //  sliced 4-bit Adder/Subtractor
  //FIXME: May need flags input; accumulator register (A) currently located in
  //  register file
  
  //The general functions the alu needs to be able to perform are:
  //    Add
  //    Add w/ Carry
  //    Subtract
  //    Subtract w/ Carry
  //    Logical AND
  //    Logical Exclusive OR
  //    Logical OR
  //    Compare'
  n_bit_adder_subtractor #(
    .DATA_WIDTH (8)
  )n_bit_adder_subtractor_inst (
    .i_data_A     (i_data_A),
    .i_data_B     (i_data_B),
    .i_carry      (flags[0]),
    .i_control    ({i_control[1], !i_control[2] && i_control[0]}),
    .o_result     (sum),
    .o_half_carry (half_carry),
    .o_carry      (carry_out)
  );
  
  always @(*) begin : combProcess
      if (i_control[2]) begin
        case (i_control[1:0])
          2'b00 : begin
            nxt_data = i_data_A & i_data_B;
            nxt_flags[2] = 1'b0;
            nxt_flags[1] = 1'b0;
            nxt_flags[0] = 1'b0;
          end
          2'b01 : begin
            nxt_data = i_data_A ^ i_data_B;
            nxt_flags[2] = 1'b0;
            nxt_flags[1] = 1'b0;
            nxt_flags[0] = 1'b0;
          end
          2'b10 : begin 
            nxt_data = i_data_A | i_data_B;
            nxt_flags[2] = 1'b0;
            nxt_flags[1] = 1'b0;
            nxt_flags[0] = 1'b0;
          end
          2'b11 : begin
            nxt_data = sum;
            nxt_flags[2] = 1'b1;
            nxt_flags[1] = half_carry;
            nxt_flags[0] = carry_out;
          end
        endcase
      end else begin
        nxt_data = sum;
        nxt_flags[2] = i_control[1];
        nxt_flags[1] = half_carry;
        nxt_flags[0] = carry_out;
      end 
      nxt_flags[3] = !(|nxt_data);
  end
  
  always @(posedge i_clk) begin : clkProcess
    data  <= nxt_data;
    flags <= nxt_flags;
  end
  
  assign o_data  = data;
  assign o_flags = flags;

  //    Left or Right Shifts (both arithmetic and logical)
  //    Increment
  //    Decrement
  //    Set bit
  //    Reset bit
  //    Test bit

endmodule