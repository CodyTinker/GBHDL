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
//  Revision 0.02 - Added flags output                                            //
//--------------------------------------------------------------------------------//
module alu #(
 parameter                        OPCODE_WIDTH = 3,
 parameter                        DATA_WIDTH = 8
)(
 input [DATA_WIDTH-1:0]           i_data_A,
 input [DATA_WIDTH-1:0]           i_data_B,
 input [OPCODE_WIDTH-1:0]         i_control,
 input [DATA_WIDTH-1:0]           o_data,
 output [DATA_WIDTH-1:0]          o_flags
);

//The general functions the alu needs to be able to perform are:
//    Add       
//    Subtract  
//    Logical AND 
//    Logical OR 
//    Logical Exclusive OR
//    Compare
//    Left or Right Shifts (both arithmetic and logical)
//    Increment
//    Decrement
//    Set bit
//    Reset bit
//    Test bit

endmodule