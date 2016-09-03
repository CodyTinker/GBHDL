//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : gb80_processor.v                                               //
//  Create Date  : August, 2016                                                   //
//  Author       : Cody Tinker                                                    //
//                 Kevin Millar                                                   //
//                                                                                //
//  Description  : Structural workspace for the gb80 processor.                   //
//                                                                                //
//  Dependencies : None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module gb80_processor #(
  //parameter                         DATA_WIDTH = 8
)(
  input                             i_clk
  input [7:0]                       i_memory_data
  output [15:0]                     o_memory_addr
);

  //Global Signal and Bus definitons
  wire [7:0]                        g_data_bus;
  
  //Control Section ---------------------------------------
  register #(
  .DATA_WIDTH(8)
  ) inst_instruction_reg (
  .i_clk(i_clk),
  .i_reset(),
  .i_we(),
  .i_data(),                        //[DATA_WIDTH-1:0]
  .o_data()                         //[DATA_WIDTH-1:0]
  );
  
  module decoder #(
  ) inst_decoder (
  )
  
  module controller_sequencer #(
  ) inst_controller_sequencer (
  )

  //end Control Section -----------------------------------
  
  //Registers Section -------------------------------------
  wire reg_file_addr_data_in, reg_file_addr_data_out,
  register_file #(
  .DATA_WIDTH(8),
  .ADDRESS_WIDTH(3)
  ) inst_register_file (
  .i_clk(i_clk),
  .i_reset(),
  .i_wr_en(),
  .i_rd_en(),
  .i_addr(),
  .i_data(g_data_bus),
  .i_addr_data_in(reg_file_addr_data_in),
  .o_data(),
  .o_addr_data(reg_file_addr_data_out)
  );
  
  module bit_adder #(
  .DATA_WIDTH(16)
)(
  .i_data_A(reg_file_addr_data_out),
  .i_data_B(16'h0001),
  .i_carry_in(1'b0),
  .o_sum(reg_file_addr_data_in),
  .o_carry_out()
)

  assign o_memory_addr = reg_file_addr_data_out;
  
  //end Registers Section ---------------------------------
  
  //Alu Section -------------------------------------------
  register #(
  .DATA_WIDTH(8)
  ) inst_accumulator_reg (
  .i_clk(i_clk),
  .i_reset(),
  .i_we(),
  .i_data(),                        //[DATA_WIDTH-1:0]
  .o_data()                         //[DATA_WIDTH-1:0]
  );
  
  register #(
  .DATA_WIDTH(8)
  ) inst_accumulator_temp_reg (
  .i_clk(i_clk),
  .i_reset(),
  .i_we(),
  .i_data(),                        //[DATA_WIDTH-1:0]
  .o_data()                         //[DATA_WIDTH-1:0]
  );
  
  register #(
  .DATA_WIDTH(8)
  ) inst_temp_reg (
  .i_clk(i_clk),
  .i_reset(),
  .i_we(),
  .i_data(),                        //[DATA_WIDTH-1:0]
  .o_data()                         //[DATA_WIDTH-1:0]
  );
  
  alu #(
  .OPCODE_WIDTH(3),
  .DATA_WIDTH(8)
  ) inst_alu (
  .i_data_A(),                      //[DATA_WIDTH-1:0]  
  .i_data_B(),                      //[DATA_WIDTH-1:0]  
  .i_control(),                     //[OPCODE_WIDTH-1:0]
  .o_data(),                        //[DATA_WIDTH-1:0]  
  .o_flags()                        //[DATA_WIDTH-1:0]
  )
  
  register #(
  .DATA_WIDTH(8)
  ) inst_flags_reg (
  .i_clk(i_clk),
  .i_reset(),
  .i_we(),
  .i_data(),                        //[DATA_WIDTH-1:0]
  .o_data()                         //[DATA_WIDTH-1:0]
  );
  
  //end Alu Section ---------------------------------------
  end
endmodule